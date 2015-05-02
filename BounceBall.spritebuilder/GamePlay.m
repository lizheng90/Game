//
//  GamePlay.m
//  hide
//
//  Created by Zheng Li on 3/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "Character.h"
#import "NewCharacter.h"
#import "CCPhysics+ObjectiveChipmunk.h"



@implementation GamePlay

{
    CCPhysicsNode *_physicsNode;
    CCNode *character;
    
    CCLabelTTF *_time_label;
    int seconds;
    
    CCButton *_GameOverButton;
    CCButton *_RestartButton;
    CCButton *_ShareFB;
    
    NSMutableArray *stones;
    
    NSTimer* myTimer;
    
//    BOOL _gameOver;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    //    _RestartButton.visible = true;
    
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    // create character
    [self launchCharacter];

    
    // generate stones every 5 seconds
    [self generateStone];
    [self generateCoin];
    
    seconds = 0;
    _time_label.visible = TRUE;
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                                      selector: @selector(callAfterOneSecond:) userInfo: nil repeats: YES];

    _physicsNode.collisionDelegate = self;
    
    stones = [[NSMutableArray alloc] init];

}

// called on every touch in this scene
- (void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    // move the player to the touch location smoothly
    [character stopActionByTag:1]; // Stop an action by tag to avoid having multiple move
    // actions running simultaneously
    CGPoint pos = [touch locationInNode:_physicsNode]; // this allow the player to move about the
    // full extents of the _levelNode (4000x500 points)
    CCAction* move = [CCActionMoveTo actionWithDuration:1.2 position:pos];
    move.tag = 1;
    [character runAction:move];
    
//    // move the player to the touch location smoothly
//    [_playerNode stopActionByTag:1]; // Stop an action by tag to avoid having multiple move
//    // actions running simultaneously
//    CGPoint pos = [touch locationInNode:_levelNode]; // this allow the player to move about the
//    // full extents of the _levelNode (4000x500 points)
//    CCAction* move = [CCActionMoveTo actionWithDuration:1.2 position:pos];
//    move.tag = 1;
//    [_playerNode runAction:move];
}

- (void)launchCharacter {
    // load the character.ccb
    character = [CCBReader load:@"Character"];
    character.position = ccpAdd(ccp(150, 100), ccp(150, 100));
    
    // add character to physicsNode
    [_physicsNode addChild:character];
}

- (void)generateStone {
    [NSTimer scheduledTimerWithTimeInterval:(5.0) target:self selector:@selector(launchStone) userInfo:nil repeats:YES];
}

- (void)launchStone {
    // loads the stone.ccb
    CCNode* stone = [CCBReader load:@"Stone"];
    stone.position = ccpAdd(ccp(100, 5), ccp(100, 5));
    
    // add stone to physicsNode
    [stones addObject:stone];
//    NSLog(@"%d", [stones count]);
    [_physicsNode addChild:stone];
    
    // manually create & apply a force to launch the stone
    CGPoint launchDirection = ccp(arc4random_uniform(200), arc4random_uniform(200));
    CGPoint force = ccpMult(launchDirection, 200);
    [stone.physicsBody applyForce:force];
}

- (void)generateCoin {
    [NSTimer scheduledTimerWithTimeInterval:(7.0) target:self selector:@selector(launchCoin) userInfo:nil repeats:YES];
}

- (void)launchCoin {
    // loads the coin.ccb
    CCNode* coin = [CCBReader load:@"Coin"];
    coin.position = ccpAdd(ccp(arc4random_uniform(300), arc4random_uniform(100)),
                           ccp(arc4random_uniform(300),arc4random_uniform(100)));
    
    // add coin to physicsNode
    [_physicsNode addChild:coin];
    
}

-(void) callAfterOneSecond:(NSTimer*) t
{
    seconds++;
    _time_label.string = [NSString stringWithFormat:@"%d", seconds];
    _time_label.visible = TRUE;
}

- (void) stoneRemoved: (CCNode *)Stone {
    [Stone removeFromParent];
}

- (void) coinRemoved:(CCNode *)Coin {
    
    // remove coin
    [Coin removeFromParent];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Coin:(CCNode *)nodeA Character:(CCNode *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    if (energy > -100.f) {
        [[_physicsNode space] addPostStepBlock:^{
            [self coinRemoved:nodeA];
            CCNode *stone = [stones objectAtIndex:[stones count] - 1];
            [self stoneRemoved:stone];
        } key:nodeA];    }
}

- (void)gameOver {
    _RestartButton.visible = TRUE;
    _GameOverButton.visible = TRUE;
    _ShareFB.visible = TRUE;
    [myTimer invalidate];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Stone:(CCNode *)nodeA Character:(CCNode *)nodeB
{
    
    float energy = [pair totalKineticEnergy];
    
    if (energy > -100.f) {
        [self gameOver];
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"GamePlay"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)fb {
    
    NSString *score = [NSString stringWithFormat:@"%d",seconds];
    NSLog(@"%@", score);
    NSString *urlString = @"hahaha";
    NSString *title = [NSString stringWithFormat:@"%@,%@", @"My score is: ", score];

    NSString *shareUrlString = [NSString stringWithFormat:@"http://www.facebook.com/sharer.php?u=%@&t=%@", urlString , title];
    shareUrlString = [shareUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:shareUrlString];
    [[UIApplication sharedApplication] openURL:url];
}

//-(void) update:(CCTime)delta
//{
//    // update scroll node position to player node, with offset to center player in the view
//    [self scrollToTarget:character];
//}
//
//-(void) scrollToTarget:(CCNode*)target
//{
//    // assign the size of the view to viewSize,
//    CGSize viewSize = [CCDirector sharedDirector].viewSize;
//    // the center point of the view is calculated and assigned to viewCenter
//    CGPoint viewCenter = CGPointMake(viewSize.width / 2.0, viewSize.height / 2.0);
//    // keeps the target node centered in the view
//    CGPoint viewPos = ccpSub(target.positionInPoints, viewCenter);
//    // clamp the viewPos to the level’s size using the MIN and MAX macros
//    CGSize levelSize = _bgNode.contentSizeInPoints;
//    viewPos.x = MAX(0.0, MIN(viewPos.x, levelSize.width - viewSize.width));
//    viewPos.y = MAX(0.0, MIN(viewPos.y, levelSize.height - viewSize.height));
//    _bgNode.positionInPoints = ccpNeg(viewPos);
//}


@end
