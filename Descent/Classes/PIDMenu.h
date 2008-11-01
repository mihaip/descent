//
//  PIDMenu.h
//  Descent
//
//  Created by Mihai Parparita on 10/13/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "EAGLView.h"
#import "PIDEntity.h"

@interface PIDMenu : NSObject < PIDEventTarget > {
 @private
  EAGLView *glView_;
  PIDEntity *root_;
  PIDEntity *startButton_;
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
