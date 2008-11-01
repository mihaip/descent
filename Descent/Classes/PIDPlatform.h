//
//   PIDPlatform.h
//   Descent
//
//   Created by Mihai Parparita on 9/10/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntityWithFrame.h"
#import "PIDPlayer.h"

#define kPlatformWidth 64
#define kPlatformHeight 14

typedef enum {
  kPlatformNormal,
  kPlatformBouncy,
  kPlatformKiller,
} PIDPlatformType;


@interface PIDPlatform : PIDEntityWithFrame {
 @private
  PIDPlatformType type_;
}

- initWithPosition:(CGPoint)position;
- (void)handlePlayerLanding:(PIDPlayer *)player;

- (double)collisionTop;
- (double)collisionBottom;
- (double)collisionLeft;
- (double)collisionRight;

@end
