//
//  PIDEntityWithFrame.m
//  Descent
//
//  Created by Mihai Parparita on 9/28/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntityWithFrame.h"


@implementation PIDEntityWithFrame

- initWithSprite:(PIDTextureSprite *)sprite 
        position:(CGPoint)position 
           frame:(int)frame {
  if (self = [super initWithSprite:sprite position:position]) {
    textureSprite_ = sprite;
    frame_ = frame;
  }
  
  return self;
}

- (void)draw {
  [textureSprite_ setFrame:frame_];
  [super draw];
}

@end
