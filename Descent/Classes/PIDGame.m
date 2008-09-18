//
//   PIDGame.m
//   Descent
//
//   Created by Mihai Parparita on 9/10/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDGame.h"
#import "PIDRectangleSprite.h"
#import "PIDPlatform.h"

#define kDescentSpeed 50 // In pixels/s

// Private methods
@interface PIDGame ()
- (void)initPlayer;
- (void)initPlatforms;
- (void)addPlatformWithPosition:(CGPoint)platformPosition;
- (void)addPlatformWithRandomPositionBetween:(int)minY and:(int)maxY;
@end

@implementation PIDGame

- initWithView:(EAGLView *)glView {
  if (self = [super init]) {
    glView_ = [glView retain];
    [glView_ setEventTarget:self];
    
    // For now use a fixed seed so that repeated runs are reproducible
    srandom(26);
    
    descentPosition_ = 0;
    platformGenerationTriggerPosition_ = 0;
    
    [self initPlayer];
    [self initPlatforms];
    
    glView_.animationInterval = 1.0 / 60.0;
  }
  
  return self;
}

- (void)initPlayer {
  CGSize viewSize = [glView_ size];
  // Center player in view
  CGPoint playerPosition = {viewSize.width / 2, viewSize.height};
  player_ = [[PIDPlayer alloc] initWithPosition:playerPosition];
  
  [[glView_ root] addChild:player_];
}

- (void)initPlatforms {
  CGSize viewSize = [glView_ size];
  platforms_ = [[NSMutableArray alloc] initWithCapacity:10];
  for (int i = 0; i < 7; i++) {
    // Always start with a platform underneath the player (who is in the 
    // center)
    if (i == 0) {
      CGPoint platformPosition;
      platformPosition.x = viewSize.width / 2;
      platformPosition.y = viewSize.height / 2 - 40;
      [self addPlatformWithPosition:platformPosition];
    } else {
      [self addPlatformWithRandomPositionBetween:0 and:viewSize.height];
    }    
  }
}

- (void)addPlatformWithPosition:(CGPoint)platformPosition {
  PIDPlatform* platform = [[PIDPlatform alloc] 
                           initWithPosition:platformPosition];
  
  [[glView_ root] addChild:platform];
  
  [platforms_ addObject:platform];
  
  [platform release];
}

- (void)addPlatformWithRandomPositionBetween:(int)minY and:(int)maxY {
  CGSize viewSize = [glView_ size];
  CGPoint platformPosition;
  
  // TODO(mihaip): take into account collisions with other platforms and minium
  // spacing
  platformPosition.x = 
      (random() % ((int) viewSize.width - kPlatformWidth)) + kPlatformWidth/2;
  platformPosition.y = minY +(random() % (maxY - minY));
  
  [self addPlatformWithPosition:platformPosition];
}

- (void)handleTick:(double)ticks {
  CGSize viewSize = [glView_ size];

  descentPosition_ += kDescentSpeed * ticks;
  if (descentPosition_ > platformGenerationTriggerPosition_) {
    platformGenerationTriggerPosition_ = descentPosition_ + 55 + (random() % 20);
    
    [self addPlatformWithRandomPositionBetween:-platformGenerationTriggerPosition_
                                           and:-descentPosition_];

    // Also check if any platforms scrolled off the top and so can be removed
    NSMutableArray *platformsToRemove = [NSMutableArray arrayWithCapacity:1];
    for (PIDPlatform *platform in platforms_) {
      if ([platform bounds].origin.y > -descentPosition_ + viewSize.height) {
        [platformsToRemove addObject:platform];
      }
    }
    for (PIDPlatform *platform in platformsToRemove) {
      [[glView_ root] removeChild:platform];
      [platforms_ removeObject:platform];
    }
  }
  [glView_ setViewportOffsetX:0 andY:descentPosition_];
  
  [player_ resetMovementConstraints];

  // First constrain movement by viewing rect
  [player_ addMovementConstraint:0
                          onSide:kSideLeft];
  [player_ addMovementConstraint:-descentPosition_
                          onSide:kSideBottom];
  [player_ addMovementConstraint:viewSize.width
                          onSide:kSideRight];
  [player_ addMovementConstraint:-descentPosition_ + viewSize.height
                          onSide:kSideTop];
  
  // Then by platforms
  CGRect playerBounds = [player_ bounds];
  double playerBottom = CGRectGetMinY(playerBounds);
  double playerTop = CGRectGetMaxY(playerBounds);
  double playerLeft = CGRectGetMinX(playerBounds);
  double playerRight = CGRectGetMaxX(playerBounds);
  CGPoint playerPosition = [player_ position];
  
  for (PIDPlatform *platform in platforms_) {
    CGRect platformBounds = [platform bounds];
    double platformBottom = CGRectGetMinY(platformBounds);
    double platformTop = CGRectGetMaxY(platformBounds);
    double platformLeft = CGRectGetMinX(platformBounds);
    double platformRight = CGRectGetMaxX(platformBounds);
    CGPoint platformPosition = [platform position];
    
    // Platforms that are in the same vertical "column" as the player constraint
    // their vertical movement (player is assumed to be narrower than platforms)
    if (platformLeft < playerLeft && platformRight > playerLeft ||
        platformLeft < playerRight && platformRight > playerRight) {

      // Player is above platform
      if (playerPosition.y > platformPosition.y) {
        [player_ addMovementConstraint:platformTop onSide:kSideBottom];
      } else { // Player is below platform
        [player_ addMovementConstraint:platformBottom onSide:kSideTop];
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
        [player_ addMovementConstraint:platformLeft onSide:kSideRight];
      } else { // Player is to the right of the platform
        [player_ addMovementConstraint:platformRight onSide:kSideLeft];
      }
    }
  }
  
  [player_ handleTick:ticks]; 
}

- (void)handleTouchBegin:(CGPoint)touchPoint {
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

- (void)begin {
  [glView_ startAnimation];
}

- (void)pause {
  glView_.animationInterval = 1.0 / 5.0;
  
}
- (void)resume {
  glView_.animationInterval = 1.0 / 60.0;
}

- (void)dealoc {
  [glView_ release];
  [player_ release];
  [platforms_ makeObjectsPerformSelector:@selector(release)];
  [platforms_ release];
}

@end
