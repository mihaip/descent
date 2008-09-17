//
//  PIDPlayer.m
//  Descent
//
//  Created by Mihai Parparita on 9/13/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDPlayer.h"
#import "PIDTextureSprite.h"

#define kPlayerHorizontalSpeed 150.0 // In pixels/s
#define kPlayerVerticalAcceleration 800.0 // In pixels/s/s
#define kPlayerVerticalMaxSpeed 1200.0 // In pixels/s

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
   
   CGSize playerSize = {32, 32};
   kPlayerSprite = [[PIDTextureSprite alloc] initWithImage:@"player.png"
                                                                               size:playerSize
                                                                            frames:8];
   [kPlayerSprite setFrame:3];
}

- initWithPosition:(CGPoint)position {
   if (self = [super initWithSprite:kPlayerSprite position:position]) {
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
   if (walkingFrameCounter_ == 3) {
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
         [kPlayerSprite setFrame:walkingFrameCounter_];
      } else {
         [kPlayerSprite setFrame:4 + walkingFrameCounter_];
      }
   } else {
      [kPlayerSprite setFrame:3];
   }
   
   // Move player vertically
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
   if (position_.y == newPosition.y) {
      verticalSpeed_ = 0;
   }
      
   position_ = newPosition;
}

- (void)addMovementConstraint:(double)value onSide:(PIDSide)side {
   switch (side) {
      case kSideLeft: if (value > minX_) minX_ = value; break;
      case kSideRight: if (value < maxX_) maxX_ = value; break;
      case kSideTop: if (value < maxY_) maxY_ = value; break;
      case kSideBottom: if (value > minY_) minY_ = value; break;
   }
}

- (void)resetMovementConstraints {
   minX_ = -DBL_MAX;
   maxX_ = DBL_MAX;
   minY_ = -DBL_MAX;
   maxY_ = DBL_MAX;
}

- (void)dealloc {
   [walkingFrameTimer_ invalidate];
   [super dealloc];
}

@end
