//
//   EAGLView.m
//   Descent
//
//   Created by Mihai Parparita on 9/7/08.
//   Copyright persistent.info 2008. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "PIDEntity.h"
#import "PIDRectangleSprite.h"

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

- (void)handleTick;
- (CGPoint)getTouchPoint:(NSSet *)touches;

@end

@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;


// You must implement this
+ (Class)layerClass {
  return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {

  if ((self = [super initWithCoder:coder])) {
    // Get the layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat,
                                    nil];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!context || ![EAGLContext setCurrentContext:context]) {
      [self release];
      return nil;
    }
    
    animationInterval = 1.0 / 60.0;
    framesPerSecond_ = 0.0;

    root_ = [[PIDEntity alloc] initWithSprite:[PIDSprite new]];       
  }
  return self;
}

- (void)handleTick {
  NSTimeInterval tickDate = [NSDate timeIntervalSinceReferenceDate];
  NSTimeInterval tickInterval = tickDate - lastTickDate_;
  
  double currentFramesPerSecond = 1.0 / tickInterval;
  if (framesPerSecond_ == 0.0) {
    framesPerSecond_ = currentFramesPerSecond;
  } else {
    // Basic smoothing of FPS measurement
    framesPerSecond_ = (framesPerSecond_ + currentFramesPerSecond)/2.0;
  }
    
  lastTickDate_ = tickDate;
  
  [eventTarget_ handleTick:tickInterval];
  [self draw];
}

- (void)setViewportOffsetX:(int)viewportOffsetX andY:(int)viewportOffsetY {
  viewportOffsetX_ = viewportOffsetX;
  viewportOffsetY_ = viewportOffsetY;
}

- (void)draw {    
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glTranslatef(viewportOffsetX_, viewportOffsetY_, 0);
  
  glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  
  [root_ draw];
    
  [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews {
  [EAGLContext setCurrentContext:context];
  [self destroyFramebuffer];
  [self createFramebuffer];
  [self draw];
}

- (BOOL)createFramebuffer {
  
  glGenFramebuffersOES(1, &viewFramebuffer);
  glGenRenderbuffersOES(1, &viewRenderbuffer);
  
  glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
  glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
  [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
  glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
  
  glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
  glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
  
  if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
    NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    return NO;
  }
  
  glViewport(0, 0, backingWidth, backingHeight);
  
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrthof(0, backingWidth, 
           0, backingHeight,
           -1, 1);    

  // Set a blending function to use
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
  // Enable blending
  glEnable(GL_BLEND);
  
  return YES;
}


- (void)destroyFramebuffer {   
  glDeleteFramebuffersOES(1, &viewFramebuffer);
  viewFramebuffer = 0;
  glDeleteRenderbuffersOES(1, &viewRenderbuffer);
  viewRenderbuffer = 0;
  
  if(depthRenderbuffer) {
    glDeleteRenderbuffersOES(1, &depthRenderbuffer);
    depthRenderbuffer = 0;
  }
}

- (void)startAnimation {
  if (animationTimer) {
    [self stopAnimation];
  }
  
  lastTickDate_ = [NSDate timeIntervalSinceReferenceDate];
  animationTimer = 
      [NSTimer scheduledTimerWithTimeInterval:animationInterval 
                                       target:self 
                                     selector:@selector(handleTick) 
                                     userInfo:nil 
                                      repeats:YES];
}


- (void)stopAnimation {
  [animationTimer invalidate];
  animationTimer = nil;
}

- (void)setAnimationInterval:(NSTimeInterval)interval {
  animationInterval = interval;
  if (animationTimer) {
    [self stopAnimation];
    [self startAnimation];
  }
}

- (PIDEntity *)root {
  return root_;
}

- (CGSize)size {
  return self.frame.size;
}

- (double)framesPerSecond {
  return framesPerSecond_;
}

- (void)setEventTarget:(id <PIDEventTarget>)eventTarget {
  eventTarget_ = eventTarget;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [eventTarget_ handleTouchBegin:[self getTouchPoint:touches]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [eventTarget_ handleTouchMove:[self getTouchPoint:touches]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [eventTarget_ handleTouchEnd:[self getTouchPoint:touches]];
}

- (CGPoint)getTouchPoint:(NSSet *)touches {
  CGRect bounds = [self bounds];
  UITouch* touch = [touches anyObject];
  // Convert touch point from UIView referential to OpenGL one (upside-down flip)
  CGPoint touchPoint = [touch locationInView:self];
  touchPoint.y = bounds.size.height - touchPoint.y;

  return touchPoint;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"touchesCancelled");   
}

- (void)dealloc {
  
  [self stopAnimation];
  
  if ([EAGLContext currentContext] == context) {
    [EAGLContext setCurrentContext:nil];
  }
  
  [root_ release];
  
  [context release];  
  [super dealloc];
}

@end
