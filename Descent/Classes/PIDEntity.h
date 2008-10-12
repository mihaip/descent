//
//   PIDEntity.h
//   Descent
//
//   Created by Mihai Parparita on 9/9/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDSprite.h"

@interface PIDEntity : NSObject {
 @protected
  PIDSprite *sprite_;
  CGPoint position_;
  NSMutableArray *children_;
  BOOL isEnabled_;
}

- initWithSprite:(PIDSprite *)sprite position:(CGPoint) position;
- initWithSprite:(PIDSprite *)sprite;

- (void)addChild:(PIDEntity *)child;
- (BOOL)removeChild:(PIDEntity *)child;
- (void)removeAllChildren;

- (CGPoint)position;
- (void)setPosition:(CGPoint)position;

- (CGRect)bounds;
- (double)top;
- (double)bottom;
- (double)left;
- (double)right;

- (BOOL)intersectsWith:(PIDEntity *)other;
- (BOOL)isPointInside:(CGPoint)point;

- (void)handleTick:(double)ticks;

- (void)draw;

- (void)enable;
- (void)disable;
- (BOOL)isEnabled;

@end
