//
//  HammerScene.m
//  TrickTrick
//
//  Created by Zheng Li on 3/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "HammerScene.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "CCActionInterval.h"
#import "CCAction.h"
@implementation HammerScene

{
  CCPhysicsNode *_hammer;
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
}

// called on every touch in this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self hitHead];
}

- (void) hitHead {
    CCLOG(@"play button pressed");
    
    CCActionMoveTo *actionMoveTo1 = [CCActionMoveTo actionWithDuration:1.f position:ccp(310, 239)];
    CCActionMoveTo *actionMoveTo2 = [CCActionMoveTo actionWithDuration:0.f position:ccp(320, 67)];

    [_hammer runAction : actionMoveTo1];
    [_hammer runAction : actionMoveTo2];

}

@end
