//
//  Coin.m
//  SpaceWalker
//
//  Created by Zheng Li on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Coin.h"

@implementation Coin

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"Coin";
}

@end
