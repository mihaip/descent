//
//  PIDFlash.h
//  Descent
//
//  Created by Mihai Parparita on 11/9/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"
#import "PIDColor.h"

@interface PIDFlash : PIDEntity {
 @private
  int triggerCounter_;
  NSTimer *timer_;
  PIDColor *color_;
}

- initWithSize:(CGSize)size;
- (void)trigger;
- (BOOL)isTriggering;

@end
