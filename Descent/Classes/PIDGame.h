//
//   PIDGame.h
//   Descent
//
//   Created by Mihai Parparita on 9/10/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "PIDPlayer.h"
#import "PIDNumbersDisplay.h"

#define SHOW_FPS 0

@interface PIDGame : NSObject < PIDEventTarget > {
 @private
  EAGLView *glView_;
  
  double descentPosition_;
  double platformGenerationTriggerPosition_;
  
  // Game entities
  PIDPlayer *player_;
  NSMutableArray *platforms_;
#if SHOW_FPS
  PIDNumbersDisplay* fpsDisplay_;
#endif
}

- initWithView:(EAGLView *)glView;

// PIDEeventTarget protocol implementation
- (void)handleTick:(double)ticks;
- (void)handleTouchBegin:(CGPoint)touchPoint;
- (void)handleTouchMove:(CGPoint)touchPoint;
- (void)handleTouchEnd:(CGPoint)touchPoint;

- (void)begin;
- (void)pause;
- (void)resume;

@end
