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
#import "PIDTrail.h"
#import "PIDTextureSprite.h"
#import "PIDFlash.h"
#import "PIDPlatform.h"

#define SHOW_FPS 0

typedef enum {
  kEasy,
  kMedium,
  kHard
} PIDGameDifficulty;

@interface PIDGame : NSObject < PIDEventTarget > {
 @private
  EAGLView *glView_;
  
  PIDGameDifficulty difficulty_;
  double descentPosition_;
  double platformGenerationTriggerPosition_;
  
  PIDEntity *normalLayer_;
  PIDEntity *fixedLayer_;
  
  // Background entities
  PIDEntity *background_;
  
  // Game entities
  PIDPlayer *player_;
  NSMutableArray *platforms_;
  PIDPlatform *lastLandedPlatform_;
  PIDFence *fence_;
  PIDTrail *trail_;
  
  // Status
#if SHOW_FPS
  PIDNumbersDisplay *fpsDisplay_;
#endif
  PIDHealthDisplay *healthDisplay_;
  PIDFlash *flash_;
  
  // Floor display
  PIDNumbersDisplay *currentFloorDisplay_;
  PIDNumbersDisplay *nextFloorDisplay_;
  
  // Pausing
  PIDEntity *pauseCover_;
  PIDTextureSprite *pauseButtonSprite_;
  PIDEntity *pauseButton_;
  BOOL isPaused_;
}

- initWithView:(EAGLView *)glView difficulty:(PIDGameDifficulty)difficulty;

// PIDEeventTarget protocol implementation
- (void)handleTick:(double)ticks;
- (void)handleTouchBegin:(CGPoint)touchPoint;
- (void)handleTouchMove:(CGPoint)touchPoint;
- (void)handleTouchEnd:(CGPoint)touchPoint;
- (void)draw;
- (void)suspend;
- (void)resume;

- (void)updateMovementConstraints;

- (void)pause;
- (void)unpause;
- (BOOL)isPaused;

@end
