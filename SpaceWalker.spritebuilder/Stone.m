//
//  Stone.m
//  SpaceWalker
//
//  Created by Zheng Li on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Stone.h"

@implementation Stone

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"Stone";
}

@end
