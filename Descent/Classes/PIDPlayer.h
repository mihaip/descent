//
//   PIDPlayer.h
//   Descent
//
//   Created by Mihai Parparita on 9/13/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"

#define kMaxHealth 7

typedef enum {
  kLeft = -1,
  kNone = 0,
  kRight = 1,
} PIDPlayerHorizontalDirection;

typedef enum  {
  kSideTop,
  kSideRight,
  kSideBottom,
  kSideLeft,
} PIDSide;

@interface PIDPlayer : PIDEntity {
 @private
  int health_;
  BOOL landed_;
  
  // Movement
  PIDPlayerHorizontalDirection horizontalDirection_;
  double verticalSpeed_;
  
  // Constraints
  double minX_, maxX_, minY_, maxY_;
  PIDEntity *minXEntity_, *maxXEntity_, *minYEntity_, *maxYEntity_;
  
  // Animation
  NSTimer* walkingFrameTimer_;
  int walkingFrameCounter_;
}

- initWithPosition:(CGPoint)position;
- (void)setHorizontalDirection:(PIDPlayerHorizontalDirection)direction;

- (void)addMovementConstraint:(double)value 
                       entity:(PIDEntity *)entity 
                       onSide:(PIDSide)side;
- (void)resetMovementConstraints;
- (PIDEntity *)hitEntityOnSide:(PIDSide)side;

- (int)health;
- (void)increaseHealth;
- (void)decreaseHealth;

- (void)bounce;

- (BOOL)landed;

@end
