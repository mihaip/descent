//
//  PIDColor.m
//  Descent
//
//  Created by Mihai Parparita on 9/9/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDColor.h"

@implementation PIDColor

- initWithRed:(float)red green:(float)green blue:(float)blue {
  self = [self initWithRed:red green:green blue:blue alpha:1.0];
  return self;
}  

- initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
  if (self = [self init]) {
    red_ = red;
    green_ = green;
    blue_ = blue;
    alpha_ = alpha;
  }

  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"(%f, %f, %f %f)", red_, green_, blue_, alpha_];
}

- (void)apply {
  glColor4f(red_, green_, blue_, alpha_);
}

- (GLfloat*)asGlFloats {
  NSLog(@"in asGlFloats");
  GLfloat* color = (GLfloat*)malloc(sizeof(GLfloat) * 4);
  NSLog(@"malloc result: %d", color);
  
  color[0] = red_;
  color[1] = green_;
  color[2] = blue_;
  color[3] = alpha_;
  
  return color;
}

- (void)setAlpha:(float)alpha {
  alpha_ = alpha; 
}

@end
