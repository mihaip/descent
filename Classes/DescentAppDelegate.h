//
//  DescentAppDelegate.h
//  Descent
//
//  Created by Mihai Parparita on 9/7/08.
//  Copyright persistent.info 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PIDGame.h"

@class EAGLView;

@interface DescentAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet EAGLView *glView;
 @private
	PIDGame* game_;
}

@property (nonatomic, retain) UIWindow *window;

@end

