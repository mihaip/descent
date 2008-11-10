//
//  PIDFence.m
//  Descent
//
//  Created by Mihai Parparita on 9/27/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFence.h"
#import "PIDEntityWithFrame.h"
#import "PIDTextureSprite.h"

// While we're touching the player, for every period of this lenth (in seconds), 
// one unit of health is removed
#define kFencePlayerHurtTime 0.08

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
    vertexCount_ = 60;
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

    // Make sure vertices aren't too close
    for (int i = 1; i < vertexCount_ - 2; i++) {
      if (intervalPositions[i] < intervalPositions[i - 1]) {
        intervalPositions[i] = intervalPositions[i - 1] + 6 + (random() % 4);
      } else if (intervalPositions[i] - intervalPositions[i - 1] < 10) {
        intervalPositions[i] += 10;
      }
    }

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

static int kLineThicknesses[] = {3, 1, 1};
static int kLineOffsets[] = {0, -2, 2};
static GLfloat kLineColors[][3] = {
  {1.0, 1.0, 0.0},
  {0.8, 0.8, 0.0},
  {0.8, 0.8, 0.0},
};

- (void)draw {
  glVertexPointer(2, GL_FLOAT, 0, currentVertices_);
  glEnableClientState(GL_VERTEX_ARRAY);

  for (int i = 0; i < 3; i++) {
    glPushMatrix();
    glTranslatef(0, kLineOffsets[i], 0);
    glColor4f(kLineColors[i][0], kLineColors[i][1], kLineColors[i][2], 1.0);
    glLineWidth(kLineThicknesses[i]);
    
    glDrawArrays(GL_LINE_STRIP, 0, vertexCount_);
    glPopMatrix();
  }
}

@end

@implementation PIDFence

- initWithPosition:(CGPoint)position size:(CGSize)size {
  PIDSprite *lightningSprite =
      [[PIDLightiningSprite alloc] 
           initWithSize:CGSizeMake(size.width, size.height)];

  if (self = [super initWithSprite:lightningSprite position:position]) {
    [self fixPosition];
  }

  [lightningSprite release];

  return self;
}

- (void)handleTick:(double)ticks {
  if (!isHurtingPlayer_) return;
  
  hurtTime_ += ticks;
  if (hurtTime_ > kFencePlayerHurtTime) {
    [player_ decreaseHealth];
    hurtTime_ = 0;
  }
}

- (void)startHurtingPlayer:(PIDPlayer *)player {
  isHurtingPlayer_ = YES;
  player_ = [player retain];
  hurtTime_ = 0;
}

- (void)stopHurtingPlayer {
  isHurtingPlayer_ = NO;
  [player_ release];
}

- (BOOL)isHurtingPlayer {
  return isHurtingPlayer_;
}

- (void)dealloc {
  if (player_) {
    [player_ release];
  }
  
  [super dealloc];
}


@end
