//
//  NewCharacter.m
//  hide
//
//  Created by Zheng Li on 4/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "NewCharacter.h"

@implementation NewCharacter

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"NewCharacter";
}

@end
