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

*


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

* [支持UITableViewCell中播放视频](Docs/Cell_README.md)

* [记住上次播放的位置](Docs/RememberLast_README.md)



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

KYAlertView 被许可在 **MIT** 协议下使用。查阅 **LICENSE** 文件来获得更多信息。
