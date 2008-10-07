//
//  PIDHealthDisplay.h
//  Descent
//
//  Created by Mihai Parparita on 9/28/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFixedEntity.h"
#import "PIDPlayer.h"

@interface PIDHealthDisplay : PIDFixedEntity {
 @private
  int currentValue_;
}

- (void)update:(PIDPlayer *)player;

@end
