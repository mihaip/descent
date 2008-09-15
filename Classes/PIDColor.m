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
  if (self = [self init]) {
	  red_ = red;
		green_ = green;
		blue_ = blue;
	}
	
	return self;
}

- (void)apply {
	glColor4f(red_, green_, blue_, 1.0);
}

@end
