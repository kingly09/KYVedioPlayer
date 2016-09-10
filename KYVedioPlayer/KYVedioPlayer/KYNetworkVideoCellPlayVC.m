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

@interface KYNetworkVideoCellPlayVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView		*tableView;
@property (nonatomic, strong) NSArray			*dataSource;

@end

@implementation KYNetworkVideoCellPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - 初始化方法
- (void)setUpView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = ({
        UITableView *tableView	= [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.delegate		= self;
        tableView.dataSource	= self;
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
                      @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
                      @"video":@"http://7rfkz6.com1.z0.glb.clouddn.com/480p_20160229_T2.mp4"},
                    
                    @{@"title":@"视频二 m3u8格式",
                      @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
                      @"video":@"http://flv2.bn.netease.com/videolib3/1609/10/QElkL2832/SD/movie_index.m3u8"},
                    
                    @{@"title":@"视频三 mov格式",
                      @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
                      @"video":@"http://movies.apple.com/media/us/iphone/2010/tours/apple-iphone4-design_video-us-20100607_848x480.mov"},
                    
                    @{@"title":@"视频四 3gp格式",
                      @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
                      @"video":path3gp},
                    
                    @{@"title":@"视频五",
                      @"image":@"http://vimg3.ws.126.net/image/snapshot/2016/9/V/A/VBVM8HAVA.jpg",
                      @"video":@"http://flv2.bn.netease.com/videolib3/1609/05/shRkL5482/HD/movie_index.m3u8"},
                    
                    @{@"title":@"视频六",
                      @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
                      @"video":@"http://flv2.bn.netease.com/videolib3/1609/10/KMEzY9667/SD/KMEzY9667-mobile.mp4"},
                    
                    @{@"title":@"视频七",
                      @"image":@"http://vimg3.ws.126.net/image/snapshot/2016/9/O/J/VBVMCCMOJ.jpg",
                      @"video":@"http://flv2.bn.netease.com/tvmrepo/2016/9/R/9/EBVLTSCR9/SD/movie_index.m3u8"},
                    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    KYVideo *kYVideo  = self.dataSource[indexPath.row];
    cell.textLabel.text = kYVideo.title;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
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



@end
