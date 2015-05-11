//
//  ViewController.m
//  RowdenSnowbot
//
//  Created by Jonathan Beilin on 5/9/15.
//  Copyright (c) 2015 com.stupid.snowbot. All rights reserved.
//

#import "ViewController.h"

#import "PlayerView.h"


@interface ViewController ()

@property (strong) SRWebSocket *webSocket;

@property (strong) AVPlayer *player;
@property (strong) AVPlayerItem *playerItem;
@property (strong) PlayerView *playerView;

@property (strong) NSMutableArray *videosIntro;
@property (strong) NSMutableArray *videosYes;
@property (strong) NSMutableArray *videosNo;
@property (strong) NSMutableArray *videosSilent;
@property (strong) NSMutableArray *videosLiberty;
@property (strong) NSMutableArray *videosNSA;
@property (strong) NSMutableArray *videosThreats;
@property (strong) NSMutableArray *videosBragging;
@property (strong) NSMutableArray *videosCondescension;
@property (strong) NSMutableArray *videosFactual;
@property (strong) NSMutableArray *videosNudity;
@property (strong) NSMutableArray *videosPress;

@property (strong) NSTimer *timer;

@end

typedef NS_ENUM(NSInteger, VideoCategory) {
    VideoINTRO,
    VideoYES,
    VideoNO,
    VideoSILENT,
    VideoLIBERTY,
    VideoNSA,
    VideoTHREATS,
    VideoBRAGGING,
    VideoCONDESCENSION,
    VideoFACTUAL,
    VideoNUDITY,
    VideoPRESS
};

@implementation ViewController

// LIFECYCLE

- (id)init {
    self = [super init];
    if (self) {
        
        self.view.frame = [[UIScreen mainScreen] bounds];
        self.view.backgroundColor = [UIColor blackColor];
        
        // SET UP ARRAYS
        self.videosIntro = [[NSMutableArray alloc] init];
        self.videosYes = [[NSMutableArray alloc] init];
        self.videosNo = [[NSMutableArray alloc] init];
        self.videosSilent = [[NSMutableArray alloc] init];
        self.videosNSA = [[NSMutableArray alloc] init];
        self.videosLiberty = [[NSMutableArray alloc] init];
        self.videosThreats = [[NSMutableArray alloc] init];
        self.videosBragging = [[NSMutableArray alloc] init];
        self.videosCondescension = [[NSMutableArray alloc] init];
        self.videosFactual = [[NSMutableArray alloc] init];
        self.videosNudity = [[NSMutableArray alloc] init];
        self.videosPress = [[NSMutableArray alloc] init];
        
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *clipsPath = [resourcePath stringByAppendingPathComponent:@"snowclips"];
        
        // set up arrays
        NSString *silentPath = [clipsPath stringByAppendingPathComponent:@"idle"];
        [self addFilesFromDirectory:silentPath toArray:self.videosSilent];
        
        NSString *introPath = [clipsPath stringByAppendingPathComponent:@"intro"];
        [self addFilesFromDirectory:introPath toArray:self.videosIntro];
        
        NSString *yesPath = [clipsPath stringByAppendingPathComponent:@"yes"];
        [self addFilesFromDirectory:yesPath toArray:self.videosYes];
        
        NSString *noPath = [clipsPath stringByAppendingPathComponent:@"no"];
        [self addFilesFromDirectory:noPath toArray:self.videosNo];
        
        NSString *libertyPath = [clipsPath stringByAppendingPathComponent:@"liberty"];
        [self addFilesFromDirectory:libertyPath toArray:self.videosLiberty];
        
        NSString *nsaPath = [clipsPath stringByAppendingPathComponent:@"nsa"];
        [self addFilesFromDirectory:nsaPath toArray:self.videosNSA];

        NSString *threatsPath = [clipsPath stringByAppendingPathComponent:@"threats"];
        [self addFilesFromDirectory:threatsPath toArray:self.videosThreats];
        
        NSString *braggingPath = [clipsPath stringByAppendingPathComponent:@"bragging"];
        [self addFilesFromDirectory:braggingPath toArray:self.videosBragging];

        NSString *condescensionPath = [clipsPath stringByAppendingPathComponent:@"condescension"];
        [self addFilesFromDirectory:condescensionPath toArray:self.videosCondescension];

        NSString *factualPath = [clipsPath stringByAppendingPathComponent:@"factualstatements"];
        [self addFilesFromDirectory:factualPath toArray:self.videosFactual];
        
        NSString *nudityPath = [clipsPath stringByAppendingPathComponent:@"nudity"];
        [self addFilesFromDirectory:nudityPath toArray:self.videosNudity];

        NSString *pressPath = [clipsPath stringByAppendingPathComponent:@"press"];
        [self addFilesFromDirectory:pressPath toArray:self.videosPress];

        
        // SET UP PLAYER
        
        self.player = [[AVPlayer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avplayerFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        self.playerView = [[PlayerView alloc] initWithFrame:self.view.frame];
        self.playerView.backgroundColor = [UIColor blackColor];
        self.playerView.player = self.player;
        [self.view addSubview:self.playerView];
        [self playVideo:VideoSILENT];
        
        // SET UP WEBSOCKET
        
        [self connectWebSocket];
        self.timer = [NSTimer timerWithTimeInterval:15.0 target:self selector:@selector(webSocketKeepAlive) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// UTILITY
                  
- (void)addFilesFromDirectory:(NSString *)directory toArray:(NSMutableArray *)array {
    NSError *error;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    
    for (NSString *file in directoryContents) {
        NSString *filePath = [directory stringByAppendingPathComponent:file];
        //            NSLog(@"file: %@", filePath);
        [array addObject:filePath];
    }
}

// WEBSOCKET
- (void)connectWebSocket {
    self.webSocket.delegate = nil;
    self.webSocket = nil;
    
    NSString *urlString = @"ws://robot-snowden.herokuapp.com/client/listen";
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.webSocket.delegate = self;
    
    [self.webSocket open];
}

#pragma mark - SRWebSocket delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSString *rawCategory = (NSString *) message;

    VideoCategory category;
    
    if (rawCategory == nil || ![message isKindOfClass:[NSString class]]) return;
    
    if ([rawCategory  isEqual: @"intro"]) {
        category = VideoINTRO;
    } else if ([rawCategory  isEqual: @"yes"]) {
        category = VideoYES;
    } else if ([rawCategory  isEqual: @"no"]) {
        category = VideoNO;
    } else if ([rawCategory  isEqual: @"idle"]) {
        category = VideoSILENT;
    } else if ([rawCategory  isEqual: @"nsa"]) {
        category = VideoNSA;
    } else if ([rawCategory  isEqual: @"liberty"]) {
        category = VideoLIBERTY;
    } else if ([rawCategory  isEqual: @"threats"]) {
        category = VideoTHREATS;
    } else if ([rawCategory  isEqual: @"bragging"]) {
        category = VideoBRAGGING;
    } else if ([rawCategory  isEqual: @"condescension"]) {
        category = VideoCONDESCENSION;
    } else if ([rawCategory  isEqual: @"factualstatements"]) {
        category = VideoFACTUAL;
    } else if ([rawCategory  isEqual: @"nudity"]) {
        category = VideoNUDITY;
    } else if ([rawCategory  isEqual: @"press"]) {
        category = VideoPRESS;
    } else {
        category = VideoSILENT;
    }
    
    [self playVideo:category];
}

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    [self.webSocket send:[NSString stringWithFormat:@"Hello from %@", [UIDevice currentDevice].name]];
    NSLog(@"timer started; websocket opened");
    [self.timer fire];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self.timer invalidate];
    NSLog(@"timer invalidated; websocket failed");
    [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self.timer invalidate];
    NSLog(@"timer invalidated; websocket closed");
    [self connectWebSocket];
}

- (void)webSocketKeepAlive {
    [self.webSocket send:[NSString stringWithFormat:@"Ping from %@", [UIDevice currentDevice].name]];
}

// AVPLAYER

- (void)avplayerFinished {
    [self playVideo:VideoSILENT];
}

- (void)playVideo:(VideoCategory)category {
    NSMutableArray *videoArray = nil;
    
    switch (category) {
        case VideoINTRO:
            videoArray = self.videosIntro;
            break;
        case VideoNO:
            videoArray = self.videosNo;
            break;
        case VideoNSA:
            videoArray = self.videosNSA;
            break;
        case VideoSILENT:
            videoArray = self.videosSilent;
            break;
        case VideoYES:
            videoArray = self.videosYes;
            break;
        case VideoLIBERTY:
            videoArray = self.videosLiberty;
            break;
        case VideoTHREATS:
            videoArray = self.videosThreats;
            break;
        case VideoBRAGGING:
            videoArray = self.videosBragging;
            break;
        case VideoCONDESCENSION:
            videoArray = self.videosCondescension;
            break;
        case VideoFACTUAL:
            videoArray = self.videosFactual;
            break;
        case VideoNUDITY:
            videoArray = self.videosNudity;
            break;
        case VideoPRESS:
            videoArray = self.videosPress;
            break;
    }

    if (videoArray == nil || [videoArray count] == 0) return;
    
    NSUInteger randomIndex = arc4random() % [videoArray count];
    NSString *videoPath = [videoArray objectAtIndex:randomIndex];
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:anItem];
    [self.player play];
}

@end
