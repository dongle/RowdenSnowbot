//
//  PlayerView.m
//  RowdenSnowbot
//
//  Created by Jonathan Beilin on 5/9/15.
//  Copyright (c) 2015 com.stupid.snowbot. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end
