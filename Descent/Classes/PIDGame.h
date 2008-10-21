//
//   PIDGame.h
//   Descent
//
//   Created by Mihai Parparita on 9/10/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "EAGLView.h"
#import "PIDPlayer.h"
#import "PIDFence.h"
#import "PIDNumbersDisplay.h"
#import "PIDHealthDisplay.h"

#define SHOW_FPS 0

@interface PIDGame : NSObject < PIDEventTarget > {
 @private
  EAGLView *glView_;
  
  double descentPosition_;
  double platformGenerationTriggerPosition_;
  
  PIDEntity *normalLayer_;
  PIDEntity *fixedLayer_;
  
  // Game entities
  PIDPlayer *player_;
  NSMutableArray *platforms_;
  PIDFence *fence_;
  
  // Status
#if SHOW_FPS
  PIDNumbersDisplay *fpsDisplay_;
#endif
  PIDNumbersDisplay *floorDisplay_;
  PIDFixedEntity *statusBackground_;
  PIDHealthDisplay *healthDisplay_;
  
  // Pausing
  PIDFixedEntity *pauseCover_;
  PIDFixedEntity *pauseButton_;
  BOOL isPaused_;
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

- (void)pause;
- (void)unpause;
- (BOOL)isPaused;

@end
