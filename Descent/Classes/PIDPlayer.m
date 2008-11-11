//
//   PIDPlayer.m
//   Descent
//
//   Created by Mihai Parparita on 9/13/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDPlayer.h"
#import "PIDTextureSprite.h"
#import "PIDGame.h"

#define kPlayerHorizontalSpeed 150.0 // In pixels/s
#define kPlayerVerticalAcceleration 800.0 // In pixels/s/s
#define kPlayerVerticalMaxSpeed 1200.0 // In pixels/s
#define kPlayerBounce 300.0 // In pixels/s

#define kPlayerWalkingFrameCount 3
#define kPlayerWalkingFrameLeftStart 0
#define kPlayerWalkingFrameRightStart 4
#define kPlayerNormalFrame 3
#define kPlayerTotalFrameCount 8

static PIDTextureSprite *kPlayerSprite;

// Private methods
@interface PIDPlayer ()
- (void)updateWalkingFrame;
- (int)constrainNewPosition;
@end

@implementation PIDPlayer

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;
  
  kPlayerSprite = [[PIDTextureSprite alloc] initWithImage:@"player.png"
                                                     size:CGSizeMake(32, 32)
                                                   frames:kPlayerTotalFrameCount];
  [kPlayerSprite setFrame:kPlayerNormalFrame];
}

- initWithPosition:(CGPoint)position game:(PIDGame *)game {
  if (self = [super initWithSprite:kPlayerSprite position:position]) {
    health_ = kMaxHealth;
    
    horizontalDirection_ = kNone;
    verticalSpeed_ = 0.0;
    [self resetMovementConstraints];
    
    walkingFrameCounter_ = 0;
    walkingFrameTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.08
                                                          target:self 
                                                        selector:@selector(updateWalkingFrame) 
                                                        userInfo:nil 
                                                         repeats:YES];
    game_ = [game retain];
  }
  
  return self;
}

- (void)updateWalkingFrame {
  walkingFrameCounter_++;
  if (walkingFrameCounter_ == kPlayerWalkingFrameCount) {
    walkingFrameCounter_ = 0;
  }
}

- (void)setHorizontalDirection:(PIDPlayerHorizontalDirection)direction {
  horizontalDirection_ = direction;   
}

- (void)handleTick:(double)ticks {
  // Move player horizontally, and update walking animation
  if (horizontalDirection_ != kNone) {
    position_.x += horizontalDirection_ * kPlayerHorizontalSpeed * ticks;
    
    if (horizontalDirection_ == kLeft) {
      [kPlayerSprite setFrame:kPlayerWalkingFrameLeftStart + walkingFrameCounter_];
    } else {
      [kPlayerSprite setFrame:kPlayerWalkingFrameRightStart + walkingFrameCounter_];
    }
  } else {
    [kPlayerSprite setFrame:kPlayerNormalFrame];
  }
  
  // Move player vertically
  double previousSpeed = verticalSpeed_;
  verticalSpeed_ += kPlayerVerticalAcceleration * ticks;
  if (verticalSpeed_ > kPlayerVerticalMaxSpeed) {
    verticalSpeed_ = kPlayerVerticalMaxSpeed;
  }
  position_.y -= verticalSpeed_ * ticks;

  int constrainedSides = [self constrainNewPosition];

  // If we've been stopped, then reset our speed back to 0. "Landing" is 
  // triggered the first time we stop on the way down.
  landed_ = NO;
  if (constrainedSides & kSideBottom) {
    if (previousSpeed > 0) {
      landed_ = YES;
    }
    verticalSpeed_ = 0;
  }
  if (constrainedSides & kSideTop && previousSpeed < 0) {
    verticalSpeed_ = 0;
  }
}

- (int)constrainNewPosition {
  CGSize size = [sprite_ size];
  BOOL moved;
  // Keep track of which sides we've been constrained on, so that we don't 
  // bounce back and forth between the two opposing side when the player tries
  // to squeeze into a shorter area than their height
  int constrainedSides = 0;

  do {
    moved = NO;
    
    [game_ updateMovementConstraints];
    
    if (!(constrainedSides & kSideLeft) && [self left] < minX_) {
      position_.x = minX_ + size.width/2;
      moved = YES;
      constrainedSides |= kSideLeft;
      continue;
    }
    if (!(constrainedSides & kSideRight) && [self right] > maxX_) {
      position_.x = maxX_ - size.width/2;
      moved = YES;
      constrainedSides |= kSideRight;
      continue;
    }
    if (!(constrainedSides & kSideBottom) && [self bottom] < minY_) {
      position_.y = minY_ + size.height/2;
      moved = YES;
      constrainedSides |= kSideBottom;
      continue;
    }
    if (!(constrainedSides & kSideTop) && [self top] > maxY_) {
      position_.y = maxY_ - size.height/2;
      moved = YES;
      constrainedSides |= kSideTop;
      continue;
    }
  } while (moved == YES);
  
  return constrainedSides;
}

- (void)addMovementConstraint:(double)value 
                       entity:(PIDEntity *)entity 
                       onSide:(PIDSide)side {
  switch (side) {
    case kSideLeft: 
      if (value > minX_) {
        minX_ = value; 
        if (minXEntity_) [minXEntity_ release];
        minXEntity_ = [entity retain];
      }
      break;
    case kSideRight: 
      if (value < maxX_) {
        maxX_ = value;
        if (maxXEntity_) [maxXEntity_ release];
        maxXEntity_ = [entity retain];
      }
      break;
    case kSideTop: 
      if (value < maxY_) {
        maxY_ = value; 
        if (maxYEntity_) [maxYEntity_ release];
        maxYEntity_ = [entity retain];
      }
      break;
    case kSideBottom:
      if (value > minY_) {
        minY_ = value;
        if (minYEntity_) [minYEntity_ release];
        minYEntity_ = [entity retain];
      }
      break;
  }
}

- (PIDEntity *)hitEntityOnSide:(PIDSide)side {
  switch (side) {
    case kSideTop: return maxYEntity_;
    case kSideRight: return maxXEntity_;
    case kSideBottom: return minYEntity_;
    case kSideLeft: return minXEntity_;
  }
  
  return NULL;
}


- (void)resetMovementConstraints {
  minX_ = -DBL_MAX;
  if (minXEntity_) [minXEntity_ release];
  minXEntity_ = NULL;

  maxX_ = DBL_MAX;
  if (maxXEntity_) [maxXEntity_ release];
  maxXEntity_ = NULL;
  
  minY_ = -DBL_MAX;
  if (minYEntity_) [minYEntity_ release];
  minYEntity_ = NULL;

  maxY_ = DBL_MAX;
  if (maxYEntity_) [maxYEntity_ release];
  maxYEntity_ = NULL;
}

- (int)health {
  return health_;
}

- (void)increaseHealth {
  if (health_ < kMaxHealth) {
    health_++;
  }
}

- (void)decreaseHealth {
  if (health_ >= 0) {
    health_--;
  }
}

- (BOOL)isDead {
  return health_ < 0; 
}

- (BOOL)landed {
  return landed_;
}

- (void)bounce {
  verticalSpeed_ -= kPlayerBounce;
}

- (void)dealloc {
  [walkingFrameTimer_ invalidate];
  [self resetMovementConstraints];
  [game_ release];
  [super dealloc];
}

@end
