//
//  PIDTrail.h
//  Descent
//
//  Created by Mihai Parparita on 11/1/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"
#import "PIDPlayer.h"

@interface PIDTrail : PIDEntity {
 @private
  GLfloat *points_;
  int currentPoint_;
  int totalPoints_;
  GLushort *connectingPoints_;
}

- init;
- (void)update:(PIDPlayer *)player;

@end
