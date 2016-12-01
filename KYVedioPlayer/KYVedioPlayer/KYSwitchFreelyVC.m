//
//  KYSwitchFreelyVC.m
//  KYVedioPlayer
//
//  Created by kingly on 16/9/9.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import "KYSwitchFreelyVC.h"
#import "KYLocalVideoPlayVC.h"
#import "KYVideo.h"
#import "KYNetworkVideoCell.h"


@interface KYSwitchFreelyVC ()<UITableViewDelegate, UITableViewDataSource,KYNetworkVideoCellDelegate,KYVedioPlayerDelegate>
@property (nonatomic, strong) UITableView		*tableView;
@property (nonatomic, strong) NSMutableArray	*dataSource;

@end



@implementation KYSwitchFreelyVC{

    KYVedioPlayer *vedioPlayer;
    KYVideo *currentVideo;
    NSIndexPath *currentIndexPath;
    BOOL isSmallScreen;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _dataSource = [NSMutableArray array];
        isSmallScreen = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpView];
    [self loadDataList];
    [self addMJRefresh];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    self.navigationController.navigationBarHidden = NO;
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NotificationDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}

-(void)loadDataList{
    [self addProgressHUDWithMessage:@"加载中..."];
    [self getVideoListWithURLString:@"http://c.m.163.com/nc/video/home/0-10.html"
                            success:^( NSArray *videoArray) {
                                _dataSource =[NSMutableArray arrayWithArray:videoArray];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self removeProgressHUD];
                                    [self.tableView reloadData];
                                    [self.tableView.mj_header endRefreshing];
                                });
                            }
                             failed:^(NSError *error) {
                                 [self removeProgressHUD];
                             }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)addMJRefresh{
    WS(weakSelf)
    __unsafe_unretained UITableView *tableView = self.tableView;
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
         [weakSelf addProgressHUDWithMessage:@"加载中..."];
        [self getVideoListWithURLString:@"http://c.m.163.com/nc/video/home/0-10.html"
                                success:^( NSArray *videoArray) {
                                    _dataSource =[NSMutableArray arrayWithArray:videoArray];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (currentIndexPath.row> _dataSource.count) {
                                            [weakSelf releasePlayer];
                                        }
                                        [weakSelf removeProgressHUD];
                                        [tableView reloadData];
                                        [tableView.mj_header endRefreshing];
                                    });
                                }
                                 failed:^(NSError *error) {

                                     [weakSelf removeProgressHUD];
                                 }];

    }];


    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSString *URLString = [NSString stringWithFormat:@"http://c.m.163.com/nc/video/home/%ld-10.html",_dataSource.count - _dataSource.count%10];
        [weakSelf addProgressHUDWithMessage:@"加载中..."];
        [self getVideoListWithURLString:URLString
                                success:^(NSArray *videoArray) {
                                    [_dataSource addObjectsFromArray:videoArray];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf removeProgressHUD];
                                        [tableView reloadData];
                                        [tableView.mj_header endRefreshing];
                                    });

                                }
                                 failed:^(NSError *error) {

                                     [weakSelf removeProgressHUD];
                                 }];
        // 结束刷新
        [tableView.mj_footer endRefreshing];
    }];


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
            isSmallScreen = NO;
            vedioPlayer.fullScreenBtn.selected = NO;

        }];
    }
}

-(void)showSmallScreen{

    //放widow上
    [vedioPlayer removeFromSuperview];
    [UIView animateWithDuration:0.5f animations:^{
        vedioPlayer.transform = CGAffineTransformIdentity;
        vedioPlayer.frame = CGRectMake(kScreenWidth/2,kScreenHeight-kNavbarHeight-(kScreenWidth/2)*0.75, kScreenWidth/2, (kScreenWidth/2)*0.75);
        vedioPlayer.playerLayer.frame =  vedioPlayer.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:vedioPlayer];
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
        isSmallScreen = YES;
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:vedioPlayer];
    }];

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

    if (isSmallScreen) {
        [self releasePlayer];
        isSmallScreen = NO;
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

        if (isSmallScreen) {
            //放widow上,小屏显示
            [self showSmallScreen];
        }else{
            [self showCellCurrentVedioPlayer];

        }

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
    NSLog(@"KYSwitchFreelyVC dealloc");
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
                if (isSmallScreen) {
                    //放widow上,小屏显示
                    [self showSmallScreen];
                }else{
                    [self showCellCurrentVedioPlayer];
                }
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

#pragma mark -  scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView ==self.tableView){
        if (vedioPlayer==nil) {
            return;
        }

        if (vedioPlayer.superview) {
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:currentIndexPath];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            if (rectInSuperview.origin.y<-self.currentCell.vedioBg.frame.size.height||rectInSuperview.origin.y>kScreenHeight-kNavbarHeight-kTabBarHeight) {//往上拖动

                if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:vedioPlayer]&&isSmallScreen) {
                    isSmallScreen = YES;
                }else{
                    //放widow上,小屏显示
                    [self showSmallScreen];
                }

            }else{
                if ([self.currentCell.vedioBg.subviews containsObject:vedioPlayer]) {

                }else{
                    [self showCellCurrentVedioPlayer];
                }
            }
        }

    }
}


@end
