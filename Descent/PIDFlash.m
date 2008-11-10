//
//  PIDFlash.m
//  Descent
//
//  Created by Mihai Parparita on 11/9/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFlash.h"
#import "PIDColor.h"
#import "PIDRectangleSprite.h"

#define kFlashFrameCount 20

@interface PIDFlash ()
- (void) handleTick;
@end

@implementation PIDFlash

- initWithSize:(CGSize)size {
  color_ = [[PIDColor alloc] initWithRed:0.2 green:0.0 blue:0.0 alpha:0.2];
  PIDRectangleSprite *flashSprite = 
      [[PIDRectangleSprite alloc] initWithSize:size color:color_];
  if (self = [super initWithSprite:flashSprite
                          position:CGPointMake(size.width/2, size.height/2)]) {
    triggerCounter_ = 0;
    [self disable];
    [self fixPosition];
  }
  
  return self;
}

- (void)trigger {
  if (triggerCounter_ > 0) {
    triggerCounter_ = kFlashFrameCount;
    return;
  }
  
  [self enable];
  triggerCounter_ = kFlashFrameCount;
  timer_ = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                            target:self 
                                          selector:@selector(handleTick) 
                                          userInfo:nil
                                           repeats:YES];  
}

- (BOOL)isTriggering {
  return triggerCounter_ > 0;
}

- (void)handleTick {
  triggerCounter_--;
  
  if (triggerCounter_ == 0) {
    [self disable];
    [timer_ invalidate];
    timer_ = nil;
  }
  
  [color_ setAlpha:0.2 + 0.4 * ((float)triggerCounter_)/((float)kFlashFrameCount)];
}

- (void)dealloc {
  if (timer_) {
    [timer_ invalidate];
  }
  
  [color_ release];
  [super dealloc]; 
}

@end
