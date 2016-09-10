//
//  KYVedioPlayer.m
//  KYVedioPlayer
//
//  Created by kingly on 16/9/9.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import "KYVedioPlayer.h"


static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;

static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface KYVedioPlayer () <UIGestureRecognizerDelegate>
@property (nonatomic,assign)CGPoint firstPoint;
@property (nonatomic,assign)CGPoint secondPoint;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;

//视频进度条的单击事件
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, assign) BOOL isDragingSlider;//是否点击了按钮的响应事件
/**
 *  显示播放时间的UILabel
 */
@property (nonatomic,strong) UILabel        *leftTimeLabel;
@property (nonatomic,strong) UILabel        *rightTimeLabel;
/**
 * 亮度的进度条
 */
@property (nonatomic,strong) UISlider       *lightSlider;
@property (nonatomic,strong) UISlider       *progressSlider;
@property (nonatomic,strong) UISlider       *volumeSlider;
//系统滑条
@property (nonatomic,strong) UISlider       *systemSlider;
@property (nonatomic,strong) UITapGestureRecognizer* singleTap;  //单击

@property (nonatomic,strong) UIProgressView *loadingProgress;    //loading


@end

@implementation KYVedioPlayer

@synthesize isPlaying;

- (instancetype)init{
    self = [super init];
    if (self){
        [self initPlayer];
    }
    return self;
}

/**
 *  storyboard、xib的初始化方法
 */
- (void)awakeFromNib
{
    [self initPlayer];
}
/**
 *  initWithFrame的初始化方法
 */
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPlayer];
    }
    return self;
}
/**
 *  初始化KYVedioPlayer的控件，添加手势，添加通知，添加kvo等
 */
-(void)initPlayer{
    
    self.seekTime = 0.00;
    self.backgroundColor = [UIColor blackColor];
    //添加loading视图
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.loadingView];
    
    //添加顶部视图
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self addSubview:self.topView];
    
    //添加底部视图
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self addSubview:self.bottomView];
    
    //添加暂停和开启按钮
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    [self.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"video_pause_nor"] ?: [UIImage imageNamed:@"video_pause_nor"] forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"video_play_nor"] ?: [UIImage imageNamed:@"video_play_nor"] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.playOrPauseBtn];
    
    //创建亮度的进度条
    self.lightSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.lightSlider.hidden = YES;
    self.lightSlider.minimumValue = 0;
    self.lightSlider.maximumValue = 1;
    //进度条的值等于当前系统亮度的值,范围都是0~1
    self.lightSlider.value = [UIScreen mainScreen].brightness;
    [self addSubview:self.lightSlider];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    [self addSubview:volumeView];
    volumeView.frame = CGRectMake(-1000, -100, 100, 100);
    [volumeView sizeToFit];
    
    self.systemSlider = [[UISlider alloc]init];
    self.systemSlider.backgroundColor = [UIColor clearColor];
    for (UIControl *view in volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            self.systemSlider = (UISlider *)view;
        }
    }
    self.systemSlider.autoresizesSubviews = NO;
    self.systemSlider.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:self.systemSlider];
    
    //设置声音滑块
    self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.volumeSlider.tag = 1000;
    self.volumeSlider.hidden = YES;
    self.volumeSlider.minimumValue = self.systemSlider.minimumValue;
    self.volumeSlider.maximumValue = self.systemSlider.maximumValue;
    self.volumeSlider.value = self.systemSlider.value;
    [self.volumeSlider addTarget:self action:@selector(updateSystemVolumeValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.volumeSlider];
    
    //进度条
    self.progressSlider = [[UISlider alloc]init];
    self.progressSlider.minimumValue = 0.0;
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"ic_dot"] ?: [UIImage imageNamed:@"ic_dot"]  forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
    self.progressSlider.maximumTrackTintColor = [UIColor clearColor];
    self.progressSlider.value = 0.0;//指定初始值
    //进度条的拖拽事件
    [self.progressSlider addTarget:self action:@selector(stratDragSlide:)  forControlEvents:UIControlEventValueChanged];
    //进度条的点击事件
    [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside];
    //给进度条添加单击手势
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    self.tap.delegate = self;
    [self.progressSlider addGestureRecognizer:self.tap];
    self.progressSlider.backgroundColor = [UIColor clearColor];
    [self.bottomView addSubview:self.progressSlider];
    
    //loadingProgress
    self.loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadingProgress.progressTintColor = [UIColor clearColor];
    self.loadingProgress.trackTintColor    = [UIColor lightGrayColor];
    [self.bottomView addSubview:self.loadingProgress];
    [self.loadingProgress setProgress:0.0 animated:NO];
    
    //全屏按钮
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"video_fullscreen_nor"] ?: [UIImage imageNamed:@"video_fullscreen_nor"] forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"video_smallscreen_nor"] ?: [UIImage imageNamed:@"video_smallscreen_nor"] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.fullScreenBtn];
    
    //左边时间
    self.leftTimeLabel = [[UILabel alloc]init];
    self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    self.leftTimeLabel.backgroundColor = [UIColor clearColor];
    self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.leftTimeLabel];
    
    //右边时间
    self.rightTimeLabel = [[UILabel alloc]init];
    self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    self.rightTimeLabel.backgroundColor = [UIColor clearColor];
    self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.rightTimeLabel];

   
    //关闭按钮
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.showsTouchWhenHighlighted = YES;
    [_closeBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_closeBtn];
    
    //标题
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [self.topView addSubview:self.titleLabel];
    
    [self makeConstraints];
    
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTap.numberOfTapsRequired = 1; // 单击
    self.singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:self.singleTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
/**
 * 设置 autoLayout
 **/
-(void)makeConstraints{

    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    [self.loadingView startAnimating];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
        make.top.equalTo(self).with.offset(0);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self).with.offset(0);
        
    }];
    //让子视图自动适应父视图的方法
    [self setAutoresizesSubviews:NO];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.center.equalTo(self.bottomView);
    }];
    
    [self.loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressSlider);
        make.right.equalTo(self.progressSlider);
        make.center.equalTo(self.progressSlider);
        make.height.mas_equalTo(1.5);
    }];
    [self.bottomView sendSubviewToBack:self.loadingProgress];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).with.offset(0);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(40);
        
    }];
    
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];

    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];

    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(5);
        make.height.mas_equalTo(30);
        make.top.equalTo(self.topView).with.offset(5);
        make.width.mas_equalTo(30);
        
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(45);
        make.right.equalTo(self.topView).with.offset(-45);
        make.center.equalTo(self.topView);
        make.top.equalTo(self.topView).with.offset(0);
        
    }];
    
    [self bringSubviewToFront:self.loadingView];
    [self bringSubviewToFront:self.bottomView];


}

#pragma mark - lazy 加载失败的label
-(UILabel *)loadFailedLabel{
    if (_loadFailedLabel==nil) {
        _loadFailedLabel = [[UILabel alloc]init];
        _loadFailedLabel.textColor = [UIColor whiteColor];
        _loadFailedLabel.textAlignment = NSTextAlignmentCenter;
        _loadFailedLabel.text = @"视频加载失败";
        _loadFailedLabel.hidden = YES;
        [self addSubview:_loadFailedLabel];
        
        [_loadFailedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@30);
            
        }];
    }
    return _loadFailedLabel;
}

#pragma mark  - 私有方法
/**
 * 获取视频长度
 **/
- (double)duration{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([[playerItem asset] duration]);
    }
    else{
        return 0.f;
    }
}
/**
 * 设置当前播放的时间
 **/
- (void)setCurrentTime:(double)time{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToTime:CMTimeMakeWithSeconds(time, self.currentItem.currentTime.timescale)];
        
    });
}

/**
 *  重写URLString的setter方法，处理自己的逻辑，
 */
- (void)setURLString:(NSString *)URLString{
    _URLString = URLString;
    //设置player的参数
    self.currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:URLString]];
    
    self.player = [AVPlayer playerWithPlayerItem:_currentItem];
    self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
    //AVPlayerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.layer.bounds;
    //视频的默认填充模式，AVLayerVideoGravityResizeAspect
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer insertSublayer:_playerLayer atIndex:0];
    self.state = KYVedioPlayerStateBuffering;
    
    if (self.closeBtnStyle==CloseBtnStylePop) {
        [_closeBtn setImage:[UIImage imageNamed:@"video_nav_back_nor"] ?: [UIImage imageNamed:@"video_nav_back_nor"] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:@"video_nav_back_nor"] ?: [UIImage imageNamed:@"video_nav_back_nor"] forState:UIControlStateSelected];
        
    }else{
        [_closeBtn setImage:[UIImage imageNamed:@"ic_close"] ?: [UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:@"ic_close"] ?: [UIImage imageNamed:@"ic_close"] forState:UIControlStateSelected];
    }
}

/**
 *  设置播放的状态
 *  @param state KYVedioPlayerState
 */
- (void)setState:(KYVedioPlayerState )state
{
    _state = state;
    // 控制菊花显示、隐藏
    if (state == KYVedioPlayerStateBuffering) {
        [self.loadingView startAnimating];
    }else if(state == KYVedioPlayerStatePlaying){
        [self.loadingView stopAnimating];
    }else if(state == KYVedioPlayerStatusReadyToPlay){
        [self.loadingView stopAnimating];
    }
    else{
        [self.loadingView stopAnimating];
    }
}



#pragma mark - 播放 或者 暂停
- (void)PlayOrPause:(UIButton *)sender{
    if (self.player.rate != 1.f) {
        if ([self currentTime] == [self duration])
            [self setCurrentTime:0.f];
        sender.selected = NO;
        [self.player play];
    } else {
        sender.selected = YES;
        [self.player pause];
    }
    if ([self.delegate respondsToSelector:@selector(kyvedioPlayer:clickedPlayOrPauseButton:)]) {
        [self.delegate kyvedioPlayer:self clickedPlayOrPauseButton:sender];
    }
}

#pragma mark - 更新系统音量
- (void)updateSystemVolumeValue:(UISlider *)slider{
    self.systemSlider.value = slider.value;
}

#pragma mark - 进度条的相关事件 progressSlider 
/**
 *   开始点击sidle
 **/
- (void)stratDragSlide:(UISlider *)slider{
    self.isDragingSlider = YES;
    self.isDragingSlider = NO;
    
}
/**
 *   更新播放进度
 **/
- (void)updateProgress:(UISlider *)slider{
    self.isDragingSlider = NO;
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, _currentItem.currentTime.timescale)];
    
}
/**
 *  视频进度条的点击事件
 **/
- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:self.progressSlider];
    CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchLocation.x/self.progressSlider.frame.size.width);
    [self.progressSlider setValue:value animated:YES];
    
    [self.player seekToTime:CMTimeMakeWithSeconds(self.progressSlider.value, self.currentItem.currentTime.timescale)];
    if (self.player.rate != 1.f) {
        if ([self currentTime] == [self duration])
            [self setCurrentTime:0.f];
        self.playOrPauseBtn.selected = NO;
        [self.player play];
    }
}

#pragma mark  -  点击全屏按钮 和 点击缩小按钮
/**
 *   点击全屏按钮 和 点击缩小按钮
 **/
-(void)fullScreenAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(kyvedioPlayer:clickedFullScreenButton:)]) {
        [self.delegate kyvedioPlayer:self clickedFullScreenButton:sender];
    }
}

#pragma mark - 点击关闭按钮
/**
 *   点击关闭按钮
 **/
-(void)colseTheVideo:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(kyvedioPlayer:clickedCloseButton:)]) {
        [self.delegate kyvedioPlayer:self clickedCloseButton:sender];
    }
}
#pragma mark - 单击播放器 手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissBottomView:) object:nil];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(kyvedioPlayer:singleTaped:)]) {
        [self.delegate kyvedioPlayer:self singleTaped:sender];
    }
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomView.alpha == 0.0) {
            self.bottomView.alpha = 1.0;
            self.closeBtn.alpha = 1.0;
            self.topView.alpha = 1.0;
            
        }else{
            self.bottomView.alpha = 0.0;
            self.closeBtn.alpha = 0.0;
            self.topView.alpha = 0.0;
            
        }
    } completion:^(BOOL finish){
        
    }];
}

/**
 * 隐藏 底部视图
 **/
-(void)autoDismissBottomView:(NSTimer *)timer{
    
    if (self.player.rate==.0f&&self.currentTime != self.duration) {//暂停状态
        
    }else if(self.player.rate==1.0f){
        if (self.bottomView.alpha==1.0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.bottomView.alpha = 0.0;
                self.closeBtn.alpha = 0.0;
                self.topView.alpha = 0.0;
                
            } completion:^(BOOL finish){
                
            }];
        }
    }
}
#pragma mark - 双击播放器 手势方法
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(kyvedioPlayer:doubleTaped:)]) {
        [self.delegate kyvedioPlayer:self doubleTaped:doubleTap];
    }
    if (self.player.rate != 1.f) {
        if ([self currentTime] == self.duration)
            [self setCurrentTime:0.f];
        [self.player play];
        self.playOrPauseBtn.selected = NO;
    } else {
        [self.player pause];
        self.playOrPauseBtn.selected = YES;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 1.0;
        self.topView.alpha = 1.0;
        self.closeBtn.alpha = 1.0;
        
    } completion:^(BOOL finish){
        
    }];
}


#pragma mark NSNotification 消息通知接收 

- (void)appwillResignActive:(NSNotification *)note
{
    NSLog(@"appwillResignActive");
}

- (void)appBecomeActive:(NSNotification *)note
{
    NSLog(@"appBecomeActive");
}
/**
 * 进入后台
 **/
- (void)appDidEnterBackground:(NSNotification*)note
{
    if (self.playOrPauseBtn.isSelected==NO) {//如果是播放中，则继续播放
        NSArray *tracks = [self.currentItem tracks];
        for (AVPlayerItemTrack *playerItemTrack in tracks) {
            if ([playerItemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual]) {
                playerItemTrack.enabled = YES;
            }
        }
        self.playerLayer.player = nil;
        [self.player play];
        self.state = KYVedioPlayerStatePlaying;
    }else{
        self.state = KYVedioPlayerStateStopped;
    }
}
/**
 *  进入前台
 **/
- (void)appWillEnterForeground:(NSNotification*)note
{
    if (self.playOrPauseBtn.isSelected==NO) {//如果是播放中，则继续播放
        NSArray *tracks = [self.currentItem tracks];
        for (AVPlayerItemTrack *playerItemTrack in tracks) {
            if ([playerItemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual]) {
                playerItemTrack.enabled = YES;
            }
        }
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.layer insertSublayer:_playerLayer atIndex:0];
        [self.player play];
        self.state = KYVedioPlayerStatePlaying;
        
    }else{
        self.state = KYVedioPlayerStateStopped;
    }
}


#pragma mark - 对外方法
/**
 *  播放
 */
- (void)play{
     [self PlayOrPause:self.playOrPauseBtn];
}

/**
 * 暂停
 */
- (void)pause{
     [self PlayOrPause:self.playOrPauseBtn];
}
/**
 * 是否正在播放中
 * @return BOOL YES 正在播放 NO 不在播放中
 **/
- (BOOL)isPlaying {
    if (_player && _player.rate != 0) {
        return YES;
    }
    return NO;
}
/**
 *  获取正在播放的时间点
 *
 *  @return double的一个时间点
 */
- (double)currentTime{
    if (self.player) {
        return CMTimeGetSeconds([self.player currentTime]);
    }else{
        return 0.0;
    }
}

#pragma mark - 重置播放器 或 销毁
/**
 * 重置播放器
 */
- (void )resetKYVedioPlayer{

    self.currentItem = nil;
    self.seekTime = 0;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 关闭定时器
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    // 暂停
    [self.player pause];
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    // 把player置为nil
    self.player = nil;

}


-(void)dealloc{
    
    NSLog(@"KYVedioPlayer dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player pause];
    
    [self.player removeTimeObserver:self.playbackTimeObserver];
    
    //移除观察者
    [_currentItem removeObserver:self forKeyPath:@"status"];
    [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.currentItem = nil;
    self.playOrPauseBtn = nil;
    self.playerLayer = nil;
    
    self.autoDismissTimer = nil;
    
}

@end
