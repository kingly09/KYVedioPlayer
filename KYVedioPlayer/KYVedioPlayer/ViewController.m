//
//  ViewController.m
//  KYVedioPlayer
//
//  Created by kingly on 16/9/8.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import "ViewController.h"
#import "KYNetworkVideoCellPlayVC.h"
#import "KYLocalVideoPlayVC.h"
#import "KYRememberLastPlayedVC.h"
#import "KYSwitchFreelyVC.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *myTableView;
    NSArray *dataSource;//数据源
    NSArray *viewControllers; //对应的控制器
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"KYVedioPlayerDemo";
    [self loadTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadTableView{
    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    [self.view addSubview:myTableView];
    
    dataSource = @[@"支持网络视频Cell中播放",@"本地视频播放",@"记忆上次播放的位置",@"小屏幕全屏自如切换"];
    viewControllers =  @[@"KYNetworkVideoCellPlayVC",@"KYLocalVideoPlayVC",@"KYRememberLastPlayedVC",@"KYSwitchFreelyVC"];
    [myTableView reloadData];
}

#pragma mark - UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [dataSource objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController *pushViewController = [[NSClassFromString([viewControllers objectAtIndex:indexPath.row]) alloc] init];
    pushViewController.title = [dataSource objectAtIndex:indexPath.row];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:pushViewController animated:YES];
}


@end
