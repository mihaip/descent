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
    isEnabled_ = YES;
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

- (double)top {
  return CGRectGetMaxY([self bounds]);
}

- (double)bottom {
  return CGRectGetMinY([self bounds]);
}  

- (double)left {
  return CGRectGetMinX([self bounds]);
}

- (double)right {
  return CGRectGetMaxX([self bounds]);
}

// Simple bounding rectangle collision, subclasses may choose to implement more
// accurate collision detection
- (BOOL)intersectsWith:(PIDEntity *)other {
  return [self intersectsWith:other withMargin:0];
}

- (BOOL)intersectsWith:(PIDEntity *)other withMargin:(int)margin {
  CGRect ourBounds = [self bounds];
  CGRect otherBounds = [other bounds];
  
  ourBounds = CGRectInset(ourBounds, -margin, -margin);
  otherBounds = CGRectInset(otherBounds, -margin, -margin);
  
  return CGRectIntersectsRect(ourBounds, otherBounds);
}


- (BOOL)isPointInside:(CGPoint)point {
  return CGRectContainsPoint([self bounds], point);
}

- (void)draw {
  if (!isEnabled_) return;
  
  glPushMatrix();
  glTranslatef(position_.x, position_.y, 0);
  
  [sprite_ draw];

  [children_ makeObjectsPerformSelector:@selector(draw)];
  
  glPopMatrix();
}

- (void)enable {
  isEnabled_ = YES;
}

- (void)disable {
  isEnabled_ = NO; 
}

- (BOOL)isEnabled {
  return isEnabled_; 
}


- (void) dealloc{
  [sprite_ release];
  [children_ makeObjectsPerformSelector:@selector(release)];
  [children_ release];
  
  [super dealloc];
}

@end
