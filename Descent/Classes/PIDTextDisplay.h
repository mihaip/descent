//
//  PIDTextDisplay.h
//  Descent
//
//  Created by Mihai Parparita on 9/24/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"
#import "PIDTextureSprite.h"
#import "PIDColor.h"

#define kLetterWidth 16
#define kLetterHeight 20

@interface PIDTextDisplay : PIDEntity {
 @private
  NSString *currentValue_;
  PIDTextureSprite *lettersSprite_;
  PIDColor *color_;
}

- initWithPosition:(CGPoint)position;
- initWithPosition:(CGPoint)position color:(PIDColor *)color;
- initWithPosition:(CGPoint)position sprite:(PIDTextureSprite *)sprite;
- initWithPosition:(CGPoint)position 
            sprite:(PIDTextureSprite *)sprite
             color:(PIDColor *)color;

- (void)setValue:(NSString *)value;

@end
