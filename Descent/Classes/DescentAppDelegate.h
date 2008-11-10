//
//   DescentAppDelegate.h
//   Descent
//
//   Created by Mihai Parparita on 9/7/08.
//   Copyright persistent.info 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EAGLView.h"
#import "PIDGame.h"
#import "PIDMenu.h"

@interface DescentAppDelegate : NSObject <UIApplicationDelegate> {
  IBOutlet UIWindow *window;
  IBOutlet EAGLView *glView;
  PIDGameDifficulty difficulty_;
 @private
  id <PIDEventTarget> eventTarget_;
}

@property (nonatomic, retain) UIWindow *window;

- (id <PIDEventTarget>)eventTarget;
- (void)switchToGame;
- (void)switchToMenu;
- (void)lowerDifficulty;
- (void)raiseDifficulty;
- (PIDGameDifficulty) difficulty;

@end

static DescentAppDelegate* GetAppInstance() {
  return (DescentAppDelegate*) ([UIApplication sharedApplication].delegate);
}