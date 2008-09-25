//
//   PIDEntity.h
//   Descent
//
//   Created by Mihai Parparita on 9/9/08.
//   Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDSprite.h"

#define kIntersectionNone (0)
#define kIntersectionSideTop (1 << 0)
#define kIntersectionSideRight (1 << 1)
#define kIntersectionSideBottom (1 << 2)
#define kIntersectionSideLeft (1 << 3)

@interface PIDEntity : NSObject {
 @protected
  PIDSprite *sprite_;
  CGPoint position_;
  NSMutableArray *children_;
}

- initWithSprite:(PIDSprite *)sprite position:(CGPoint) position;
- initWithSprite:(PIDSprite *)sprite;

- (void)addChild:(PIDEntity *)child;
- (BOOL)removeChild:(PIDEntity *)child;
- (void)removeAllChildren;

- (CGPoint)position;
- (void)setPosition:(CGPoint)position;

- (CGRect)bounds;
- (int)intersectsWith:(PIDEntity *)other;

- (void)handleTick:(double)ticks;

- (void)draw;

@end
