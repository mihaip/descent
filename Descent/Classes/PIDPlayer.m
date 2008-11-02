//
//   PIDPlayer.m
//   Descent
//
//   Created by Mihai Parparita on 9/13/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDPlayer.h"
#import "PIDTextureSprite.h"

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

- initWithPosition:(CGPoint)position {
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
  CGPoint newPosition = position_;

  // Move player horizontally, and update walking animation
  if (horizontalDirection_ != kNone) {
    newPosition.x += horizontalDirection_ * kPlayerHorizontalSpeed * ticks;
    
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
  newPosition.y -= verticalSpeed_ * ticks;
  
  // Constraint movement
  CGSize size = [sprite_ size];
  double left = newPosition.x - size.width/2;
  double right = left + size.width;
  double top = newPosition.y + size.height/2;
  double bottom = top - size.height;
  if (left < minX_) {newPosition.x = minX_ + size.width/2;}
  if (right > maxX_) {newPosition.x = maxX_ - size.width/2;}
  if (bottom < minY_) {newPosition.y = minY_ + size.height/2;}
  if (top > maxY_) {newPosition.y = maxY_ - size.height/2;}

  // If we've been stopped, then reset our speed back to 0
  landed_ = NO;
  if (position_.y == newPosition.y) {
    if (previousSpeed != 0 && previousSpeed > 0) {
      landed_ = YES;
    }
    verticalSpeed_ = 0;
  }
    
  position_ = newPosition;
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
  [super dealloc];
}

@end
