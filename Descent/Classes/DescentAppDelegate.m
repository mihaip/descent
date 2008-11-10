//
//    DescentAppDelegate.m
//    Descent
//
//    Created by Mihai Parparita on 9/7/08.
//    Copyright persistent.info 2008. All rights reserved.
//

#import "DescentAppDelegate.h"
#import "EAGLView.h"

@implementation DescentAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  // For now use a fixed seed so that repeated runs are reproducible
  srandom(27);
  
  difficulty_ = kMedium;
  [self switchToMenu];
  [glView startAnimation];  
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [eventTarget_ suspend];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [eventTarget_ resume];
}

- (id <PIDEventTarget>)eventTarget {
  return eventTarget_;
}

- (void)switchToGame {
  if (eventTarget_) {
    // TODO(mihaip): it'd be nice if this cast wasn't necessary
    [((NSObject*) eventTarget_) release];
  }
  
  eventTarget_ = [[PIDGame alloc] initWithView:glView difficulty:difficulty_]; 
}

- (void)switchToMenu {
  if (eventTarget_) {
    // TODO(mihaip): it'd be nice if this cast wasn't necessary
    [((NSObject*) eventTarget_) release];
  }
  eventTarget_ = [[PIDMenu alloc] initWithView:glView]; 
}

- (void)lowerDifficulty {
  if (difficulty_ > kEasy) {
    difficulty_--;
  }
}

- (void)raiseDifficulty {
  if (difficulty_ < kHard) {
    difficulty_++;
  }  
}

- (PIDGameDifficulty) difficulty {
  return difficulty_;
}

- (void)dealloc {
  [super dealloc];
}

@end
