//
//  KYRememberLastPlayedVC.m
//  KYVedioPlayer
//
//  Created by kingly on 16/9/9.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import "KYRememberLastPlayedVC.h"

#define TheUserDefaults [NSUserDefaults standardUserDefaults]

@interface KYRememberLastPlayedVC ()<KYVedioPlayerDelegate>{
    KYVedioPlayer  *vedioPlayer;
    CGRect     playerFrame;
    NSString *URLString;
}

@end

@implementation KYRememberLastPlayedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    playerFrame = CGRectMake(0, 0, kScreenWidth, (kScreenWidth)*(0.75));
    vedioPlayer = [[KYVedioPlayer alloc]initWithFrame:playerFrame];
    vedioPlayer.delegate = self;
    
    URLString = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
    if ([TheUserDefaults doubleForKey:URLString]) {//如果有存上次播放的时间点记录，直接跳到上次纪录时间点播放
        double time = [TheUserDefaults doubleForKey:URLString];
        vedioPlayer.seekTime = time;
    }
    [vedioPlayer setURLString:URLString];

    vedioPlayer.titleLabel.text = self.title;
    vedioPlayer.closeBtn.hidden = NO;
    vedioPlayer.progressColor = [UIColor orangeColor];
    [self.view addSubview:vedioPlayer];
    [vedioPlayer play];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 *  注销播放器
 **/
- (void)releasePlayer
{
    [vedioPlayer resetKYVedioPlayer];
    vedioPlayer = nil;
}

- (void)dealloc
{
    //记录播放的时间
    double time = [vedioPlayer currentTime];
    [TheUserDefaults setDouble:time forKey:URLString];
    
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"KYRememberLastPlayedVC dealloc");
}

/**
 *  隐藏状态栏
 **/
-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - KYVedioPlayerDelegate 播放器委托方法
//点击播放暂停按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    
    NSLog(@"[KYVedioPlayer] clickedPlayOrPauseButton ");
}
//点击关闭按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedCloseButton:(UIButton *)closeBtn{
    
    NSLog(@"[KYVedioPlayer] clickedCloseButton ");
   
}

//点击分享按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer onClickShareBtn:(UIButton *)closeBtn{
  
  NSLog(@"[KYVedioPlayer] onClickShareBtn ");

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
