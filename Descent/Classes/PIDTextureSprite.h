//
//  PIDTextureSprite.h
//  Descent
//
//  Created by Mihai Parparita on 9/14/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDSprite.h"

@interface PIDTextureSprite : PIDSprite {
 @private
   GLuint texture_;
   int frame_;
   int frameCount_;
}

- initWithImage:(NSString*) path size:(CGSize)size frames:(int)frames;
- (void)setFrame:(int)frame;

@end
