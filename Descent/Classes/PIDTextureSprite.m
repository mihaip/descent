//
//   PIDTextureSprite.m
//   Descent
//
//   Created by Mihai Parparita on 9/14/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PIDTextureSprite.h"

// TODO(mihaip): this should be in a buffer object (see section 2.9)
static const GLfloat kSquareVertices[] = {
  -0.5, -0.5,
  0.5, -0.5,
  -0.5, 0.5,
  0.5,  0.5,
};

// Sets up an array of values for the texture coordinates.
static const GLshort kSquareTexcoords[] = {
  0, 1,
  1, 1,
  0, 0,
  1, 0,
};

@implementation PIDTextureSprite

- initWithImage:(NSString*) path size:(CGSize)size frames:(int)frameCount {
  if (self = [super initWithSize:size]) {
    CGImageRef textureImage = [UIImage imageNamed:path].CGImage;

    // Get the width and height of the image
    textureSize_ = CGSizeMake(
        CGImageGetWidth(textureImage), CGImageGetHeight(textureImage));

    // Render image into a byte array, which we can feed to OpenGL
    GLubyte *textureData = 
        (GLubyte *) malloc(textureSize_.width * textureSize_.height * 4);
    CGContextRef textureContext = 
       CGBitmapContextCreate(textureData,
                             textureSize_.width,
                             textureSize_.height,
                             8,
                             textureSize_.width * 4,
                             CGImageGetColorSpace(textureImage),
                             kCGImageAlphaPremultipliedLast);
    CGRect textureRect = 
        CGRectMake(0.0, 0.0, textureSize_.width, textureSize_.height);
    CGContextClearRect(textureContext, textureRect);
    CGContextDrawImage(textureContext, textureRect, textureImage);
    CGContextRelease(textureContext);

    glGenTextures(1, &texture_);
    // Bind the texture name. 
    glBindTexture(GL_TEXTURE_2D, texture_);
    // Speidfy a 2D texture image, provideing the a pointer to the image data in memory
    glTexImage2D(GL_TEXTURE_2D, 
                 0, // level
                 GL_RGBA, // format
                 textureSize_.width, 
                 textureSize_.height, 
                 0, // border
                 GL_RGBA, 
                 GL_UNSIGNED_BYTE,
                 textureData);

    // Don't need our copy of the texture data anymore, since OpenGL has it
    free(textureData);

    // Don't want previously set colors to affect us
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE); 

    // Use simple linear blending (no mip maps)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    frameCount_ = frameCount;
  }
  return self;
}

- (void)draw {
  glPushMatrix();
  glScalef(size_.width, size_.height, 1.0);

  glVertexPointer(2, GL_FLOAT, 0, kSquareVertices);
  glEnableClientState(GL_VERTEX_ARRAY);

  glBindTexture(GL_TEXTURE_2D, texture_);

  // Enable use of the texture
  glEnable(GL_TEXTURE_2D);

  glTexCoordPointer(2, GL_SHORT, 0, kSquareTexcoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  // Offset texture coordinates based on the current frame
  // TODO(mihaip): see if we can use glDrawTexiOES extension instead
  glMatrixMode(GL_TEXTURE);
  glLoadIdentity();
  glScalef(size_.width/textureSize_.width, size_.height/textureSize_.height, 1.0);
  glTranslatef(frame_, 0, 0);
  glMatrixMode(GL_MODELVIEW);

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  glDisable(GL_TEXTURE_2D);

  glPopMatrix();
}

- (void)setFrame:(int)frame {
  frame_ = frame;
}

- (void)dealloc {
  glDeleteTextures(1, &texture_);

  [super dealloc];
}

@end
