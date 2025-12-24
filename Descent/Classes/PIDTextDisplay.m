//
//  PIDTextDisplay.m
//  Descent
//
//  Created by Mihai Parparita on 9/24/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDTextDisplay.h"
#import "PIDTextureSprite.h"
#import "PIDSprite.h"
#import "PIDEntityWithFrame.h"
#import "PIDColor.h"

static int kLetterWidths[] = {
  12, // 0
   8, // 1
  11, // 2
  12, // 3
  12, // 4
  11, // 5
  12, // 6
  11, // 7
  11, // 8
  12, // 9
   5, // .
  11, // a
  12, // b
  10, // c
  12, // d
  12, // e
   7, // f
  12, // g
  11, // h
   5, // i
   7, // j
  10, // k
   5, // l
  16, // m
  11, // n
  12, // o
  12, // p
  12, // q
   8, // r
  11, // s
   8, // t
  11, // u
  12, // v
  16, // w
  11, // x
  11, // y
  11  // z
};

static PIDTextureSprite *kLettersSprite;

@interface PIDLetter : PIDEntityWithFrame {}

- initWithValue:(unichar)value 
       position:(int)position 
         sprite:(PIDTextureSprite *)sprite;
@end

@implementation PIDLetter

- initWithValue:(unichar)value 
       position:(int)position 
         sprite:(PIDTextureSprite *)sprite {
  int frame;
  if (value >= '0' && value <= '9') {
    frame = value - '0';
  } else if (value == '.') {
    frame = 10;
  } else if (value >= 'a' && value <= 'z') {
    frame = 11 + value - 'a';
  } else if (value == ' ') {
    frame = 11 + 26 + 1;
  } else  {
    NSLog(@"Warning, unknown character: %d", value);
    frame = 0;
  }
  
  return [super initWithSprite:sprite 
                      position:CGPointMake(position * [sprite size].width, 0)
                         frame:frame];
}

@end

@implementation PIDTextDisplay

+ (void)initialize {
  static BOOL initialized = NO; 
  if (initialized) return;
  initialized = YES;
  
  kLettersSprite = [[PIDTextureSprite alloc]
                        initWithImage:@"font.png"
                                 size:CGSizeMake(kLetterWidth, kLetterHeight)
                               frames:10];  
}

- initWithPosition:(CGPoint)position {
  return [self initWithPosition:position sprite:kLettersSprite];
}

- initWithPosition:(CGPoint)position color:(PIDColor *)color {
  return [self initWithPosition:position sprite:kLettersSprite color:color]; 
}

- initWithPosition:(CGPoint)position sprite:(PIDTextureSprite *)sprite {
  return [self initWithPosition:position
                         sprite:sprite
                          color:nil];   
}
 
- initWithPosition:(CGPoint)position
            sprite:(PIDTextureSprite *)sprite
             color:(PIDColor *)color {
  if (self = [super initWithSprite:kNullSprite position:position]) {
    lettersSprite_ = [sprite retain];
    color_ = [color retain];
    [self fixPosition];
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
    PIDLetter *letter = [[PIDLetter alloc] initWithValue:[value characterAtIndex:i] 
                                             position:i
                                               sprite:lettersSprite_];
    [self addChild:letter];
    [letter release];
  }
}

- (CGSize)size {
  CGSize spriteSize = [lettersSprite_ size];
  int letterCount = currentValue_ ? [currentValue_ length] : 1;
  return CGSizeMake(spriteSize.width * letterCount, 
                    spriteSize.height); 
}

- (CGRect)bounds {
  CGRect bounds;
  
  bounds.size = [self size];
  
  bounds.origin.x = position_.x ;
  bounds.origin.y = position_.y - bounds.size.height/2;
  
  return bounds;
}

- (void)draw {
  GLint oldEnvMode;

  if (color_) {
    glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, &oldEnvMode);
    
    // Replace the source color in the texture with the tint color
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
    
    // Modula is arg0 * arg 1
    glTexEnvf(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
    
    // Use the vertex color (applied below) as arg0
    glTexEnvf(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PRIMARY_COLOR);
    glTexEnvf(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
    
    // Use the texture's aplha as arg1
    glTexEnvf(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_TEXTURE);
    glTexEnvf(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_ALPHA);

    [color_ apply];
  }
  
  [super draw];
  
  if (color_) {
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, oldEnvMode);
  }
}

- (void)dealloc {
  if (currentValue_) {
    [currentValue_ release];
  }
  
  [lettersSprite_ release];
  [color_ release];
  
  [super dealloc]; 
}


@end
