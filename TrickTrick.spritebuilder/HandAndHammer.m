//
//  HandAndHammer.m
//  TrickTrick
//
//  Created by Zheng Li on 3/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "HandAndHammer.h"

@implementation HandAndHammer

- (void)hit
{
    [self.physicsBody applyImpulse:ccp(0, 1500.f)];
}

@end
