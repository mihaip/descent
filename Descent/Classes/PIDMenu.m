//
//  PIDMenu.m
//  Descent
//
//  Created by Mihai Parparita on 10/13/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDMenu.h"
#import "PIDRectangleSprite.h"
#import "PIDTextureSprite.h"
#import "PIDColor.h"
#import "PIDEntityWithFrame.h"
#import "DescentAppDelegate.h"

// Private methods
@interface PIDMenu ()
- (void)initButtons;
@end

@implementation PIDMenu

static PIDTextureSprite *kDifficultyButtonsSprite;
static PIDTextureSprite *kDifficultyDisplaySprite;

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;
  
  kDifficultyButtonsSprite = 
      [[PIDTextureSprite alloc] initWithImage:@"difficulty-buttons.png"
                                         size:CGSizeMake(25, 39)
                                       frames:2];
  kDifficultyDisplaySprite = 
      [[PIDTextureSprite alloc] initWithImage:@"difficulty-display.png"
                                         size:CGSizeMake(64, 17)
                                       frames:3];  
}

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
                                                               viewSize_.height/2 - 60)];
  [root_ addChild:startButton_];

  difficultyDisplay_ = [[PIDEntity alloc] 
                            initWithSprite:kDifficultyDisplaySprite
                            position:CGPointMake(viewSize_.width/2, 
                                                 viewSize_.height/2)];
  [kDifficultyDisplaySprite setFrame:[GetAppInstance() difficulty]];
  
  lowerDifficultyButton_ = [[PIDEntityWithFrame alloc] 
                            initWithSprite:kDifficultyButtonsSprite
                            position:CGPointMake(viewSize_.width/2 - 60 - 20, 
                                                 viewSize_.height/2)
                            frame:0];
  raiseDifficultyButton_ = [[PIDEntityWithFrame alloc] 
                            initWithSprite:kDifficultyButtonsSprite
                            position:CGPointMake(viewSize_.width/2 + 60 + 20, 
                                                 viewSize_.height/2)
                            frame:1];
  [root_ addChild:difficultyDisplay_];  
  [root_ addChild:lowerDifficultyButton_];
  [root_ addChild:raiseDifficultyButton_];
  
  [startColor release];
  [startSprite release];
}

- (void)handleTick:(double)ticks {
}

- (void)handleTouchBegin:(CGPoint)touchPoint {
  if ([startButton_ isPointInside:touchPoint]) {
    [GetAppInstance() switchToGame];
  } else if ([lowerDifficultyButton_ isPointInside:touchPoint]) {
    [GetAppInstance() lowerDifficulty];
    [kDifficultyDisplaySprite setFrame:[GetAppInstance() difficulty]];
  } else if ([raiseDifficultyButton_ isPointInside:touchPoint]) {
    [GetAppInstance() raiseDifficulty];
    [kDifficultyDisplaySprite setFrame:[GetAppInstance() difficulty]];
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

- (void)dealloc {
  [glView_ release];
  
  [startButton_ release];
  [difficultyDisplay_ release];
  [lowerDifficultyButton_ release];
  [raiseDifficultyButton_ release];
  [root_ release];
  
  [super dealloc];  
}


@end
