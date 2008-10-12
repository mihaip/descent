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
  game_ = [[PIDGame alloc] initWithView:glView];
  [game_ begin];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [game_ pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Don't resume the game, let the user choose when they want to resume
}

- (void)dealloc {
  [window release];
  [game_ release];
  [super dealloc];
}

@end
