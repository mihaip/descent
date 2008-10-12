//
//   PIDPlatform.h
//   Descent
//
//   Created by Mihai Parparita on 9/10/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"
#import "PIDPlayer.h"

#define kPlatformWidth 60
#define kPlatformHeight 10

typedef enum {
  kPlatformNormal,
  kPlatformBouncy,
  kPlatformKiller,
} PIDPlatformType;


@interface PIDPlatform : PIDEntity {
 @private
  PIDPlatformType type_;
}

- initWithPosition:(CGPoint)position;
- (void)handlePlayerLanding:(PIDPlayer *)player;

@end
