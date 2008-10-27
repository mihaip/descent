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
#import "PIDEntityWithFrame.h"

#define kDigitWidth 9
#define kDigitHeight 16

static PIDTextureSprite *kNumbersSprite;

@interface PIDDigit : PIDEntityWithFrame {}

- initWithValue:(unichar)value position:(int)position;
@end

@implementation PIDDigit

- initWithValue:(unichar)value position:(int)position {
  int frame;
  if (value >= '0' && value <= '9') {
    frame = value - '0';
  } else if (value == ' ') {
    frame = 10;
  } else if (value == '.') {
    frame = 11;
  } else {
    NSLog(@"Warning, unknown character: %d", value);
    frame = 0;
  }
  
  return [super initWithSprite:kNumbersSprite 
                      position:CGPointMake(position * kDigitWidth, 0)
                         frame:frame];
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
  // Only update if value has actually changed
  if (currentValue_) {
    if ([currentValue_ compare:value] == NSOrderedSame) {
      return;
    }
    
    [currentValue_ release];
  }
  
  currentValue_ = [value retain];  
  
  [self removeAllChildren];
  
  for (int i = 0; i < [value length]; i++) {
    PIDDigit *digit = 
        [[PIDDigit alloc] initWithValue:[value characterAtIndex:i] position:i];
    [self addChild:digit];
    [digit release];
  }
}

- (void)dealloc {
  if (currentValue_) {
    [currentValue_ release];
  }
  
  [super dealloc]; 
}


@end
