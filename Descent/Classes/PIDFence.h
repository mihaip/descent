//
//  PIDFence.h
//  Descent
//
//  Created by Mihai Parparita on 9/27/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFixedEntity.h"
#import "PIDPlayer.h"

@interface PIDFence : PIDFixedEntity {
 @private
  PIDPlayer *player_;
  BOOL isHurtingPlayer_;
  double hurtTime_;  
}

- initWithPosition:(CGPoint)position size:(CGSize)size;
- (void)handleTick:(double)ticks;
- (void)startHurtingPlayer:(PIDPlayer *)player;
- (void)stopHurtingPlayer;
- (BOOL)isHurtingPlayer;


@end
