//
//  PIDHealthDisplay.m
//  Descent
//
//  Created by Mihai Parparita on 9/28/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDHealthDisplay.h"
#import "PIDTextureSprite.h"
#import "PIDEntityWithFrame.h"

static PIDTextureSprite *kStarsSprite;

@implementation PIDHealthDisplay

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;
  
  kStarsSprite = [[PIDTextureSprite alloc] initWithImage:@"health-stars.png"
                                                     size:CGSizeMake(16, 16)
                                                   frames:2];
}

- initWithPosition:(CGPoint)position {
  if (self = [super initWithSprite:kNullSprite position:position]) {
    [self fixPosition];
  }
  
  return self;
}

- (void)update:(PIDPlayer *)player {
  int health = [player health];
  
  if (currentValue_ == health) return;
  currentValue_ = health;
  
  [self removeAllChildren];
  
  for (int i = 0; i <= kMaxHealth; i++) {
    PIDEntity *star = [[PIDEntityWithFrame alloc] initWithSprite:kStarsSprite
                                                        position:CGPointMake((i - 8) * 16 + 8, 0)
                                                           frame:i <= health ? 0 : 1];
    [self addChild:star];
    [star release];
  }
}

- (int)currentValue {
  return currentValue_; 
}

@end
