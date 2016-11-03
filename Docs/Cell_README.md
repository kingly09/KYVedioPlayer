KYVedioPlayer 使用高级教程 - 支持UITableViewCell中播放视频
=====================

本教程将讲解 `KYVedioPlayer` 的高级功能的使用。

## 说明

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
