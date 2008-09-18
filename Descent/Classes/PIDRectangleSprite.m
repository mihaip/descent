//
//   PIDRectangleSprite.m
//   Descent
//
//   Created by Mihai Parparita on 9/9/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDRectangleSprite.h"

// TODO(mihaip): this should be in a buffer object (see section 2.9)
static const GLfloat kSquareVertices[] = {
  -0.5, -0.5,
   0.5, -0.5,
  -0.5,  0.5,
   0.5,  0.5,
};

@implementation PIDRectangleSprite

- initWithSize:(CGSize)size color:(PIDColor *)color {
  if (self = [super initWithSize:size]) {
    color_ = [color retain];
  }
  return self;
}

- (void)draw {
  [color_ apply];

  glPushMatrix();
  glScalef(size_.width, size_.height, 1.0);
  
  glVertexPointer(2, GL_FLOAT, 0, kSquareVertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  
  glPopMatrix();
}

- (void)dealloc {
  [color_ release];
  
  [super dealloc];
}

@end
