# KYVedioPlayer

KYVedioPlayer 是基于AVPlayer的封装视频播放器,支持播放mp4、m3u8、3gp、mov等格式；支持网络视频和本地视频播放；支持全屏和小屏幕播放；还在UITableViewCell中播放视频 ；支持横屏竖屏自动播放。

![](https://raw.githubusercontent.com/kingly09/KYVedioPlayer/master/vedio01.gif)


# 安装

### 要求

* Xcode 7 +
* iOS 7.0 +

KYVedioPlayer播放器的布局依赖`Masonry`框架，注意工程是否包含`Masonry`库，如果没有的话，可以使用CocoaPods安装`Masonry`库。

```
	pod 'Masonry', '~> 1.0.1'
```

### 手动安装

下载DEMO后,将子文件夹 **KYVedioPlayerLib** 拖入到项目中, 导入头文件`KYVedioPlayer.h` 开始使用.

### CocoaPods安装

你可以在 **Podfile** 中加入下面一行代码来使用 KYAlertView

```
	pod 'KYVedioPlayer'
```

## 实现的功能

1. 支持播放mp4、m3u8、3gp、mov等格式的视频播放；
2. 支持网络视频和本地视频播放；
3. 支持全屏和小屏幕播放；
4. 支持UITableViewCell中播放视频；
5. 支持横屏竖屏自动播放；

# 如何使用

### 基本功能

### step 1 :创建控制器

在您需要使用`KYVedioPlayer`播放器功能的类中，import 头文件`KYVedioPlayer.h`即可 。
设置 `KYVedioPlayerDelegate`委托代理  代码示例如下：

```
#import "KYVedioPlayer.h"

@interface KYLocalVideoPlayVC ()<KYVedioPlayerDelegate>{
    KYVedioPlayer  *vedioPlayer;
    CGRect     playerFrame;
}
```

### step 2 :初始化

初始化VedioPlayer 初始化需要几个步骤：

* 准备需要视频播放的UIView；
* 新建player；
* 设置url；
* 调用 ` [vedioPlayer play] ` 开始播放。还可以设置播放器进度条的颜色，关闭按钮是否显示，视频标题等。


新建一个 化VedioPlayer 播放器，代码示例如下：

```
    playerFrame = CGRectMake(0, 0, kScreenWidth, (kScreenWidth)*(0.75));
   vedioPlayer = [[KYVedioPlayer alloc]initWithFrame:playerFrame];
   vedioPlayer.delegate = self;
   vedioPlayer.URLString = _URLString;
   vedioPlayer.titleLabel.text = self.title;
   vedioPlayer.closeBtn.hidden = NO;
   vedioPlayer.progressColor = [UIColor orangeColor];
   [self.view addSubview:vedioPlayer];

```

###  step 3 :启动播放器和暂停

启动

```
[vedioPlayer play];    
```

暂停

```
[vedioPlayer pause];    
```

### step 4 :设置监听,屏幕旋转的通知，代码示例如下：

```
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(NotificationDeviceOrientationChange:)
                                             name:UIDeviceOrientationDidChangeNotification
                                           object:nil
 ];

 ```

根据屏幕旋转的通知,是否全屏，是否缩小，代码示例如下：

 ```
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

 ```


### step 5 :注销播放器，代码示例如下：

```
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
```

### step 6 :其它操作，如隐藏状态栏，设置播放器进度条的颜色，关闭按钮是否显示，获取正在播放的时间点等，代码示例如下：

* 隐藏状态栏

```
/**
 *  隐藏状态栏
 **/
-(BOOL)prefersStatusBarHidden{
    return YES;
}

```

* 设置播放器进度条的颜色

```
vedioPlayer.progressColor = [UIColor orangeColor];
```

* 关闭按钮是否显示，NO为显示关闭按钮 ，YES为隐藏关闭按钮

```
 vedioPlayer.closeBtn.hidden = NO;
```

* 获取正在播放的时间点

```
[vedioPlayer currentTime];
```


### 播放器事件

播放器的几种状态，为`KYVedioPlayerState`枚举类型

事件ID                    |     含义说明
------------------------- | ---------------------
KYVedioPlayerStateFailed    | 播放失败
KYVedioPlayerStateBuffering | 缓冲中
KYVedioPlayerStatusReadyToPlay | 将要播放
KYVedioPlayerStatePlaying   | 播放中
KYVedioPlayerStateStopped   | 暂停播放
KYVedioPlayerStateFinished  | 播放完毕

### 播放器回调

播放器所有点击事件的回调都会通过这个`KYVedioPlayerDelegate`反馈给您的App.

```
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
```


### 更多播放器方法

* 重置播放器

```
[vedioPlayer resetKYVedioPlayer];
```

* 设置全屏显示播放

```
/**
 *  全屏显示播放
 ＊ @param interfaceOrientation 方向
 ＊ @param player 当前播放器
 ＊ @param fatherView 当前父视图
 **/
-(void)showFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation player:(KYVedioPlayer *)player withFatherView:(UIView *)fatherView;
```

* 设置小屏幕显示播放

```
/**
 *  小屏幕显示播放
 ＊ @param player 当前播放器
 ＊ @param fatherView 当前父视图
 ＊ @param playerFrame 小屏幕的Frame
 **/
-(void)showSmallScreenWithPlayer:(KYVedioPlayer *)player withFatherView:(UIView *)fatherView withFrame:(CGRect )playerFrame;

```

# 高级功能演示DEMO

## 1.[记住上次播放的位置](Docs/RememberLast_README.md)

每次记录播放器注销的时候的该视频的时间点，当下次在播放该视频的时候，先判断一下是否记录了该视频的时间点，如果记录了，就从记录的时间点开始播放，若没有，正常播放即可。

> 整个例子 在 DEMO 的`KYRememberLastPlayedVC.m` 文件代码实现如下：

```
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


```

效果如下：

![](https://raw.githubusercontent.com/kingly09/KYVedioPlayer/master/vedio02.gif)


* 每次记录播放器注销的时候的该视频的时间点，代码实现如下：

```
- (void)dealloc
{
    //记录播放的时间
    double time = [vedioPlayer currentTime];
    [TheUserDefaults setDouble:time forKey:URLString];

    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"KYRememberLastPlayedVC dealloc");
}
```

* 如果有存上次播放的时间点记录，直接跳到上次纪录时间点播放，代码实现如下：

```
if ([TheUserDefaults doubleForKey:URLString]) {//如果有存上次播放的时间点记录，直接跳到上次纪录时间点播放
		double time = [TheUserDefaults doubleForKey:URLString];
		vedioPlayer.seekTime = time;
}
```

## 2.[支持UITableViewCell中播放视频](Docs/Cell_README.md)



支持UITableViewCell中播放视频，当滑动视图的时候后，切换到小窗口播放，当滑到当前的cell视图时候，回来cell视图中播放，可以自由滑动切换视频连续播放。
还可以随时点击切换横屏播放，小屏幕播放。

![](https://raw.githubusercontent.com/kingly09/KYVedioPlayer/master/vedio03.gif)

## step 1 :首先创建一个 KYNetworkVideoCell视图

**KYNetworkVideoCell.h**

```
#import <UIKit/UIKit.h>
#import "KYVideo.h"

@protocol KYNetworkVideoCellDelegate;

@interface KYNetworkVideoCell : UITableViewCell

@property (nonatomic,weak) id<KYNetworkVideoCellDelegate>mydelegate;

+(NSString *) cellReuseIdentifier;

@property (nonatomic, strong)  UIImageView *vedioBg;
@property (nonatomic, strong)   UIButton *playBtn;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic,strong) KYVideo *video;

@end


@protocol KYNetworkVideoCellDelegate <NSObject>


-(void)networkVideoCellVedioBgTapGesture:(KYVideo *)video;

-(void)networkVideoCellOnClickVideoPlay:(KYVideo *)video withVideoPlayBtn:(UIButton *)videoPlayBtn;

@end
```

**KYNetworkVideoCell.m**


```

#import "KYNetworkVideoCell.h"
#define kVerticalSpace 10

@interface KYNetworkVideoCell(){

    UILabel *title;

}
@end

@implementation KYNetworkVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        [self addCellView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addCellView
{


        title = [[UILabel alloc]init];
        title.backgroundColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentLeft;
        title.textColor = [UIColor blackColor];
        title.font = [UIFont systemFontOfSize:16];
        title.numberOfLines = 0;
        title.contentMode= UIViewContentModeTop;
        [self.contentView  addSubview:title];


        _vedioBg= [[UIImageView alloc]init];
        _vedioBg.contentMode = UIViewContentModeScaleToFill;
        _vedioBg.userInteractionEnabled = YES;
        UITapGestureRecognizer *panGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(vedioBgTapGesture:)];
        _vedioBg.userInteractionEnabled = YES;
        [_vedioBg addGestureRecognizer:panGesture];
        [self.contentView  addSubview:_vedioBg];


        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"video_cover_play_nor"]  forState:UIControlStateNormal];
        [_playBtn adjustsImageWhenHighlighted];
        [_playBtn adjustsImageWhenDisabled];
        _playBtn.backgroundColor = [UIColor clearColor];
        _playBtn.imageView.contentMode = UIViewContentModeCenter;
        [_playBtn addTarget:self action:@selector(onClickVideoPlay:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView  addSubview:_playBtn];

}

/**
 * 设置数据模型展示视图
 */
-(void)setVideo:(KYVideo *)video
{
    if (_video != video ) {
        _video = nil;
        _video = video;

        title.text  = _video.title;
        title.frame = CGRectMake(kVerticalSpace, 0 , kScreenWidth - kVerticalSpace*2, 30);
        _vedioBg.frame =  CGRectMake(0, title.frame.size.height , kScreenWidth,200);
        [_vedioBg sd_setImageWithURL:[NSURL URLWithString:video.image] placeholderImage:[UIImage imageNamed:@"PlayerBackground"]];
        _playBtn.frame = CGRectMake((kScreenWidth - 72)/2, title.frame.size.height+ (_vedioBg.frame.size.height - 72)/2  , 72, 72);
        _video.curCellHeight = 230;

    }
}

+(NSString *) cellReuseIdentifier{

    return @"KKYNetworkVideoCell";
}

-(void)vedioBgTapGesture:(id)sender{


    if (_mydelegate && [_mydelegate respondsToSelector:@selector(networkVideoCellVedioBgTapGesture:)]) {
        [_mydelegate networkVideoCellVedioBgTapGesture:_video];
    }

}

-(void)onClickVideoPlay:(UIButton *)sender{

    _video.indexPath = _indexPath;
    if (_mydelegate && [_mydelegate respondsToSelector:@selector(networkVideoCellOnClickVideoPlay:withVideoPlayBtn:)]) {
        [_mydelegate networkVideoCellOnClickVideoPlay:_video withVideoPlayBtn:sender];
    }
}

@end

```

## step 2 :  设置 `KYNetworkVideoCellDelegate` 和 `KYVedioPlayerDelegate` 委托代理 如 demo里面的 `KYSwitchFreelyVC.m ` 所示

```
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

```

## step 3 : 给播放器加监听以及屏幕旋转的通知

```
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

```

接收屏幕旋转的通知

```
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
```

## step 4 : 加载数据，显示视频列表，使用 `MJRefresh`实现下拉刷新的效果

```
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
```

## step 5 : 实现tableView，点击某个视频push到KYLocalVideoPlayVC界面播放

```
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
```

## step 6 : 从全屏来当前的cell视频

```
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
```

## step 7 :  显示小窗口视频

实际是删除vedioPlayer，然后放在keyWindow上

```
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
```

## step 8 :  点击cell视图上的播放按钮，在UITableViewCell中播放视频

cell播放：Layer是加载到cell上的背景图片区域的 滚动的时候要记录当前cell
全屏播放：Layer是加载到Window上的 frame全屏
小窗播放：它其实就是全屏播放的一个特例，也是加载到Window上的，frame自定义
其实不同状态的切换无非就是Layer所在View的位置不停切换

下面这个方法就是记录当前播放的cell下标

```
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
```

## step 9 :  设置上下滚动的时候根据坐标切换cell显示还是小窗显示


```
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
```


## step 10 : 当滑倒所属当前视频的时候自动播放，切换的时候就是把只之前的Layer移除，然后重新布局，加到KeyWindow中去，代码实现如下：

```
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
```



## step 11 : 关闭当前cell 中的 视频,直接vedioPlayer 移除子视图即可。

```
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
```





#  联系与建议反馈

>
> **weibo:** [http://weibo.com/balenn](http://weibo.com/balenn)
>
> **QQ:** 362108564
>

如果有任何你觉得不对的地方，或有更好的建议，以上联系都可以联系我。 十分感谢！

## 感谢

KYVedioPlayer播放器的布局依赖`Masonry`框架，十分感谢`Masonry`开发人员对开源事业作出的贡献！

# 鼓励

它若不慎给您帮助，请不吝啬给它点一个**star**，是对它的最好支持，非常感谢！🙏


# LICENSE

KYVedioPlayer 被许可在 **MIT** 协议下使用。查阅 **LICENSE** 文件来获得更多信息。
