//
//  PIDFixedEntity.h
//  Descent
//
//  Created by Mihai Parparita on 9/17/08.
//  Copyright 2008 persistent.info. All rights reserved.
//

#import "PIDEntity.h"

// PIDEntity variant that has fixed positioning, i.e. does not obey any viewport
// offset set on EAGLView
@interface PIDFixedEntity : PIDEntity {

}

- (void)draw;

@end
