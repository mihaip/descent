//
//   PIDRectangleSprite.h
//   Descent
//
//   Created by Mihai Parparita on 9/9/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDColor.h"
#import "PIDSprite.h"

@interface PIDRectangleSprite : PIDSprite {
  PIDColor *color_;
}

-initWithSize:(CGSize)size color:(PIDColor *)color;

@end
