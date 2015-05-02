//
//  Character.m
//  SpaceWalker
//
//  Created by Zheng Li on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Character.h"

@implementation Character

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"Character";
}

@end
