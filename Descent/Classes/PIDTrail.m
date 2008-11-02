//
//  PIDTrail.m
//  Descent
//
//  Created by Mihai Parparita on 11/1/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDTrail.h"

// Points are in a circular buffer. Assuming that the user generally descents,
// we will have at most one point per vertical pixel, of which there are 480
#define kMaxTrailLength 512

@implementation PIDTrail

- init {
  if (self = [super initWithSprite:kNullSprite position:CGPointMake(0, 0)]) {
    points_ = malloc(sizeof(GLfloat) * kMaxTrailLength * 2);
    currentPoint_ = 0;
    totalPoints_ = 0;
    connectingPoints_ = malloc(sizeof(GLushort) * 2);
    connectingPoints_[0] = kMaxTrailLength - 1;
    connectingPoints_[1] = 0;
  }
  
  return self;
}

- (void)update:(PIDPlayer *)player {
  CGPoint playerPosition = [player position];
  playerPosition.y = [player bottom];
  
  // No point in adding another point if it's within 2 pixels of the last one
  if (currentPoint_ > 0) {
    double dX = playerPosition.x - points_[2 * (currentPoint_ - 1)];
    double dY = playerPosition.y - points_[2 * (currentPoint_ - 1) + 1];
    if (dX * dX + dY * dY < 4) {
      return;
    }
  }
  points_[2 * currentPoint_] = playerPosition.x;
  points_[2 * currentPoint_ + 1] = playerPosition.y;
  
  currentPoint_++;
  totalPoints_++;
  
  if (currentPoint_ >= kMaxTrailLength) {
    currentPoint_ = 0;
  }
}

- (void)draw {
  glVertexPointer(2, GL_FLOAT, 0, points_);
  glEnableClientState(GL_VERTEX_ARRAY);
  
  glColor4f(0.0, 0.0, 0.0, 0.3);
  glLineWidth(2.0);

  glDrawArrays(GL_LINE_STRIP, 0, currentPoint_);
  
  if (totalPoints_ > kMaxTrailLength) {
    glDrawArrays(GL_LINE_STRIP, currentPoint_, kMaxTrailLength - currentPoint_);
    
    // Connect the two segments points
    glDrawElements(GL_LINE_STRIP, 2, GL_UNSIGNED_SHORT, connectingPoints_);
  }
}


- (void)dellaoc {
  free(points_);
  free(connectingPoints_);
  
  [super dealloc];
}

@end
