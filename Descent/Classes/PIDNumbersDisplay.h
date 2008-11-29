//
//  PIDNumbersDisplay.h
//  Descent
//
//  Created by Mihai Parparita on 9/24/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"
#import "PIDTextureSprite.h"

#define kDigitWidth 9
#define kDigitHeight 16

@interface PIDNumbersDisplay : PIDEntity {
 @private
  NSString *currentValue_;
  PIDTextureSprite *numbersSprite_;
}

- initWithPosition:(CGPoint)position;
- initWithPosition:(CGPoint)position sprite:(PIDTextureSprite *)sprite;
- (void)setValue:(NSString *)value;

@end
