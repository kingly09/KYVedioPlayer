//
//  KYLocalVideoPlayVC.m
//  KYVedioPlayer
//
//  Created by kingly on 16/9/9.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import "KYLocalVideoPlayVC.h"

#import "KYVedioPlayer.h"

@interface KYLocalVideoPlayVC ()<KYVedioPlayerDelegate>{
    KYVedioPlayer  *vedioPlayer;
    CGRect     playerFrame;
}

@end

@implementation KYLocalVideoPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    playerFrame = CGRectMake(0, 0, kScreenWidth, (kScreenWidth)*(0.75));
    vedioPlayer = [[KYVedioPlayer alloc]initWithFrame:playerFrame];
    vedioPlayer.delegate = self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    
    NSLog(@"path::%@",path);
    
    vedioPlayer.URLString = @"http://7rfkz6.com1.z0.glb.clouddn.com/480p_20150528_nubiaz9.mp4";
    vedioPlayer.titleLabel.text = self.title;
    vedioPlayer.closeBtn.hidden = NO;
    [self.view addSubview:vedioPlayer];
    [vedioPlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)releasePlayer
{

    [vedioPlayer pause];
    [vedioPlayer removeFromSuperview];
    [vedioPlayer.playerLayer removeFromSuperlayer];
    [vedioPlayer.player replaceCurrentItemWithPlayerItem:nil];
    
    vedioPlayer.player = nil;
    vedioPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [vedioPlayer.autoDismissTimer invalidate];
    vedioPlayer.autoDismissTimer = nil;
    
    vedioPlayer.playOrPauseBtn = nil;
    vedioPlayer.playerLayer = nil;
    vedioPlayer = nil;
}

- (void)dealloc
{
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"KYLocalVideoPlayVC deallco");
}

/**
 *  隐藏状态栏
 **/
-(BOOL)prefersStatusBarHidden{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma make - KYVedioPlayerDelegate 播放器委托方法
//点击播放暂停按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{

    NSLog(@"[KYVedioPlayer] clickedPlayOrPauseButton ");
}
//点击关闭按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedCloseButton:(UIButton *)closeBtn{

     NSLog(@"[KYVedioPlayer] clickedCloseButton ");
}
//点击全屏按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    NSLog(@"[KYVedioPlayer] clickedFullScreenButton ");
}
//单击WMPlayer的代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer singleTaped:(UITapGestureRecognizer *)singleTap{

     NSLog(@"[KYVedioPlayer] singleTaped ");
}
//双击WMPlayer的代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer doubleTaped:(UITapGestureRecognizer *)doubleTap{

     NSLog(@"[KYVedioPlayer] doubleTaped ");
}

///播放状态
//播放失败的代理方法
-(void)kyvedioPlayerFailedPlay:(KYVedioPlayer *)kyvedioPlayer playerStatus:(KYVedioPlayerState)state{
    NSLog(@"[KYVedioPlayer] kyvedioPlayerFailedPlay  播放失败");
}
//准备播放的代理方法
-(void)kyvedioPlayerReadyToPlay:(KYVedioPlayer *)kyvedioPlayer playerStatus:(KYVedioPlayerState)state{

    NSLog(@"[KYVedioPlayer] kyvedioPlayerReadyToPlay  准备播放");
}
//播放完毕的代理方法
-(void)kyplayerFinishedPlay:(KYVedioPlayer *)kyvedioPlayer{

      NSLog(@"[KYVedioPlayer] kyvedioPlayerReadyToPlay  播放完毕");
}

@end
