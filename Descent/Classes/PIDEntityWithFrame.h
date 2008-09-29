//
//  PIDEntityWithFrame.h
//  Descent
//
//  Created by Mihai Parparita on 9/28/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"
#import "PIDTextureSprite.h"

@interface PIDEntityWithFrame : PIDEntity {
 @private
  PIDTextureSprite *textureSprite_;
  int frame_;
}

- initWithSprite:(PIDTextureSprite *)sprite 
        position:(CGPoint)position 
           frame:(int)frame;

@end
