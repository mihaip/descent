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
  
  menu_ = [[PIDMenu alloc] initWithView:glView];
  game_ = [[PIDGame alloc] initWithView:glView];

  [glView startAnimation];  
  
  [self switchToMenu];
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
  eventTarget_ = game_; 
}

- (void)switchToMenu {
  eventTarget_ = menu_; 
}

- (void)dealloc {
  [window release];
  [game_ release];
  [super dealloc];
}

@end
