//
//   PIDColor.h
//   Descent
//
//   Created by Mihai Parparita on 9/9/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

@interface PIDColor : NSObject {
  float red_;
  float green_;
  float blue_;
  float alpha_;
}

- initWithRed:(float)red green:(float)green blue:(float)blue;
- initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
- (void)apply;

@end
