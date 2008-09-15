//
//  PIDPlatform.m
//  Descent
//
//  Created by Mihai Parparita on 9/10/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDPlatform.h"
#import "PIDRectangleSprite.h"
#import "PIDColor.h"

static PIDRectangleSprite *kPlatformSprite;

@implementation PIDPlatform

+ (void)initialize {
	static BOOL initialized = NO; 
	if (initialized) return;
	initialized = YES;

	CGSize platformSize = {kPlatformWidth, kPlatformHeight};
	PIDColor *platformColor = [[PIDColor alloc] initWithRed:0.2 
																										green:0.8 
																										 blue:0.2];
	kPlatformSprite = [[PIDRectangleSprite alloc] initWithSize:platformSize
																											 color:platformColor];

	[platformColor release];
}

- initWithPosition:(CGPoint)position {
	if (self = [super initWithSprite:kPlatformSprite position:position]) {
		// Nothing else for now
	}
	
	return self;
}

@end
