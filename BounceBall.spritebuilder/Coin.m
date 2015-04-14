//
//  Coin.m
//  hide
//
//  Created by Zheng Li on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Coin.h"

@implementation Coin

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"Coin";
}

@end
