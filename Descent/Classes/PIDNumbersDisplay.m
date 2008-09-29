//
//  PIDNumbersDisplay.m
//  Descent
//
//  Created by Mihai Parparita on 9/24/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDNumbersDisplay.h"
#import "PIDTextureSprite.h"
#import "PIDSprite.h"

#define kDigitWidth 9
#define kDigitHeight 16

static PIDTextureSprite *kNumbersSprite;

@interface PIDDigit : PIDEntity {
@private
  int frame_;
}

- initWithValue:(unichar)value position:(int)position;
@end

@implementation PIDDigit

- initWithValue:(unichar)value position:(int)position {
  if (self = [super initWithSprite:kNumbersSprite 
                          position:CGPointMake(position * kDigitWidth, 0)]) {
    if (value >= '0' && value <= '9') {
      frame_ = value - '0';
    } else if (value == ' ') {
      frame_ = 10;
    } else if (value == '.') {
      frame_ = 11;
    } else {
      NSLog(@"Warning, unknown character: %d", value);
      frame_ = 0;
    }
  }
  
  return self;
}

- (void)draw {
  [kNumbersSprite setFrame:frame_];
  [super draw];
}

@end

@implementation PIDNumbersDisplay

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;
  
  kNumbersSprite = [[PIDTextureSprite alloc]
                        initWithImage:@"numbers.png"
                                 size:CGSizeMake(kDigitWidth, kDigitHeight)
                               frames:10];  
}

- initWithPosition:(CGPoint)position {
  if (self = [super initWithSprite:kNullSprite position:position]) {
    // Nothing else to do for now
  }
  
  return self;
}

- (void)setValue:(NSString *)value {
  [self removeAllChildren];
  
  for (int i = 0; i < [value length]; i++) {
    PIDDigit *digit = 
        [[PIDDigit alloc] initWithValue:[value characterAtIndex:i] position:i];
    [self addChild:digit];
    [digit release];
  }
}


@end
