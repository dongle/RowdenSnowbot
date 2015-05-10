//
//  ViewController.m
//  RowdenSnowbot
//
//  Created by Jonathan Beilin on 5/9/15.
//  Copyright (c) 2015 com.stupid.snowbot. All rights reserved.
//

//- replaceCurrentItemWithPlayerItem:

//AVPlayerItemDidPlayToEndTimeNotification
//AVPlayerItemFailedToPlayToEndTimeNotification
//AVPlayerItemTimeJumpedNotification
//AVPlayerItemPlaybackStalledNotification
//AVPlayerItemNewAccessLogEntryNotification
//AVPlayerItemNewErrorLogEntryNotification

#import "ViewController.h"

#import "PlayerView.h"


@interface ViewController ()

@property (strong) SRWebSocket *webSocket;

@property (strong) AVPlayer *player;
@property (strong) AVPlayerItem *playerItem;
@property (strong) PlayerView *playerView;

@property (strong) NSArray *yesVideos;
@property (strong) NSArray *idleVideos;

@end

typedef NS_ENUM(NSInteger, VideoCategory) {
    VideoYES,
    VideoNO,
    VideoMAYBE,
    VideoSILENT,
    VideoFREEDOM,
    VideoNSA,
    VideoCONSTITUTION,
    VideoDANGER,
    VideoBRAGGING,
};

@implementation ViewController

- (id)init {
    self = [super init];
    if (self) {

        self.player = [[AVPlayer alloc] init];
    //    NSLog(@"compatible types %@", [AVURLAsset audiovisualTypes]);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avplayerFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [self.view addSubview:_playerView];
        
        self.yesVideos = [[NSMutableArray alloc] init];
        self.idleVideos = [[NSMutableArray alloc] init];
        
        [self connectWebSocket];
    }
    return self;
}

// WEBSOCKET
- (void)connectWebSocket {
    self.webSocket.delegate = nil;
    self.webSocket = nil;
    
    NSString *urlString = @"ws://localhost:8080";
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.webSocket.delegate = self;
    
    [self.webSocket open];
}

#pragma mark - SRWebSocket delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"received websocket message: %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    [self.webSocket send:[NSString stringWithFormat:@"Hello from %@", [UIDevice currentDevice].name]];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self connectWebSocket];
}

// AVPLAYER

- (void)avplayerFinished {
    NSLog(@"Finished!");
}


// LIFECYCLE
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
