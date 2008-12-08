//
//  PIDMenu.h
//  Descent
//
//  Created by Mihai Parparita on 10/13/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "EAGLView.h"
#import "PIDEntity.h"
#import "PIDTextDisplay.h"

@interface PIDMenu : NSObject < PIDEventTarget > {
 @private
  EAGLView *glView_;
  PIDEntity *root_;
  PIDEntity *background_;
  PIDTextDisplay *startButton_;
  PIDTextDisplay *difficultyDisplay_;
  PIDEntity *lowerDifficultyButton_;
  PIDEntity *raiseDifficultyButton_;
  PIDEntity *highScoreRoot_;
}

- initWithView:(EAGLView *)glView;

// PIDEeventTarget protocol implementation
- (void)handleTick:(double)ticks;
- (void)handleTouchBegin:(CGPoint)touchPoint;
- (void)handleTouchMove:(CGPoint)touchPoint;
- (void)handleTouchEnd:(CGPoint)touchPoint;
- (void)draw;
- (void)suspend;
- (void)resume;

@end
