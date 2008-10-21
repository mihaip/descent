//
//  PIDMenu.m
//  Descent
//
//  Created by Mihai Parparita on 10/13/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDMenu.h"
#import "PIDRectangleSprite.h"
#import "PIDColor.h"
#import "DescentAppDelegate.h"

// Private methods
@interface PIDMenu ()
- (void)initButtons;
@end

@implementation PIDMenu

- initWithView:(EAGLView *)glView {
  if (self = [super init]) {
    glView_ = [glView retain];
    
    root_ = [[PIDEntity alloc] initWithSprite:kNullSprite];
    
    [self initButtons];
   
    [glView_ setViewportOffsetX:0 andY:0];
  }
  
  return self;
}

- (void)initButtons {
  CGSize viewSize_ = [glView_ size];
  PIDColor *startColor = [[PIDColor alloc] initWithRed:0.6 green:0.6 blue:0.6];
  PIDRectangleSprite *startSprite = [[PIDRectangleSprite alloc] initWithSize:CGSizeMake(120, 40)
                                                                       color:startColor];
  
  startButton_ = [[PIDEntity alloc] initWithSprite:startSprite 
                                          position:CGPointMake(viewSize_.width/2,
                                                               viewSize_.height/2)];
  [root_ addChild:startButton_];
  
  [startColor release];
  [startSprite release];
}

- (void)handleTick:(double)ticks {
}

- (void)handleTouchBegin:(CGPoint)touchPoint {
  if ([startButton_ isPointInside:touchPoint]) {
    [GetAppInstance() switchToGame];
  }
}

- (void)handleTouchMove:(CGPoint)touchPoint {
}

- (void)handleTouchEnd:(CGPoint)touchPoint {
}

- (void)draw {
  [root_ draw];
}

- (void)suspend {
}

- (void)resume {
}

@end
