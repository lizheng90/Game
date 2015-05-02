#import "MainScene.h"

@implementation MainScene

- (void)playnow {
    CCScene *gameplay = [CCBReader loadAsScene:@"GameScene"];
    [[CCDirector sharedDirector] replaceScene:gameplay];
}

@end
