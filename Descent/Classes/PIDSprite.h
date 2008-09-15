//
//  PIDSprite.h
//  Descent
//
//  Created by Mihai Parparita on 9/9/08.
//  Copyright 2008 persistent.info. All rights reserved.
//


@interface PIDSprite : NSObject {
 @protected
  CGSize size_;
}

- initWithSize:(CGSize)size;

- (CGSize)size;

- (void)draw;

@end
