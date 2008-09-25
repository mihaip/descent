//
//   PIDEntity.m
//   Descent
//
//   Created by Mihai Parparita on 9/9/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"

@implementation PIDEntity

- initWithSprite:(PIDSprite *)sprite position:(CGPoint) position {
  if (self = [super init]) {
    sprite_ = [sprite retain];
    position_ = position;
    children_ = [[NSMutableArray alloc] initWithCapacity:10];
  }
  
  return self;
}

- initWithSprite:(PIDSprite *)sprite {
  CGPoint defaultPosition = {0, 0};
  return [self initWithSprite:sprite position:defaultPosition];
}

- (void)addChild:(PIDEntity*) child {
  [children_ addObject:child];
}

- (BOOL)removeChild:(PIDEntity*) child {
  int childIndex = [children_ indexOfObject:child];
  if (childIndex == NSNotFound) {
    return NO;
  } else {
    [children_ removeObjectAtIndex:childIndex];
    return YES;
  }
}

- (void)removeAllChildren {
  [children_ removeAllObjects];
}

- (CGPoint)position {
  return position_;
}

- (void)setPosition:(CGPoint) position {
  position_ = position;
}

- (void)handleTick:(double)ticks {
  // Subclasses may override this 
}

- (CGRect)bounds {
  CGRect bounds;

  bounds.size = [sprite_ size];

  bounds.origin.x = position_.x - bounds.size.width/2;
  bounds.origin.y = position_.y - bounds.size.height/2;
  
  return bounds;
}

// Simple bounding rectangle collision, subclasses may choose to implement more
// accurate collision detection
- (int)intersectsWith:(PIDEntity *)other {
  CGRect ourBounds = [self bounds];
  CGRect otherBounds = [other bounds];
  CGRect intersection = CGRectIntersection(ourBounds, otherBounds);
  
  if (CGRectIsNull(intersection)) {
    return kIntersectionNone;
  }
  
  int sides = 0;
  
  if (ourBounds.origin.y == intersection.origin.y) {
    sides |= kIntersectionSideBottom;
  }
  if (ourBounds.origin.x == intersection.origin.x) {
    sides |= kIntersectionSideLeft;
  }
  if (ourBounds.origin.x + ourBounds.size.width == intersection.origin.x + intersection.size.width) {
    sides |= kIntersectionSideRight;
  }
  if (ourBounds.origin.y + ourBounds.size.height == intersection.origin.y + intersection.size.height) {
    sides |= kIntersectionSideTop;
  }
  
  return sides;
}


- (void)draw {
  glPushMatrix();
  glTranslatef(position_.x, position_.y, 0);
  
  [sprite_ draw];

  [children_ makeObjectsPerformSelector:@selector(draw)];
  
  glPopMatrix();
}

- (void) dealloc{
  [sprite_ release];
  [children_ makeObjectsPerformSelector:@selector(release)];
  [children_ release];
  
  [super dealloc];
}

@end
