//
//  KYNetworkVideoCellPlayVC.m
//  KYVedioPlayer
//
//  Created by kingly on 16/9/9.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import "KYNetworkVideoCellPlayVC.h"
#import "KYLocalVideoPlayVC.h"
#import "KYVideo.h"
#import "KYNetworkVideoCell.h"

@interface KYNetworkVideoCellPlayVC ()<UITableViewDelegate, UITableViewDataSource,KYNetworkVideoCellDelegate,KYVedioPlayerDelegate>
@property (nonatomic, strong) UITableView		*tableView;
@property (nonatomic, strong) NSArray			*dataSource;

@end

@implementation KYNetworkVideoCellPlayVC{

     KYVedioPlayer *vedioPlayer;
     KYVideo *currentVideo;
     NSIndexPath *currentIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    if (vedioPlayer) {
        if (vedioPlayer.isFullscreen) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

-(KYNetworkVideoCell *)currentCell{
    if (currentIndexPath==nil) {
        return nil;
    }
    KYNetworkVideoCell *currentCell = (KYNetworkVideoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    return currentCell;
}

/**
 * 显示 从全屏来当前的cell视频
 **/
-(void)showCellCurrentVedioPlayer{

    if (currentVideo != nil &&  currentIndexPath != nil) {

        KYNetworkVideoCell *currentCell = [self currentCell];
        [vedioPlayer removeFromSuperview];

        [UIView animateWithDuration:0.5f animations:^{
            vedioPlayer.transform = CGAffineTransformIdentity;
            vedioPlayer.frame = currentCell.vedioBg.bounds;
            vedioPlayer.playerLayer.frame =  vedioPlayer.bounds;
            [currentCell.vedioBg addSubview:vedioPlayer];
            [currentCell.vedioBg bringSubviewToFront:vedioPlayer];
            [vedioPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vedioPlayer).with.offset(0);
                make.right.equalTo(vedioPlayer).with.offset(0);
                make.height.mas_equalTo(40);
                make.bottom.equalTo(vedioPlayer).with.offset(0);
            }];
            [vedioPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vedioPlayer).with.offset(0);
                make.right.equalTo(vedioPlayer).with.offset(0);
                make.height.mas_equalTo(40);
                make.top.equalTo(vedioPlayer).with.offset(0);
            }];
            [vedioPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vedioPlayer.topView).with.offset(45);
                make.right.equalTo(vedioPlayer.topView).with.offset(-45);
                make.center.equalTo(vedioPlayer.topView);
                make.top.equalTo(vedioPlayer.topView).with.offset(0);
            }];
            [vedioPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vedioPlayer).with.offset(5);
                make.height.mas_equalTo(30);
                make.width.mas_equalTo(30);
                make.top.equalTo(vedioPlayer).with.offset(5);
            }];
            [vedioPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(vedioPlayer);
                make.width.equalTo(vedioPlayer);
                make.height.equalTo(@30);
            }];
        }completion:^(BOOL finished) {
            vedioPlayer.isFullscreen = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            vedioPlayer.fullScreenBtn.selected = NO;

        }];
    }
}


#pragma  mark - 初始化方法
- (void)setUpView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = ({
        UITableView *tableView	= [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.delegate		= self;
        tableView.dataSource	= self;
        [tableView registerClass:[KYNetworkVideoCell class] forCellReuseIdentifier:[KYNetworkVideoCell cellReuseIdentifier]];
        tableView;
    });
    [self.view addSubview:self.tableView];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}
/**
 * Lazy 加载数据
 **/
- (NSArray *)dataSource {
    if (_dataSource) {
        return _dataSource;
    }
    NSString *path3gp = [[NSBundle mainBundle] pathForResource:@"贝加尔湖畔" ofType:@"3gp"];
    NSArray *arr = @[

                    @{@"title":@"视频一 mp4 格式",
                      @"image":@"http://vimg3.ws.126.net/image/snapshot/2016/9/L/1/VBVQVQRL1.jpg",
                      @"video":@"http://flv2.bn.netease.com/videolib3/1609/12/yRxoB7561/SD/yRxoB7561-mobile.mp4"},

                    @{@"title":@"视频二 m3u8格式",
                      @"image":@"http://vimg2.ws.126.net/image/snapshot/2016/9/7/7/VBV4B7Q77.jpg",
                      @"video":@"http://flv2.bn.netease.com/videolib3/1609/03/WotPc9077/SD/movie_index.m3u8"},

                    @{@"title":@"视频三 mov格式",
                      @"image":@"http://img2.cache.netease.com/m/3g/mengchong.png",
                      @"video":@"http://movies.apple.com/media/us/iphone/2010/tours/apple-iphone4-design_video-us-20100607_848x480.mov"},

                    @{@"title":@"视频四 3gp格式",
                      @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
                      @"video":path3gp},

                    @{@"title":@"视频五",
                      @"image":@"http://vimg3.ws.126.net/image/snapshot/2016/9/A/G/VBV4BB5AG.jpg",
                      @"video":@"http://flv2.bn.netease.com/videolib3/1609/03/GVRLQ8933/SD/movie_index.m3u8"},

                    @{@"title":@"视频六",
                      @"image":@"http://vimg3.ws.126.net/image/snapshot/2016/9/5/1/VBV4BEH51.jpg",
                      @"video":@"http://flv2.bn.netease.com/videolib3/1609/03/lGPqA9142/SD/lGPqA9142-mobile.mp4"},

                    @{@"title":@"视频七",
                      @"image":@"http://vimg3.ws.126.net/image/snapshot/2016/9/U/R/VBVQV83UR.jpg",
                      @"video":@"http://flv2.bn.netease.com/videolib3/1609/12/aOzvT5225/HD/movie_index.m3u8"},

                    ];

    NSMutableArray *arrVideo = [NSMutableArray array];
    for (NSDictionary *video in arr) {
        KYVideo *kYVideo = [[KYVideo alloc] init];
        kYVideo.title = [video objectForKey:@"title"];
        kYVideo.image = [video objectForKey:@"image"];
        kYVideo.video = [video objectForKey:@"video"];

        [arrVideo addObject:kYVideo];
    }
    _dataSource = arrVideo;
    return _dataSource;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    KYNetworkVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:[KYNetworkVideoCell cellReuseIdentifier]];
    if (nil==cell)
    {
        cell = [[KYNetworkVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[KYNetworkVideoCell cellReuseIdentifier]];

    }
    KYVideo *kYVideo  = self.dataSource[indexPath.row];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexPath = indexPath;
    cell.video = kYVideo;
    cell.mydelegate = self;
    cell.playBtn.tag = indexPath.row;

    if (vedioPlayer && vedioPlayer.superview) {
        if (indexPath.row == currentIndexPath.row) {
            [cell.playBtn.superview sendSubviewToBack:cell.playBtn];    //隐藏播放按钮
        }else{
            [cell.playBtn.superview bringSubviewToFront:cell.playBtn];  //显示播放按钮
        }
        NSArray *indexpaths = [tableView indexPathsForVisibleRows];
        if (![indexpaths containsObject:currentIndexPath] && currentIndexPath!=nil) { //复用机制

            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:vedioPlayer]) {
                vedioPlayer.hidden = NO;
            }else{
                vedioPlayer.hidden = YES;
                [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
            }
        }else{
            if ([cell.vedioBg.subviews containsObject:vedioPlayer]) {  //当滑倒所属当前视频的时候自动播放
                [cell.vedioBg addSubview:vedioPlayer];
                [vedioPlayer play];
                vedioPlayer.hidden = NO;
            }

        }
    }


    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.dataSource.count > 0) {
         KYVideo *kYVideo  = self.dataSource[indexPath.row];
         return kYVideo.curCellHeight;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    KYLocalVideoPlayVC *localVideoPlayVC = [[KYLocalVideoPlayVC alloc] init];
    KYVideo *kYVideo  = self.dataSource[indexPath.row];
    localVideoPlayVC.title = kYVideo.title;
    localVideoPlayVC.URLString = kYVideo.video;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:localVideoPlayVC animated:YES];

}

#pragma mark - KYNetworkVideoCellDelegate

-(void)networkVideoCellVedioBgTapGesture:(KYVideo *)video{

    KYLocalVideoPlayVC *localVideoPlayVC = [[KYLocalVideoPlayVC alloc] init];
    localVideoPlayVC.title = video.title;
    localVideoPlayVC.URLString = video.video;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:localVideoPlayVC animated:YES];

}

-(void)networkVideoCellOnClickVideoPlay:(KYVideo *)video withVideoPlayBtn:(UIButton *)videoPlayBtn;{

    [self closeCurrentCellVedioPlayer];

    currentVideo = video;
    currentIndexPath = [NSIndexPath indexPathForRow:videoPlayBtn.tag inSection:0];
    KYNetworkVideoCell *cell =nil;
    if ([UIDevice currentDevice].systemVersion.floatValue>=8||[UIDevice currentDevice].systemVersion.floatValue<7) {
        cell = (KYNetworkVideoCell *)videoPlayBtn.superview.superview;

    }else{//ios7系统 UITableViewCell上多了一个层级UITableViewCellScrollView
        cell = (KYNetworkVideoCell *)videoPlayBtn.superview.superview.subviews;

    }

    if (vedioPlayer) {
        [self releasePlayer];
        vedioPlayer = [[KYVedioPlayer alloc]initWithFrame:cell.vedioBg.bounds];
        vedioPlayer.delegate = self;
        vedioPlayer.closeBtnStyle = CloseBtnStyleClose;
        vedioPlayer.titleLabel.text = video.title;
        vedioPlayer.URLString = video.video;
    }else{

        vedioPlayer = [[KYVedioPlayer alloc]initWithFrame:cell.vedioBg.bounds];
        vedioPlayer.delegate = self;
        vedioPlayer.closeBtnStyle = CloseBtnStyleClose;
        vedioPlayer.titleLabel.text = video.title;
        vedioPlayer.URLString = video.video;
    }

    [cell.vedioBg addSubview:vedioPlayer];
    [cell.vedioBg bringSubviewToFront:vedioPlayer];
    [cell.playBtn.superview sendSubviewToBack:cell.playBtn];
    [self.tableView reloadData];


}
/**
 * 关闭当前cell 中的 视频
 **/
-(void)closeCurrentCellVedioPlayer{

    if (currentVideo != nil &&  currentIndexPath != nil) {

        KYNetworkVideoCell *currentCell = [self currentCell];
        [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
        [vedioPlayer removeFromSuperview];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}


#pragma mark - KYVedioPlayerDelegate 播放器委托方法
//点击播放暂停按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{

    NSLog(@"[KYVedioPlayer] clickedPlayOrPauseButton ");
}
//点击关闭按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedCloseButton:(UIButton *)closeBtn{

    NSLog(@"[KYVedioPlayer] clickedCloseButton ");

    if (kyvedioPlayer.isFullscreen == YES) { //点击全屏模式下的关闭按钮
        self.navigationController.navigationBarHidden = NO;
        [self showCellCurrentVedioPlayer];
    }else{

        [self closeCurrentCellVedioPlayer];
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
        self.navigationController.navigationBarHidden = YES;
        kyvedioPlayer.isFullscreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [kyvedioPlayer showFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft player:kyvedioPlayer withFatherView:self.view];
    }else{
         self.navigationController.navigationBarHidden = NO;
        [self showCellCurrentVedioPlayer];

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

    [self closeCurrentCellVedioPlayer];


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
    NSLog(@"KYNetworkVideoCellPlayVC dealloc");
}


@end
