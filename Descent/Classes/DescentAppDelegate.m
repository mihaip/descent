//
//    DescentAppDelegate.m
//    Descent
//
//    Created by Mihai Parparita on 9/7/08.
//    Copyright persistent.info 2008. All rights reserved.
//

#import "DescentAppDelegate.h"
#import "EAGLView.h"

@interface DescentAppDelegate () 
- (NSString *)highScoresPath;
- (void)loadHighScores;
- (void)saveHighScores;
@end

@implementation DescentAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  // For now use a fixed seed so that repeated runs are reproducible
  srandom(27);
  
  difficulty_ = kMedium;

  [self loadHighScores];
  
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

- (NSString *)highScoresPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:@"Scores.plist"];
}

- (void)loadHighScores {
  highScores_ = [[NSMutableArray alloc] initWithCapacity:3];

  NSString *errorDesc = nil;
  NSData *plistXML = 
      [[NSFileManager defaultManager] contentsAtPath:[self highScoresPath]];
  NSDictionary *scoresDict = 
      (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML
                                                       mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                 format:NULL 
                                                       errorDescription:&errorDesc];
  if (errorDesc) {
    NSLog(@"Couldn't load high scores: %@", errorDesc);
    [errorDesc release];
    
    // Default high scores
    [highScores_ addObject:[NSMutableArray arrayWithObjects:
                            [NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:0],
                            nil]];
     [highScores_ addObject:[NSMutableArray arrayWithObjects:
                             [NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:0],
                             nil]];
      [highScores_ addObject:[NSMutableArray arrayWithObjects:
                              [NSNumber numberWithInt:0],
                              [NSNumber numberWithInt:0],
                              [NSNumber numberWithInt:0],
                              [NSNumber numberWithInt:0],
                              [NSNumber numberWithInt:0],
                              nil]];
    return;
  }
  
  [highScores_ addObject:
      [NSMutableArray arrayWithArray:[scoresDict objectForKey:@"Easy"]]];
  [highScores_ addObject:
      [NSMutableArray arrayWithArray:[scoresDict objectForKey:@"Medium"]]];
  [highScores_ addObject:
      [NSMutableArray arrayWithArray:[scoresDict objectForKey:@"Hard"]]];
}

- (void)saveHighScores {
  NSDictionary *scoresDict = 
      [NSDictionary dictionaryWithObjects:highScores_
                                  forKeys:[NSArray arrayWithObjects: @"Easy", @"Medium", @"Hard", nil]];
  
  NSString *errorDesc;
  NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:scoresDict
                                                                 format:NSPropertyListXMLFormat_v1_0
                                                       errorDescription:&errorDesc];
  
  if (plistData) {
    if (![plistData writeToFile:[self highScoresPath] atomically:YES]) {
      NSLog(@"Couldn't save high scores");
    }
  } else {
    NSLog(@"Couldn't save high scores: %@", errorDesc);
    [errorDesc release];
  }
}

- (void)reportScore:(int)newScore {
  NSMutableArray *highScores = [self highScores];
  for (int i = 0; i < [highScores count]; i++) {
    NSNumber *score = [highScores objectAtIndex:i];
    if (newScore > [score intValue]) {
      [highScores replaceObjectAtIndex:i 
                            withObject:[NSNumber numberWithInt:newScore]];
      [self saveHighScores];
      break;
    }
  }
}

- (NSMutableArray *)highScores {
  return [highScores_ objectAtIndex:difficulty_];
}

- (void)dealloc {
  [highScores_ release];
  
  [super dealloc];
}

@end
