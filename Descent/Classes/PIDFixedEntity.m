//
//  PIDFixedEntity.m
//  Descent
//
//  Created by Mihai Parparita on 9/17/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDFixedEntity.h"

@implementation PIDFixedEntity

- (void)draw {
  glPushMatrix();
  glLoadIdentity();
  
  [super draw];
  
  glPopMatrix();
}

@end
