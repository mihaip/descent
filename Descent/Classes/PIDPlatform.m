//
//   PIDPlatform.m
//   Descent
//
//   Created by Mihai Parparita on 9/10/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDPlatform.h"
#import "PIDTextureSprite.h"
#import "PIDColor.h"

static PIDTextureSprite *kPlatformSprite;

@implementation PIDPlatform

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;

  kPlatformSprite = 
      [[PIDTextureSprite alloc] initWithImage:@"platform.png"
                                         size:CGSizeMake(kPlatformWidth, 
                                                         kPlatformHeight)
                                       frames:5];
}

- initWithPosition:(CGPoint)position type:(PIDPlatformType)type {
  if (self = [super initWithSprite:kPlatformSprite 
                          position:position 
                             frame:type]) {
    type_ = type;
  }
  
  return self;
}

- (void)handlePlayerLanding:(PIDPlayer *)player {
  switch (type_) {
    case kPlatformKiller:
      [player decreaseHealth];
      break;
    case kPlatformBouncy:
      [player increaseHealth];
      [player bounce];
      break;
    case kPlatformMoverLeft:
      [player increaseHealth];
      [player beginPushLeft];
      break;
    case kPlatformMoverRight:
      [player increaseHealth];
      [player beginPushRight];
      break;      
    case kPlatformNormal:
      [player increaseHealth];
      break;
  }
}

- (void)handlePlayerLeaving:(PIDPlayer *)player {
  switch (type_) {
    case kPlatformMoverLeft:
    case kPlatformMoverRight:
      [player resetPush];
      break;
  }
}

- (double)collisionTop {
  return [self top] - 2;
}

- (double)collisionBottom {
  return [self bottom] + 3;
}

- (double)collisionLeft {
  return [self left] + 2;
}

- (double)collisionRight {
  return [self right] - 4;
}

- (CGRect)collisionBounds {
  return CGRectMake([self collisionLeft], 
                    [self collisionBottom],
                    [self collisionRight] - [self collisionLeft],
                    [self collisionTop] - [self collisionBottom]);
}

@end
