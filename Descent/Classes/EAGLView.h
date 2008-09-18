//
//   EAGLView.h
//   Descent
//
//   Created by Mihai Parparita on 9/7/08.
//   Copyright persistent.info 2008. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>

#import "PIDEntity.h"

@protocol PIDEventTarget
- (void)handleTick:(double)ticks;
- (void)handleTouchBegin:(CGPoint)touchPoint;
- (void)handleTouchMove:(CGPoint)touchPoint;
- (void)handleTouchEnd:(CGPoint)touchPoint;
@end

/*
This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
The view content is basically an EAGL surface you render your OpenGL scene into.
Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
*/
@interface EAGLView : UIView {
  
 @private
  /* The pixel dimensions of the backbuffer */
  GLint backingWidth;
  GLint backingHeight;
  
  EAGLContext *context;
  
  /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
  GLuint viewRenderbuffer, viewFramebuffer;
  
  /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
  GLuint depthRenderbuffer;
  
  NSTimer *animationTimer;
  NSTimeInterval animationInterval;
  NSTimeInterval lastTickDate_;
  double framesPerSecond_;
  
  int viewportOffsetX_, viewportOffsetY_;
  
  PIDEntity *root_;
  id <PIDEventTarget> eventTarget_;
}

@property NSTimeInterval animationInterval;

- (void)startAnimation;
- (void)stopAnimation;

- (void)setViewportOffsetX:(int)viewportOffsetX andY:(int)viewportOffsetY;

- (PIDEntity *)root;
- (CGSize)size;
- (double)framesPerSecond;
- (void)setEventTarget:(id <PIDEventTarget>)eventTarget;

@end
