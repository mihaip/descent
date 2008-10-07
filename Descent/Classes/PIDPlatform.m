//
//   PIDPlatform.m
//   Descent
//
//   Created by Mihai Parparita on 9/10/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDPlatform.h"
#import "PIDRectangleSprite.h"
#import "PIDColor.h"

static PIDRectangleSprite *kPlatformNormalSprite;
static PIDRectangleSprite *kPlatformBouncySprite;

@implementation PIDPlatform

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;

  CGSize platformSize = {kPlatformWidth, kPlatformHeight};
  PIDColor *normalColor = [[PIDColor alloc] initWithRed:0.2 
                                                  green:0.8 
                                                   blue:0.2];
  kPlatformNormalSprite = [[PIDRectangleSprite alloc] initWithSize:platformSize
                                                             color:normalColor];

  PIDColor *bouncyColor = [[PIDColor alloc] initWithRed:0.8 
                                                  green:0.8 
                                                   blue:0.2];
  kPlatformBouncySprite = [[PIDRectangleSprite alloc] initWithSize:platformSize
                                                             color:bouncyColor];
  
  
  [normalColor release];
  [bouncyColor release];
}

- initWithPosition:(CGPoint)position {
  int typeChooser = random() % 10;
  PIDPlatformType type;
  PIDSprite *sprite;
  switch (typeChooser) {
    case 0: 
    case 1: 
      type = kPlatformBouncy; 
      sprite = kPlatformBouncySprite;
      break;
    default:
      type = kPlatformNormal; 
      sprite = kPlatformNormalSprite;
      break;
  }
  
  if (self = [super initWithSprite:sprite position:position]) {
    type_ = type;
  }
  
  return self;
}

- (void)handlePlayerLanding:(PIDPlayer *)player {
  switch (type_) {
    case kPlatformBouncy:
      [player increaseHealth];
      [player bounce];
      break;
    case kPlatformNormal:
      [player increaseHealth];
      break;
  }
}


@end
