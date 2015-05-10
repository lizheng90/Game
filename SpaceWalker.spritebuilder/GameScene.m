//
//  GameScene.m
//  SpaceWalker
//
//  Created by Zheng Li on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameScene.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@implementation GameScene

{
    // level node contains level1 scene, character node, background node and physics node
    CCNode *_levelNode;
    
    // character node, physics node and background node in level1 scene
    CCNode *_playerNode;
    CCPhysicsNode *_physicsNode;
    CCNode *_backgroundNode;
    
    // time lable to show how long you hang in
    CCLabelTTF *_time_label;
    int seconds;
    NSTimer* myTimer;
    
    // game over button
    CCButton *_GameOverButton;
    
    // restart button
    CCButton *_RestartButton;
    
    // share on FB button
    CCButton *_ShareFB;
    
    // game over sprite
    CCSprite *_gameOver;
    
    // array stores all stones in game scene
    NSMutableArray *stones;
    
    // audio player
    OALSimpleAudio* audio;

}

-(void) didLoadFromCCB
{
    // enable receiving input events
    self.userInteractionEnabled = YES;
    
    // load physics node by name
    _physicsNode = (CCPhysicsNode*)[_levelNode getChildByName:@"physics" recursively:NO];
    // enable collisiion
    _physicsNode.collisionDelegate = self;

    // load background and character node by name
    _backgroundNode = [_levelNode getChildByName:@"background" recursively:NO];
    _playerNode = [_physicsNode getChildByName:@"character" recursively:YES];
    
    // initialize second and time label
    seconds = 0;
    _time_label.visible = TRUE;
    
    // update time label every second
    myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                             selector: @selector(callAfterOneSecond:) userInfo: nil repeats: YES];
    // generate stones every 5 seconds
    [self generateStone];
    
    // generate coions every 7 seconds
    [self generateCoin];
    
    stones = [[NSMutableArray alloc] init];
    
    // play background music
    audio = [OALSimpleAudio sharedInstance];
    [audio playBg:@"123.mp3" loop:YES];
    
}

-(void) callAfterOneSecond:(NSTimer*) t
{
    // increase seconds every second and update time label
    seconds++;
    _time_label.string = [NSString stringWithFormat:@"%d", seconds];
    _time_label.visible = TRUE;
}

- (void)generateStone {
    // generate stones every 5 seconds
    [NSTimer scheduledTimerWithTimeInterval:(5.0) target:self selector:@selector(launchStone) userInfo:nil repeats:YES];
}

- (void)launchStone {
    // loads the stone.ccb
    CCNode* stone = [CCBReader load:@"Stone"];
    stone.position = ccpAdd(ccp(200, 5), ccp(200, 5));
    
    // add stone to physicsNode
    [stones addObject:stone];
    [_physicsNode addChild:stone];
    
    // manually create & apply a force to launch the stone
    CGPoint launchDirection = ccp(arc4random_uniform(200), arc4random_uniform(200));
    CGPoint force = ccpMult(launchDirection, 200);
    [stone.physicsBody applyForce:force];
    
}

- (void)generateCoin {
    // generate coions every 7 seconds
    [NSTimer scheduledTimerWithTimeInterval:(7.0) target:self selector:@selector(launchCoin) userInfo:nil repeats:YES];
}

- (void)launchCoin {
    // loads the coin.ccb
    CCNode* coin = [CCBReader load:@"Coin"];
    coin.position = ccpAdd(ccp(arc4random_uniform(400), arc4random_uniform(500)),
                           ccp(arc4random_uniform(400),arc4random_uniform(500)));
    
    // resize the coin sprite
    [self resizeSprite:coin toWidth:25 toHeight:25];

    
    // add coin to physicsNode
    [_physicsNode addChild:coin];
    
}


-(void) touchBegan:(CCTouch *)touch withEvent:(UIEvent *)event
{
    // Stop an action by tag to avoid having multiple move
    [_playerNode stopActionByTag:1];
    // allows the character to move about the full extents of the _levelNode
    CGPoint pos = [touch locationInNode:_levelNode];
    CCAction* move = [CCActionMoveTo actionWithDuration:1.2 position:pos];
    move.tag = 1;
    // apply the move action
    [_playerNode runAction:move];
}


-(void) update:(CCTime)delta
{
    // update scroll node position to player node, with offset to center player in the view
    [self scrollToTarget:_playerNode];
}

-(void) scrollToTarget:(CCNode*)target
{
    // assign the size of the view to viewSize,
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    // the center point of the view is calculated and assigned to viewCenter
    CGPoint viewCenter = CGPointMake(viewSize.width / 2.0, viewSize.height / 2.0);
    // keeps the target node centered in the view
    CGPoint viewPos = ccpSub(target.positionInPoints, viewCenter);
    // clamp the viewPos to the level’s size using the MIN and MAX macros
    CGSize levelSize = _levelNode.contentSizeInPoints;
    viewPos.x = MAX(0.0, MIN(viewPos.x, levelSize.width - viewSize.width));
    viewPos.y = MAX(0.0, MIN(viewPos.y, levelSize.height - viewSize.height));
    _levelNode.positionInPoints = ccpNeg(viewPos);
}

-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height {
    // resize the coin sprite
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
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
    
    // if collision happens between coin and character, remove the last stone in the array
    if (energy > -100.f) {
        [[_physicsNode space] addPostStepBlock:^{
            [self coinRemoved:nodeA];
            CCNode *stone = [stones objectAtIndex:[stones count] - 1];
            [self stoneRemoved:stone];
        } key:nodeA];
    }
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Stone:(CCNode *)nodeA Character:(CCNode *)nodeB
{
    
    float energy = [pair totalKineticEnergy];
    
    // if collison happens between stone and character, call game over method
    if (energy > -100.f) {
        [self gameOver];
    }
}

- (void)gameOver {
    // set restart, shareFB button and gameOver sprite visible, set myTimer invalidate
    _RestartButton.visible = TRUE;
    _ShareFB.visible = TRUE;
    _gameOver.visible = TRUE;
    self.userInteractionEnabled = NO;
    [myTimer invalidate];
}

- (void)restart {
    // restart the game by reloading game scene
    CCScene *scene = [CCBReader loadAsScene:@"GameScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)fb {
    
    // construct a FB url to post the game website on my time line
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    
    // this should link to FB page for your app or AppStore link if published
    content.contentURL = [NSURL URLWithString:@"https://www.facebook.com/makeschool"];
    // URL of image to be displayed alongside post
    content.imageURL = [NSURL URLWithString:@"https://git.makeschool.com/MakeSchool-Tutorials/News/f744d331484d043a373ee2a33d63626c352255d4//663032db-cf16-441b-9103-c518947c70e1/cover_photo.jpeg"];
    // title of post
    content.contentTitle = [NSString stringWithFormat:@"My lucky number is %d", seconds];
    // description/body of post
    content.contentDescription = @"Check out My Lucky Number to get your own.";
    
    [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
                                 withContent:content
                                    delegate:nil];
    
//    NSString *score = [NSString stringWithFormat:@"%d",seconds];
//    NSLog(@"%@", score);
//    NSString *urlString = @"space walker";
//    NSString *title = [NSString stringWithFormat:@"%@,%@", @"My score is: ", score];
//    
//    NSString *shareUrlString = [NSString stringWithFormat:@"http://www.facebook.com/sharer.php?u=%@&t=%@", urlString , title];
//    shareUrlString = [shareUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [[NSURL alloc] initWithString:shareUrlString];
//    [[UIApplication sharedApplication] openURL:url];
    
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    content.contentURL = [NSURL URLWithString:@"https://developers.facebook.com"];
//    
//    FBSDKShareButton *button = [[FBSDKShareButton alloc] init];
//    button.shareContent = content;
//    [self.view addSubview:button];
    

    
//    FBSDKShareButton *button = [[FBSDKShareButton alloc] init];
//    button.shareContent = content;
//    [self.view addSubview:button];
}


@end
