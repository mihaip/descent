//
//  PIDHealthDisplay.h
//  Descent
//
//  Created by Mihai Parparita on 9/28/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"
#import "PIDPlayer.h"

@interface PIDHealthDisplay : PIDEntity {
 @private
  int currentValue_;
}

- (void)update:(PIDPlayer *)player;
- (int)currentValue;

@end
