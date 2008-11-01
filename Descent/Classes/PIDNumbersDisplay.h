//
//  PIDNumbersDisplay.h
//  Descent
//
//  Created by Mihai Parparita on 9/24/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFixedEntity.h"
#import "PIDTextureSprite.h"

@interface PIDNumbersDisplay : PIDFixedEntity {
 @private
  NSString *currentValue_;
  PIDTextureSprite *numbersSprite_;
}

- initWithPosition:(CGPoint)position;
- initWithPosition:(CGPoint)position sprite:(PIDTextureSprite *)sprite;
- (void)setValue:(NSString *)value;

@end
