//
//  PIDPlayer.h
//  Descent
//
//  Created by Mihai Parparita on 9/13/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"
#import "PIDPlatform.h"

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
   PIDPlayerHorizontalDirection horizontalDirection_;
   double verticalSpeed_;
   double minX_, maxX_, minY_, maxY_;
   NSTimer* walkingFrameTimer_;
   int walkingFrameCounter_;
}

- initWithPosition:(CGPoint)position;
- (void)setHorizontalDirection:(PIDPlayerHorizontalDirection)direction;

- (void)addMovementConstraint:(double)value onSide:(PIDSide)side;
- (void)resetMovementConstraints;

@end
