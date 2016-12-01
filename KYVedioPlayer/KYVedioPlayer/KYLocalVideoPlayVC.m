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
    if (_URLString.length == 0) {
        _URLString  = path;
    }
    vedioPlayer.URLString = _URLString;
    vedioPlayer.titleLabel.text = self.title;
    vedioPlayer.closeBtn.hidden = NO;
    vedioPlayer.progressColor = [UIColor orangeColor];
    [self.view addSubview:vedioPlayer];
    [vedioPlayer play];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NotificationDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    self.navigationController.navigationBarHidden = YES;
    
}
-(void)viewDidDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
#pragma mark - KYVedioPlayerDelegate 播放器委托方法
//点击播放暂停按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{

    NSLog(@"[KYVedioPlayer] clickedPlayOrPauseButton ");
}
//点击关闭按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedCloseButton:(UIButton *)closeBtn{

     NSLog(@"[KYVedioPlayer] clickedCloseButton ");
    if (kyvedioPlayer.isFullscreen == YES) {
        [self setNeedsStatusBarAppearanceUpdate];
        [kyvedioPlayer showSmallScreenWithPlayer:kyvedioPlayer withFatherView:self.view withFrame:playerFrame];
        
    }else{
        
        [self releasePlayer];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//点击分享按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer onClickShareBtn:(UIButton *)closeBtn{
  
  NSLog(@"[KYVedioPlayer] onClickShareBtn ");

}
//点击全屏按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    NSLog(@"[KYVedioPlayer] clickedFullScreenButton ");
    
    if (fullScreenBtn.isSelected) {//全屏显示

        kyvedioPlayer.isFullscreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [kyvedioPlayer showFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft player:kyvedioPlayer withFatherView:self.view];
    }else{
    
         [self setNeedsStatusBarAppearanceUpdate];
        [kyvedioPlayer showSmallScreenWithPlayer:kyvedioPlayer withFatherView:self.view withFrame:playerFrame];
    }

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

#pragma mark - NotificationDeviceOrientationChange
-(void)NotificationDeviceOrientationChange:(NSNotification *)notification{

    if (vedioPlayer == nil|| vedioPlayer.superview==nil){
        return;
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            if (vedioPlayer.isFullscreen) {
                [self setNeedsStatusBarAppearanceUpdate];
                [vedioPlayer showSmallScreenWithPlayer:vedioPlayer withFatherView:self.view withFrame:playerFrame];
                
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            vedioPlayer.isFullscreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [vedioPlayer showFullScreenWithInterfaceOrientation:interfaceOrientation player:vedioPlayer withFatherView:self.view];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            vedioPlayer.isFullscreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [vedioPlayer showFullScreenWithInterfaceOrientation:interfaceOrientation player:vedioPlayer withFatherView:self.view];
        }
            break;
        default:
            break;
    }

}
@end
