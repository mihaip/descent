//
//  PIDFence.m
//  Descent
//
//  Created by Mihai Parparita on 9/27/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFence.h"
#import "PIDTextureSprite.h"

static PIDTextureSprite *kCapsSprite;

@interface PIDCap : PIDEntity {
 @private
  int frame_;
}

- initWithFrame:(int)frame position:(CGPoint) position;

@end

@implementation PIDCap

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;
  
  kCapsSprite = [[PIDTextureSprite alloc] initWithImage:@"caps.png"
                                                   size:CGSizeMake(20, 12)
                                                 frames:2];
}

- initWithFrame:(int)frame position:(CGPoint) position {
  if (self = [super initWithSprite:kCapsSprite position:position]) {
    frame_ = frame;
  }
  
  return self;
}

- (void)draw {
  [kCapsSprite setFrame:frame_];
  
  [super draw];
}

@end


@interface PIDLightiningSprite : PIDSprite {
 @private
  // Number of vertices that make up this bolt
  int vertexCount_;
  // Base points along center line
  GLfloat *baseVertices_;
  // Vectors that are added to base points
  GLfloat *vertexVectors_;
  // Multiplier (in -1 to 1 range) applied to vector before adding it to the 
  // vertex
  GLfloat *vertexVectorMultiplers_;
  GLfloat *vertexSpeeds_;
  // If YES, the multiplier is increasing, if NO, decreasing
  BOOL *vertexDirections_;
  // Current sum of base point + multipler * vector (to be rendered)
  GLfloat *currentVertices_;
  
  NSTimer* updateMultipliersTimer_;
}

- (void)applyVectors;
- (void)updateMultipliers;

@end

@implementation PIDLightiningSprite

static int compareInts(const void * a, const void * b) {
  return *(int*)a - *(int*)b;
}

- initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    vertexCount_ = 100 + (random() % 20) - 10;
    baseVertices_ = malloc(sizeof(GLfloat) * vertexCount_ * 2);
    
    // Endpoints are fixed
    baseVertices_[0] = -size_.width/2;
    baseVertices_[1] = 0;
    baseVertices_[2 * vertexCount_ - 2] = size.width/2;
    baseVertices_[2 * vertexCount_ - 1] = 0;
    
    // Others are randomly positioned along the interval
    int *intervalPositions = malloc(sizeof(int) * (vertexCount_ - 2));
    
    for (int i = 0; i < vertexCount_ - 2; i++) {
      intervalPositions[i] = random() % ((int) (size_.width));
    }
    
    qsort(intervalPositions, vertexCount_ - 2, sizeof(int), compareInts);
    
    for (int i = 0; i < vertexCount_ - 2; i++) {
      baseVertices_[2 * (i + 1)] = intervalPositions[i] - size_.width/2;
      baseVertices_[2 * (i + 1) + 1] = 0;
    }
    
    free(intervalPositions);
    
    // Generate a vector for each inner vertex (with a wider range in the 
    // vertical)
    vertexVectors_ = malloc(sizeof(GLfloat) * (vertexCount_ - 2) * 2);
    for (int i = 0; i < vertexCount_ - 2; i++) {
      vertexVectors_[2 * i] = random() % 10 - 5;
      vertexVectors_[2 * i + 1] = 
          random() % ((int) (size_.height/2.0)) - size_.height/4.0;
    }
    
    // Initialize multipliers to random values so that they don't all move in
    // sync
    vertexVectorMultiplers_ = malloc(sizeof(GLfloat) * (vertexCount_ - 2));
    for (int i = 0; i < vertexCount_ - 2; i++) {
      vertexVectorMultiplers_[i] = ((double)(random() % 100))/50.0 - 1.0;
    }
    
    // And random speeds so that they're not all in phase
    vertexSpeeds_ = malloc(sizeof(GLfloat) * (vertexCount_ - 2));
    for (int i = 0; i < vertexCount_ - 2; i++) {
      vertexSpeeds_[i] = 0.20 + (random() % 100)/500.0;
    }    
    
    vertexDirections_ = malloc(sizeof(BOOL) * (vertexCount_ - 2));
    currentVertices_ = malloc(sizeof(GLfloat) * vertexCount_ * 2);    
    
    [self applyVectors];    
    
    updateMultipliersTimer_ = 
        [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                         target:self 
                                       selector:@selector(updateMultipliers) 
                                       userInfo:nil 
                                        repeats:YES];    
  }
  
  return self;
}

- (void)applyVectors {
  // Endpoints are fixed
  currentVertices_[0] = baseVertices_[0];
  currentVertices_[1] = baseVertices_[1];
  currentVertices_[2 * vertexCount_ - 2] = baseVertices_[2 * vertexCount_ - 2];
  currentVertices_[2 * vertexCount_ - 1] = baseVertices_[2 * vertexCount_ - 1];
  
  for (int i = 0; i < vertexCount_ - 2; i++) {
    int baseX = 2 * (i + 1);
    int baseY = 2 * (i + 1) + 1;
    int vectorX = 2 * i;
    int vectorY = 2 * i + 1;

    currentVertices_[baseX] = baseVertices_[baseX] + 
                              vertexVectors_[vectorX] * vertexVectorMultiplers_[i];
    currentVertices_[baseY] = baseVertices_[baseY] +
                              vertexVectors_[vectorY] * vertexVectorMultiplers_[i];

  }
}

- (void)updateMultipliers {
  for (int i = 0; i < vertexCount_ - 2; i++) {
    BOOL direction = vertexDirections_[i];
    GLfloat multiplier = vertexVectorMultiplers_[i];
    GLfloat speed = vertexSpeeds_[i];
    
    if (direction) {
      multiplier += speed;
      if (multiplier > 1.0) {
        multiplier = 1.0;
        direction = NO;
      }
    } else {
      multiplier -= speed;
      if (multiplier < -1.0) {
        multiplier = -1.0;
        direction = YES;
      }
    }
    
    vertexDirections_[i] = direction;
    vertexVectorMultiplers_[i] = multiplier;
  }
  
  [self applyVectors];
}

- (void)dealloc {
  free(baseVertices_);
  free(vertexVectors_);
  free(vertexVectorMultiplers_);
  free(vertexSpeeds_);
  free(currentVertices_);
  [super dealloc];
}

static int kLineThicknesses[] = {5, 3, 1};
static GLfloat kLineLightness[] = {0.0, 0.4, 0.9};

- (void)draw {
  glVertexPointer(2, GL_FLOAT, 0, currentVertices_);
  glEnableClientState(GL_VERTEX_ARRAY);

  for (int i = 0; i < 3; i++) {
    glColor4f(kLineLightness[i], kLineLightness[i], 1.0, 1.0);
    glLineWidth(kLineThicknesses[i]);
    
    glDrawArrays(GL_LINE_STRIP, 0, vertexCount_);
  }
}

@end

@implementation PIDFence

- initWithPosition:(CGPoint)position size:(CGSize)size {
  if (self = [super initWithSprite:kNullSprite position:position]) {
    PIDEntity *leftCap = [[PIDCap alloc] initWithFrame:0
                                              position:CGPointMake(-size.width/2 + 10, 0)];
    PIDEntity *rightCap = [[PIDCap alloc] initWithFrame:1
                                              position:CGPointMake(size.width/2 - 10, 0)];

    PIDSprite *lightningSprite = [[PIDLightiningSprite alloc] 
        initWithSize:CGSizeMake(size.width - 40, size.height)];
    PIDEntity *lightning = [[PIDEntity alloc] initWithSprite:lightningSprite
                                                    position:CGPointMake(0, 0)];
    
    [self addChild:lightning];
    [self addChild:leftCap];
    [self addChild:rightCap];

    [lightning release];
    [lightningSprite release];
    [leftCap release];
    [rightCap release];
  }
  
  return self;
}

@end
