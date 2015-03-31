//
//  GamePlay.m
//  hide
//
//  Created by Zheng Li on 3/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "Character.h"

@implementation GamePlay

{
    CCPhysicsNode *_physicsNode;
    CCNode *character;
    
    CCLabelTTF *_time_label;
    int seconds;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    // create character
    [self launchCharacter];
    
    // generate stones every 5 seconds
    [self generateStone];
    
    seconds = 0;
    _time_label.visible = TRUE;
    
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                                      selector: @selector(callAfterOneSecond:) userInfo: nil repeats: YES];
    
//    [self addChild:_time_label];
//    [self addTime];
}

// called on every touch in this scene
- (void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    NSLog(@"begin");
    
//    CGPoint touchLocation = [touch locationInNode:character];
//    if (CGRectContainsPoint([character boundingBox], touchLocation))
//    {
//        
//    }
}

- (void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    // whenever touches move, update the position of character to the touch position
    CGPoint touchLocation = [touch locationInNode:character];
    character.position = touchLocation;
}

- (void) touchesEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    NSLog(@"Ended");
}

//-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"begin");
//}
//
//-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView: [touch view]];
//    location = [[CCDirector sharedDirector] convertToGL:location];
//    
//    
//    
//    character.position = location;
//    
//}
//
//-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"Ended");
//}


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
    [_physicsNode addChild:stone];
    
    // manually create & apply a force to launch the stone
    CGPoint launchDirection = ccp(arc4random_uniform(200), arc4random_uniform(200));
    CGPoint force = ccpMult(launchDirection, 1000);
    [stone.physicsBody applyForce:force];
}

-(void) callAfterOneSecond:(NSTimer*) t
{
    seconds++;
    NSLog(@"%d", seconds);
    _time_label.string = [NSString stringWithFormat:@"%d", seconds];
    _time_label.visible = TRUE;
}

//- (void)addTime {
//    while(TRUE) {
//        seconds++;
//        [_time_label setString:[NSString stringWithFormat:@"%d", seconds]];
//        [NSThread sleepForTimeInterval:1.0f];
//    }
//}

//- (void)showTime {
//    while (TRUE) {
//        seconds++;
//        NSLog(@"%d", seconds);
//        _time_label.string = [NSString stringWithFormat:@"%d", seconds];
////        _time_label.visible = TRUE;
//        [NSThread sleepForTimeInterval:1.0f];
//    }
//}



@end
