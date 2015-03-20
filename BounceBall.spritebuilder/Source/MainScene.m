#import "MainScene.h"

@implementation MainScene

- (void)play {
    CCScene *gameplay = [CCBReader loadAsScene:@"GamePlay"];
    [[CCDirector sharedDirector] replaceScene:gameplay];
}

@end
