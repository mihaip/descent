//
//  PIDHealthDisplay.h
//  Descent
//
//  Created by Mihai Parparita on 9/28/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFixedEntity.h"

#define kMaxHealth 7

@interface PIDHealthDisplay : PIDFixedEntity {

}

- (void)setHealth:(int)health;

@end
