//
//   PIDGame.m
//   Descent
//
//   Created by Mihai Parparita on 9/10/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDColor.h"
#import "PIDRectangleSprite.h"
#import "PIDGame.h"
#import "PIDTextureSprite.h"
#import "PIDPlatform.h"
#import "DescentAppDelegate.h"

static double kDescentSpeeds[] = {
  50, // easy
  75, // medium
  100 // hard
};

#define kPlayerHeight 32
// Enough room for the player to fit along the top
#define kFenceTop (kStatusBarHeight + kPlayerHeight/2)
#define kFenceHeight 20
#define kStatusBarHeight 16
#define kBackgroundTileSize 256 // In pixels

#define kFloorDigitWidth 51
#define kFloorDigitHeight 86

static PIDTextureSprite *kFloorNumbersSprite;

// Private methods
@interface PIDGame ()
- (void)initBackground;
- (void)initFloorDisplay;
- (void)initPlayer;
- (void)initPlatforms;
- (void)initFence;
- (void)initStatus;
- (BOOL)addPlatformWithPosition:(CGPoint)platformPosition
                           type:(PIDPlatformType) type;
- (void)addPlatformWithRandomPositionBetween:(int)minY and:(int)maxY;
- (void)updatePlatforms;
- (void)updateBackground;
- (void)updateFloorDisplay;
- (void)gameOver;
@end

@implementation PIDGame

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;
  
  kFloorNumbersSprite = 
      [[PIDTextureSprite alloc] initWithImage:@"floor-numbers.png"
                                         size:CGSizeMake(kFloorDigitWidth, 
                                                         kFloorDigitHeight)
                                       frames:10];
}

- initWithView:(EAGLView *)glView difficulty:(PIDGameDifficulty)difficulty {
  if (self = [super init]) {
    glView_ = [glView retain];
    
    difficulty_ = difficulty;
    descentPosition_ = 0;
    platformGenerationTriggerPosition_ = 0;
    
    // Make sure that fixed entities appear in front of regular ones
    normalLayer_ = [[PIDEntity alloc] initWithSprite:kNullSprite];
    fixedLayer_ = [[PIDEntity alloc] initWithSprite:kNullSprite];
    
    [self initBackground];
    [self initFloorDisplay];
    [self initPlayer];
    [self initPlatforms];
    [self initFence];
    
    [self initStatus];    
  }
  
  return self;
}

- (void)initBackground {
  CGSize viewSize = [glView_ size];
  // Background texture is 256 x 256, we want to tile it
  PIDTextureSprite *backgroundSprite = 
      [[PIDTextureSprite alloc] initWithImage:@"paper.png" 
                                         size:CGSizeMake(kBackgroundTileSize * 2, 
                                                         kBackgroundTileSize * 3)
                                       frames:1];
  background_ = 
      [[PIDEntity alloc] initWithSprite:backgroundSprite 
                               position:CGPointMake(viewSize.width/2, 
                                                    viewSize.height - [backgroundSprite size].height/2)];
  [backgroundSprite release];
  [normalLayer_ addChild:background_];
  
  trail_ = [[PIDTrail alloc] init];
  [normalLayer_ addChild:trail_];
}

- (void)initFloorDisplay {
  CGSize viewSize = [glView_ size];

  currentFloorDisplay_ = [[PIDNumbersDisplay alloc] 
                   initWithPosition:CGPointMake(viewSize.width/2 - 20, 
                                                viewSize.height/2)
                   sprite:kFloorNumbersSprite];
  [currentFloorDisplay_ setValue:@"1"];
  [currentFloorDisplay_ unfixPosition];
  [normalLayer_ addChild:currentFloorDisplay_];

  nextFloorDisplay_ = [[PIDNumbersDisplay alloc] 
                       initWithPosition:CGPointMake(viewSize.width/2 + 30, 
                                                    -viewSize.height/2)
                          sprite:kFloorNumbersSprite];
  [nextFloorDisplay_ setValue:@"2"];
  [nextFloorDisplay_ unfixPosition];
  [normalLayer_ addChild:nextFloorDisplay_];  
}

- (void)initPlayer {
  CGSize viewSize = [glView_ size];
  // Center player in view
  player_ = [[PIDPlayer alloc] 
             initWithPosition:CGPointMake(viewSize.width / 2, 
                                          viewSize.height - kFenceTop - 
                                              kFenceHeight/2 - kPlayerHeight)
                         game:self];
  [normalLayer_ addChild:player_];
}

- (void)initPlatforms {
  CGSize viewSize = [glView_ size];
  platforms_ = [[NSMutableArray alloc] initWithCapacity:10];
  
  for (int i = 0; i < 3; i++) {
    // Always start with a platform underneath the player (who is in the 
    // center)
    if (i == 0) {
      [self addPlatformWithPosition:CGPointMake(viewSize.width / 2, 
                                                viewSize.height / 4)
                               type:kPlatformNormal];
    } else {
      // Other platforms start in the bottom quarter the screen, so that the
      // player can fall on the one that was created above
      [self addPlatformWithRandomPositionBetween:0 and:viewSize.height/4];
    }    
  }
}

- (BOOL)addPlatformWithPosition:(CGPoint)platformPosition
                           type:(PIDPlatformType) type {
  PIDPlatform *newPlatform = 
      [[PIDPlatform alloc] initWithPosition:platformPosition
                                       type:type];

  // Make sure we don't hit any of the existing platforms
  // TODO(mihaip): handle cases where user can be trapped (sunken platform
  // between two raised platforms and/or wall)
  for (PIDPlatform *platform in platforms_) {
    if ([platform intersectsWith:newPlatform withMargin:5]) {
      [newPlatform release];
      return NO;
    }
  }
  
  [normalLayer_ addChild:newPlatform];
  [platforms_ addObject:newPlatform];
  [newPlatform release];
  
  return YES;
}

- (void)addPlatformWithRandomPositionBetween:(int)minY and:(int)maxY {
  CGSize viewSize = [glView_ size];
  CGPoint platformPosition;
  BOOL addedPlatform;

  int typeChooser = random() % 20;
  PIDPlatformType type;
  switch (typeChooser) {
    case 0: case 1: type = kPlatformBouncy; break;
    case 2: case 3: type = kPlatformKiller; break;
    case 4: type = kPlatformMoverLeft; break;
    case 5: type = kPlatformMoverRight; break;
    default: type = kPlatformNormal; break;
  }
  
  do {
    platformPosition.x = 
        (random() % ((int) viewSize.width - kPlatformWidth)) + kPlatformWidth/2;
    platformPosition.y = minY +(random() % (maxY - minY));
    
    addedPlatform = [self addPlatformWithPosition:platformPosition type:type];
  } while (!addedPlatform);
}

- (void)initFence {
  CGSize viewSize = [glView_ size];
  
  fence_ = [[PIDFence alloc] 
            initWithPosition:CGPointMake(viewSize.width / 2,
                                         viewSize.height - kFenceTop - 
                                             kFenceHeight/2)
                        size:CGSizeMake(viewSize.width, kFenceHeight)];
  
  [fixedLayer_ addChild:fence_];
}

- (void)updatePlatforms {
  // Nothing to do until we're at the trigger position
  if (descentPosition_ <= platformGenerationTriggerPosition_) return;
  
  // Add a new platform
  platformGenerationTriggerPosition_ = descentPosition_ + 55 + (random() % 20);
  
  [self addPlatformWithRandomPositionBetween:-platformGenerationTriggerPosition_
                                         and:-descentPosition_];

  // Also check if any platforms scrolled off the top and so can be removed
  CGSize viewSize = [glView_ size];
  
  NSMutableArray *platformsToRemove = [NSMutableArray arrayWithCapacity:1];
  for (PIDPlatform *platform in platforms_) {
    if ([platform bounds].origin.y > -descentPosition_ + viewSize.height) {
      [platformsToRemove addObject:platform];
    }
  }
  for (PIDPlatform *platform in platformsToRemove) {
    [normalLayer_ removeChild:platform];
    [platforms_ removeObject:platform];
  }
}

- (void)initStatus {
  CGSize viewSize = [glView_ size];
  
  PIDColor *pauseCoverColor = [[PIDColor alloc] initWithRed:0.2
                                                      green:0.2
                                                       blue:0.2
                                                      alpha:0.6];
  PIDRectangleSprite *pauseCoverSprite = [[PIDRectangleSprite alloc] 
                                          initWithSize:viewSize
                                                 color:pauseCoverColor];
  pauseCover_ = [[PIDEntity alloc] initWithSprite:pauseCoverSprite
                                         position:CGPointMake(viewSize.width/2, 
                                                              viewSize.height/2)];
  [pauseCover_ fixPosition];
  [pauseCover_ disable];
  [fixedLayer_ addChild:pauseCover_];
  [pauseCoverSprite release];
  [pauseCoverColor release];
  
#if SHOW_FPS
  fpsDisplay_ = [[PIDNumbersDisplay alloc]
                 initWithPosition:CGPointMake(7, 9)];
  [fixedLayer_ addChild:fpsDisplay_];
#endif
  
  // Health display
  healthDisplay_ = [[PIDHealthDisplay alloc] 
                    initWithPosition:CGPointMake(viewSize.width - 2, viewSize.height - 10)];
  [fixedLayer_ addChild:healthDisplay_];
  [healthDisplay_ update:player_];
  
  // Pause button
  pauseButtonSprite_ = [[PIDTextureSprite alloc] initWithImage:@"pause.png" 
                                                          size:CGSizeMake(71, 16)
                                                        frames:2];
  pauseButton_ = [[PIDEntity alloc] initWithSprite:pauseButtonSprite_
                                          position:CGPointMake(38, viewSize.height - 10)];
  [pauseButton_ fixPosition];
  [fixedLayer_ addChild:pauseButton_];
  
  flash_ = [[PIDFlash alloc] initWithSize:viewSize];
  [fixedLayer_ addChild:flash_];
}

- (void)handleTick:(double)ticks {
#if SHOW_FPS
  double fps = [glView_ framesPerSecond];
  [fpsDisplay_ setValue:[NSString stringWithFormat:@"%4.1f", fps]];
#endif
  
  descentPosition_ += kDescentSpeeds[difficulty_] * ticks;
  
  [glView_ setViewportOffsetX:0 andY:descentPosition_];

  [self updatePlatforms];
  [self updateBackground];
  [self updateFloorDisplay];
  
  [player_ handleTick:ticks];
  
  if ([player_ top] > [fence_ top] - descentPosition_) {
    if (![fence_ isHurtingPlayer]) {
      [fence_ startHurtingPlayer:player_];
    }
  } else if ([fence_ isHurtingPlayer]) {
    [fence_ stopHurtingPlayer];
  } else if ([player_ top] < -descentPosition_ - [glView_ size].height) {
    [self gameOver];
    return;
  }
    
  [fence_ handleTick:ticks];
  
  if (lastLandedPlatform_) {
    PIDEntity *landedEntity = [player_ hitEntityOnSide:kSideBottom];
    
    if (landedEntity != lastLandedPlatform_) {
      [lastLandedPlatform_ handlePlayerLeaving:player_];
      lastLandedPlatform_ = NULL;
    }
  }
  
  if ([player_ landed]) {
    PIDEntity *landedEntity = [player_ hitEntityOnSide:kSideBottom];
    if ([landedEntity isKindOfClass:[PIDPlatform class]]) {
      PIDPlatform *landedPlatform = (PIDPlatform*) landedEntity;
      [landedPlatform handlePlayerLanding:player_];
      lastLandedPlatform_ = landedPlatform;
    }
  }

  if ([player_ isDead]) {
    [self gameOver];
  } else {
    if ([player_ health] < [healthDisplay_ currentValue]) {
      [flash_ trigger];
    }
    [healthDisplay_ update:player_];    
  }
}

- (void)updateMovementConstraints {
  [player_ resetMovementConstraints];

  // First constrain movement by viewing rect (just the left and right, since
  // top and bottom just kill the player)
  CGSize viewSize = [glView_ size];
  [player_ addMovementConstraint:0
                          entity:normalLayer_
                          onSide:kSideLeft];
  [player_ addMovementConstraint:viewSize.width
                          entity:normalLayer_
                          onSide:kSideRight];
  
  // Then by platforms
  CGPoint playerPosition = [player_ position];
  for (PIDPlatform *platform in platforms_) {
    double platformBottom = [platform collisionBottom];
    double platformTop = [platform collisionTop];
    
    double platformLeft = [platform collisionLeft];
    double platformRight = [platform collisionRight];
    CGPoint platformPosition = [platform position];
    
    CGRect intersection = [player_ intersection:platform];
    CGSize overlap = intersection.size;
    if (overlap.width == 0 && overlap.height == 0) continue;

    // Constrain on vertical axis
    if (overlap.width > overlap.height) {
      if (playerPosition.y > platformPosition.y) {
        [player_ addMovementConstraint:platformTop 
                                entity:platform 
                                onSide:kSideBottom];
      } else { // Player is below platform
        [player_ addMovementConstraint:platformBottom 
                                entity:platform
                                onSide:kSideTop];
      }        
    }
    // Constrain on horizontal axis
    else {
      // Player is to the left of the platform
      if (playerPosition.x < platformPosition.x) {
        [player_ addMovementConstraint:platformLeft 
                                entity:platform
                                onSide:kSideRight];
      } else { // Player is to the right of the platform
        [player_ addMovementConstraint:platformRight
                                entity:platform
                                onSide:kSideLeft];
      }        
    }
  }
}

- (void)updateBackground {
  double backgroundTop = [background_ top];
  double viewTop = -descentPosition_ + [glView_ size].height;
  // Shift background so that it appears infinitely tiled
  if (backgroundTop - viewTop > kBackgroundTileSize) {
    [background_ moveBy:CGSizeMake(0, -kBackgroundTileSize)];
  }
  
  [trail_ update:player_];
}

- (void)updateFloorDisplay {
  CGSize viewSize = [glView_ size];
  double floorDisplayBottom = [currentFloorDisplay_ bottom];
  double viewTop = -descentPosition_ + viewSize.height;
  
  if (floorDisplayBottom > viewTop) {
    int floor = descentPosition_/viewSize.height + 3;
    [currentFloorDisplay_ setValue:[NSString stringWithFormat:@"%d", floor]];
    [currentFloorDisplay_ 
         setPosition:CGPointMake(viewSize.width/2 + (random() % 100) - 50,
                                 -(floor - 1.5) * viewSize.height)];
    
    PIDNumbersDisplay *temp;
    temp = currentFloorDisplay_;
    currentFloorDisplay_ = nextFloorDisplay_;
    nextFloorDisplay_ = temp;
  }
}

- (void)handleTouchBegin:(CGPoint)touchPoint {
  // Handle buttons
  if ([pauseButton_ isPointInside:touchPoint]) {
    if (isPaused_) {
      [self unpause];
    } else {
      [self pause];
    }
    return;
  }
  
  // Otherwise map to player movement
  CGSize viewSize = [glView_ size];
  PIDPlayerHorizontalDirection playerDirection = kNone;
  if (touchPoint.x < viewSize.width * 0.4) {
    playerDirection = kLeft;
  } else if (touchPoint.x > viewSize.width * 0.6) {
    playerDirection = kRight;    
  }
  
  [player_ setHorizontalDirection:playerDirection];
}

- (void)handleTouchMove:(CGPoint)touchPoint {
  // Nothing for now
}

- (void)handleTouchEnd:(CGPoint)touchPoint {
  [player_ setHorizontalDirection:kNone];
}

- (void)draw {
  [normalLayer_ draw];
  [fixedLayer_ draw];
}

- (BOOL)isPaused {
  return isPaused_;
}

- (void)pause {
  [glView_ stopAnimation];
  
  [pauseCover_ enable];
  [pauseButtonSprite_ setFrame:1];
  [glView_ draw];
  
  isPaused_ = true;
}

- (void)unpause {
  [glView_ startAnimation];
  
  [pauseCover_ disable];
  [pauseButtonSprite_ setFrame:0];
  [glView_ draw];

  isPaused_ = false;
}

- (void)suspend {
  [self pause];
}

- (void)resume {
  // Don't resume the game, let the user choose when they want unpause
}

- (void)gameOver {
  [GetAppInstance() switchToMenu];  
}

- (void)dealloc {
  [glView_ release];
  
  // Background
  [background_ release];
  [trail_ release];
  
  // Game entities
  [player_ release];
  [fence_ release];
  [platforms_ release];

  // Status
  [pauseCover_ release];
  [healthDisplay_ release];
  [pauseButton_ release];
  [pauseButtonSprite_ release];
#if SHOW_FPS
  [fpsDisplay_ release];
#endif
  
  // Floor display
  [currentFloorDisplay_ release];
  [nextFloorDisplay_ release];
  
  // Roots
  [normalLayer_ release];
  [fixedLayer_ release];
  
  [super dealloc];  
}

@end
