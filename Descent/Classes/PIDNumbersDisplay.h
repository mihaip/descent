//
//  PIDNumbersDisplay.h
//  Descent
//
//  Created by Mihai Parparita on 9/24/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFixedEntity.h"

@interface PIDNumbersDisplay : PIDFixedEntity {
 @private
  NSString *currentValue_;
}

- initWithPosition:(CGPoint)position;
- (void)setValue:(NSString *)value;

@end
