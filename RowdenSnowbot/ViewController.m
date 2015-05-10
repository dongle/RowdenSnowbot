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

@property (strong) NSMutableArray *videosIntro;
@property (strong) NSMutableArray *videosYes;
@property (strong) NSMutableArray *videosNo;
@property (strong) NSMutableArray *videosMaybe;
@property (strong) NSMutableArray *videosSilent;
@property (strong) NSMutableArray *videosFreedom;
@property (strong) NSMutableArray *videosNSA;
@property (strong) NSMutableArray *videosCompanies;
@property (strong) NSMutableArray *videosDanger;
@property (strong) NSMutableArray *videosHotshit;
@property (strong) NSMutableArray *videosWhy;

@property (strong) NSTimer *timer;

@end

typedef NS_ENUM(NSInteger, VideoCategory) {
    VideoINTRO,
    VideoYES,
    VideoNO,
    VideoMAYBE,
    VideoSILENT,
    VideoFREEDOM,
    VideoNSA,
    VideoCOMPANIES,
    VideoDANGER,
    VideoHOTSHIT,
    VideoWHY
};

@implementation ViewController

- (id)init {
    self = [super init];
    if (self) {
        
        self.view.frame = [[UIScreen mainScreen] bounds];
        NSLog(@"vc frame: %@", NSStringFromCGRect(self.view.frame));
        self.view.backgroundColor = [UIColor blackColor];
        
        // SET UP ARRAYS
        self.videosIntro = [[NSMutableArray alloc] init];
        self.videosYes = [[NSMutableArray alloc] init];
        self.videosNo = [[NSMutableArray alloc] init];
        self.videosMaybe = [[NSMutableArray alloc] init];
        self.videosSilent = [[NSMutableArray alloc] init];
        self.videosFreedom = [[NSMutableArray alloc] init];
        self.videosNSA = [[NSMutableArray alloc] init];
        self.videosCompanies = [[NSMutableArray alloc] init];
        self.videosDanger = [[NSMutableArray alloc] init];
        self.videosHotshit = [[NSMutableArray alloc] init];
        self.videosWhy = [[NSMutableArray alloc] init];
        
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
//        NSLog(@"resourcePath: %@", resourcePath);
        
        
        // set up silent
        NSString *clipsPath = [resourcePath stringByAppendingPathComponent:@"snowclips"];
//        NSLog(@"clipspath: %@", clipsPath);
        
        NSError *error;
        NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:clipsPath error:&error];
//        NSLog(@"clipscontents: %@", directoryContents);
        
        for (NSString *file in directoryContents) {
            NSString *filePath = [clipsPath stringByAppendingPathComponent:file];
//            NSLog(@"file: %@", filePath);
            [self.videosSilent addObject:filePath];
        }
        
        // SET UP PLAYER
        
        self.player = [[AVPlayer alloc] init];
    //    NSLog(@"compatible types %@", [AVURLAsset audiovisualTypes]);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avplayerFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        self.playerView = [[PlayerView alloc] initWithFrame:self.view.frame];
        self.playerView.backgroundColor = [UIColor blackColor];
        self.playerView.player = self.player;
        [self.view addSubview:self.playerView];
        NSLog(@"playerview: %@", self.playerView);
        [self playVideo:VideoSILENT];
        
        // SET UP WEBSOCKET
        [self connectWebSocket];
        self.timer = [NSTimer timerWithTimeInterval:15.0 target:self selector:@selector(webSocketKeepAlive) userInfo:nil repeats:YES];
    }
    return self;
}
                  
- (void)addFilesFromDirectory:(NSString *)directory toArray:(NSMutableArray *)array {
    
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
    NSLog(@"received websocket message: %@", message);
    
    NSString *rawCategory = @"danger";
    VideoCategory category;
    
    if ([rawCategory  isEqual: @"intro"]) {
        category = VideoINTRO;
    } else if ([rawCategory  isEqual: @"yes"]) {
        category = VideoYES;
    } else if ([rawCategory  isEqual: @"no"]) {
        category = VideoNO;
    } else if ([rawCategory  isEqual: @"maybe"]) {
        category = VideoMAYBE;
    } else if ([rawCategory  isEqual: @"silent"]) {
        category = VideoSILENT;
    } else if ([rawCategory  isEqual: @"freedom"]) {
        category = VideoFREEDOM;
    } else if ([rawCategory  isEqual: @"nsa"]) {
        category = VideoNSA;
    } else if ([rawCategory  isEqual: @"companies"]) {
        category = VideoCOMPANIES;
    } else if ([rawCategory  isEqual: @"danger"]) {
        category = VideoDANGER;
    } else if ([rawCategory  isEqual: @"hotshit"]) {
        category = VideoHOTSHIT;
    } else if ([rawCategory  isEqual: @"why"]) {
        category = VideoWHY;
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
//    NSLog(@"Finished!");
    [self playVideo:VideoSILENT];
}

- (void)playVideo:(VideoCategory)category {
    NSMutableArray *videoArray = nil;
    
    switch (category) {
        case VideoCOMPANIES:
            videoArray = self.videosCompanies;
            break;
        case VideoDANGER:
            videoArray = self.videosDanger;
            break;
        case VideoFREEDOM:
            videoArray = self.videosFreedom;
            break;
        case VideoHOTSHIT:
            videoArray = self.videosHotshit;
            break;
        case VideoINTRO:
            videoArray = self.videosIntro;
            break;
        case VideoMAYBE:
            videoArray = self.videosMaybe;
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
        case VideoWHY:
            videoArray = self.videosWhy;
            break;
        case VideoYES:
            videoArray = self.videosYes;
            break;
    }

    if (videoArray == nil || [videoArray count] == 0) return;
    
    NSUInteger randomIndex = arc4random() % [videoArray count];
    NSString *videoPath = [videoArray objectAtIndex:randomIndex];
//    NSLog(@"video: %@", videoPath);
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self.player replaceCurrentItemWithPlayerItem:anItem];
    [self.player play];
}


// LIFECYCLE
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
