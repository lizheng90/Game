//
//  GamePlay.m
//  TrickTrick
//
//  Created by Zheng Li on 3/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlayScene.h"

@implementation GamePlayScene

- (void)hammer {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"HammerScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
