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
- (void)refreshHighScores;
@end

@implementation PIDMenu

static PIDTextureSprite *kDifficultyButtonsSprite;
static PIDColor *kLastHighScoreColor;
static PIDColor *kNormalHighScoreColor;
static NSString *kDifficultyNames[] = {
  @"easy",
  @"medium",
  @"hard"
};

#define kBackgroundTileSize 256

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;
  
  kDifficultyButtonsSprite = 
      [[PIDTextureSprite alloc] initWithImage:@"difficulty-buttons.png"
                                         size:CGSizeMake(25, 39)
                                       frames:2];

  kLastHighScoreColor = [[PIDColor alloc] initWithRed:1.0 green:1.0 blue:0.0];
  kNormalHighScoreColor = [[PIDColor alloc] initWithRed:1.0 green:1.0 blue:1.0];
}

- initWithView:(EAGLView *)glView {
  if (self = [super init]) {
    glView_ = [glView retain];
    
    root_ = [[PIDEntity alloc] initWithSprite:kNullSprite];
    
    [self initButtons];
    [self refreshHighScores];
   
    [glView_ setViewportOffsetX:0 andY:0];
  }
  
  return self;
}

- (void)initButtons {
  CGSize viewSize = [glView_ size];

  // Background texture is 256 x 256, we want to tile it
  PIDTextureSprite *backgroundSprite = 
  [[PIDTextureSprite alloc] initWithImage:@"paper.png" 
                                     size:CGSizeMake(kBackgroundTileSize * 2, 
                                                     kBackgroundTileSize * 3)
                                   frames:1];
  background_ = 
      [[PIDEntity alloc] initWithSprite:backgroundSprite 
                               position:CGPointMake(viewSize.width/2, 
                                                    viewSize.height/2)];
  [backgroundSprite release];
  [root_ addChild:background_];
  
  int startWidth = (kLetterWidth - 3) * 5;
  startButton_ = [[PIDTextDisplay alloc] initWithPosition:CGPointMake(viewSize.width/2 - startWidth/2,
                                                               viewSize.height/2 + 60)];
  [startButton_ setKerningAdjustment:-3];
  [startButton_ setValue:@"start"];
  
  [root_ addChild:startButton_];

  difficultyDisplay_ = [[PIDTextDisplay alloc] 
                            initWithPosition:CGPointMake(viewSize.width/2 - 55, 
                                                 viewSize.height/2)];
  [difficultyDisplay_ setKerningAdjustment:-2];
  [difficultyDisplay_ setValue:kDifficultyNames[[GetAppInstance() difficulty]]];
  
  lowerDifficultyButton_ = [[PIDEntityWithFrame alloc] 
                            initWithSprite:kDifficultyButtonsSprite
                            position:CGPointMake(viewSize.width/2 - 60 - 20, 
                                                 viewSize.height/2)
                            frame:0];
  raiseDifficultyButton_ = [[PIDEntityWithFrame alloc] 
                            initWithSprite:kDifficultyButtonsSprite
                            position:CGPointMake(viewSize.width/2 + 60 + 20, 
                                                 viewSize.height/2)
                            frame:1];
  [root_ addChild:difficultyDisplay_];  
  [root_ addChild:lowerDifficultyButton_];
  [root_ addChild:raiseDifficultyButton_];
  
  highScoreRoot_ = [[PIDEntity alloc] initWithSprite:kNullSprite 
                                            position:CGPointMake(0, viewSize.height/2 - 60)];
  [root_ addChild:highScoreRoot_];
}

- (void)refreshHighScores {
  CGSize viewSize = [glView_ size];

  [highScoreRoot_ removeAllChildren];
  
  NSArray *highScores = [GetAppInstance() highScores];
  int lastHighScoreIndex = [GetAppInstance() lastHighScoreIndex];

  int i = 0;
  
  int scoreX = viewSize.width/2 - 11 * kLetterWidth/2;
  int scoreHeight = kLetterHeight + 5;
  
  for (NSNumber *score in highScores) {
    PIDTextDisplay *scoreDisplay = [[PIDTextDisplay alloc] 
      initWithPosition:CGPointMake(scoreX, 200 - i * scoreHeight)
                 color:i == lastHighScoreIndex 
                                       ? kLastHighScoreColor 
                                       : kNormalHighScoreColor];
    [scoreDisplay setValue:
        [NSString stringWithFormat:@"%d. %8d", ++i, [score intValue]]];
    [highScoreRoot_ addChild:scoreDisplay];
  }
}

- (void)handleTick:(double)ticks {
}

- (void)handleTouchBegin:(CGPoint)touchPoint {
  if ([startButton_ isPointInside:touchPoint]) {
    [GetAppInstance() switchToGame];
  } else if ([lowerDifficultyButton_ isPointInside:touchPoint]) {
    [GetAppInstance() lowerDifficulty];
    [difficultyDisplay_ setValue:kDifficultyNames[[GetAppInstance() difficulty]]];
    [self refreshHighScores];
  } else if ([raiseDifficultyButton_ isPointInside:touchPoint]) {
    [GetAppInstance() raiseDifficulty];
    [difficultyDisplay_ setValue:kDifficultyNames[[GetAppInstance() difficulty]]];
    [self refreshHighScores];
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
  
  [background_ release];
  [startButton_ release];
  [difficultyDisplay_ release];
  [lowerDifficultyButton_ release];
  [raiseDifficultyButton_ release];
  [root_ release];
  
  [super dealloc];  
}


@end
