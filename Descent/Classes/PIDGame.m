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

#define kDescentSpeed 50 // In pixels/s
#define kPlayerHeight 32
// Enough room for the player to fit along the top
#define kFenceTop kPlayerHeight/2
#define kFenceHeight 20
#define kStatusBarHeight 16

// Private methods
@interface PIDGame ()
- (void)initPlayer;
- (void)initPlatforms;
- (void)initFence;
- (void)initStatus;
- (BOOL)addPlatformWithPosition:(CGPoint)platformPosition;
- (void)addPlatformWithRandomPositionBetween:(int)minY and:(int)maxY;
- (void)updatePlatforms;
- (void)updateMovementConstraints;
@end

@implementation PIDGame

- initWithView:(EAGLView *)glView {
  if (self = [super init]) {
    glView_ = [glView retain];
    [glView_ setEventTarget:self];
    
    // For now use a fixed seed so that repeated runs are reproducible
    srandom(27);
    
    descentPosition_ = 0;
    platformGenerationTriggerPosition_ = 0;
    
    // Make sure that fixed entities appear in front of regular ones
    normalLayer_ = [[PIDEntity alloc] initWithSprite:kNullSprite];
    fixedLayer_ = [[PIDEntity alloc] initWithSprite:kNullSprite];
    
    [self initPlayer];
    [self initPlatforms];
    [self initFence];
    
    [self initStatus];
    
    glView_.animationInterval = 1.0 / 60.0;
  }
  
  return self;
}

- (void)initPlayer {
  CGSize viewSize = [glView_ size];
  // Center player in view
  player_ = [[PIDPlayer alloc] 
             initWithPosition:CGPointMake(viewSize.width / 2, 
                                          viewSize.height - kFenceTop - 
                                              kFenceHeight/2 - kPlayerHeight)];
  [normalLayer_ addChild:player_];
}

- (void)initPlatforms {
  CGSize viewSize = [glView_ size];
  platforms_ = [[NSMutableArray alloc] initWithCapacity:10];
  for (int i = 0; i < 5; i++) {
    // Always start with a platform underneath the player (who is in the 
    // center)
    if (i == 0) {
      CGPoint platformPosition;
      platformPosition.x = viewSize.width / 2;
      platformPosition.y = viewSize.height / 2;
      [self addPlatformWithPosition:platformPosition];
    } else {
      // Other platforms start in the bottom half the screen, so that the
      // player can fall on the one that was created above
      [self addPlatformWithRandomPositionBetween:0 and:viewSize.height/2];
    }    
  }
}

- (BOOL)addPlatformWithPosition:(CGPoint)platformPosition {
  PIDPlatform *newPlatform = [[PIDPlatform alloc] 
                           initWithPosition:platformPosition];

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
  
  do {
    platformPosition.x = 
        (random() % ((int) viewSize.width - kPlatformWidth)) + kPlatformWidth/2;
    platformPosition.y = minY +(random() % (maxY - minY));
    
    addedPlatform = [self addPlatformWithPosition:platformPosition];
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
  
  PIDColor *pauseCoverColor = [[PIDColor alloc] initWithRed:0.0
                                                      green:0.0
                                                       blue:0.0
                                                      alpha:0.9];
  PIDRectangleSprite *pauseCoverSprite = [[PIDRectangleSprite alloc] 
                                          initWithSize:viewSize
                                                 color:pauseCoverColor];
  pauseCover_ = [[PIDFixedEntity alloc] 
                 initWithSprite:pauseCoverSprite
                       position:CGPointMake(viewSize.width/2, 
                                            viewSize.height/2)];
  [pauseCover_ disable];
  [fixedLayer_ addChild:pauseCover_];
  [pauseCoverColor release];
  
#if SHOW_FPS
  fpsDisplay_ = [[PIDNumbersDisplay alloc]
                 initWithPosition:CGPointMake(7, 9)];
  [fixedLayer_ addChild:fpsDisplay_];
#endif
  
  // Background image is only 32 pixels wide, but we stretch it to the width of 
  // the whole screen
  PIDTextureSprite *statusBackgroundSprite = 
      [[PIDTextureSprite alloc] initWithImage:@"status.png" 
                                         size:CGSizeMake(viewSize.width, 32) 
                                       frames:1];
  statusBackground_ = [[PIDFixedEntity alloc] 
                       initWithSprite:statusBackgroundSprite
                             position:CGPointMake(viewSize.width/2, 16)];
  [fixedLayer_ addChild:statusBackground_];
  [statusBackgroundSprite release];

  // Floor display
  floorDisplay_ = [[PIDNumbersDisplay alloc] 
                   initWithPosition:CGPointMake(7, 10)];
  [fixedLayer_ addChild:floorDisplay_];  
  
  // Health display
  healthDisplay_ = [[PIDHealthDisplay alloc] 
                    initWithPosition:CGPointMake(viewSize.width - 2, 10)];
  [fixedLayer_ addChild:healthDisplay_];
  [healthDisplay_ update:player_];
  
  // Pause button
  PIDTextureSprite *pauseSprite = 
  [[PIDTextureSprite alloc] initWithImage:@"pause.png" 
                                     size:CGSizeMake(90, 16) 
                                   frames:1];
  pauseButton_ = [[PIDFixedEntity alloc] initWithSprite:pauseSprite
                                               position:CGPointMake(80, 10)];
  [fixedLayer_ addChild:pauseButton_];
  [pauseSprite release];
}

- (void)handleTick:(double)ticks {
#if SHOW_FPS
  double fps = [glView_ framesPerSecond];
  [fpsDisplay_ setValue:[NSString stringWithFormat:@"%4.1f", fps]];
#endif
  
  descentPosition_ += kDescentSpeed * ticks;
  
  int floor = descentPosition_/[glView_ size].height;
  [floorDisplay_ setValue:[NSString stringWithFormat:@"%3d", floor]];
  
  [glView_ setViewportOffsetX:0 andY:descentPosition_];
  
  [self updatePlatforms];
  
  [self updateMovementConstraints];
  
  [player_ handleTick:ticks];
  
  if ([player_ top] > [fence_ top] - descentPosition_) {
    if (![fence_ isHurtingPlayer]) {
      [fence_ startHurtingPlayer:player_];
    }
  } else if ([fence_ isHurtingPlayer]) {
    [fence_ stopHurtingPlayer];
  }
    
  [fence_ handleTick:ticks];
  
  if ([player_ landed]) {
    PIDEntity *landedEntity = [player_ hitEntityOnSide:kSideBottom];
    if ([landedEntity isKindOfClass:[PIDPlatform class]]) {
      PIDPlatform *landedPlatform = (PIDPlatform*) landedEntity;
      [landedPlatform handlePlayerLanding:player_];
    }
  }

  [healthDisplay_ update:player_];
}

- (void)updateMovementConstraints {
  [player_ resetMovementConstraints];

  // First constrain movement by viewing rect
  CGSize viewSize = [glView_ size];
  [player_ addMovementConstraint:0
                          entity:normalLayer_
                          onSide:kSideLeft];
  [player_ addMovementConstraint:-descentPosition_
                          entity:normalLayer_
                          onSide:kSideBottom];
  [player_ addMovementConstraint:viewSize.width
                          entity:normalLayer_
                          onSide:kSideRight];
  [player_ addMovementConstraint:-descentPosition_ + viewSize.height
                          entity:normalLayer_
                          onSide:kSideTop];
  
  // Then by platforms
  double playerBottom = [player_ bottom];
  double playerTop = [player_ top];
  double playerLeft = [player_ left];
  double playerRight = [player_ right];
  CGPoint playerPosition = [player_ position];
  
  for (PIDPlatform *platform in platforms_) {
    double platformBottom = [platform bottom];
    double platformTop = [platform top];
    double platformLeft = [platform left];
    double platformRight = [platform right];
    CGPoint platformPosition = [platform position];
    
    // Platforms that are in the same vertical "column" as the player constraint
    // their vertical movement (player is assumed to be narrower than platforms)
    if (platformLeft < playerLeft && platformRight > playerLeft ||
        platformLeft < playerRight && platformRight > playerRight) {

      // Player is above platform
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

    // Platforms that are in the same horizontal "column" as the player 
    // constraint their horizontal movement (player is assumed to be taller
    // than platforms)
    if (platformTop > playerTop && platformBottom < playerTop ||
        platformTop < playerTop && platformBottom > playerBottom ||
        platformTop > playerBottom && platformBottom < playerBottom) {
      
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

- (void)handleTouchBegin:(CGPoint)touchPoint {
  // Handle buttons
  if ([pauseButton_ isPointInside:touchPoint]) {
    if (isPaused_) {
      [self resume];
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

- (void)begin {
  [glView_ startAnimation];
}

- (BOOL)isPaused {
  return isPaused_;
}

- (void)pause {
  [glView_ stopAnimation];

  [pauseCover_ enable];
  [glView_ draw];

  isPaused_ = true;
}

- (void)resume {
  [glView_ startAnimation];

  [pauseCover_ disable];
  [glView_ draw];
  
  isPaused_ = false;
}

- (void)dealoc {
  [glView_ release];
  
  [player_ release];  
  [platforms_ makeObjectsPerformSelector:@selector(release)];
  [platforms_ release];

#if SHOW_FPS
  [fpsDisplay_ release];
#endif
  
  [floorDisplay_ release];
  
  [super dealloc];  
}

@end
