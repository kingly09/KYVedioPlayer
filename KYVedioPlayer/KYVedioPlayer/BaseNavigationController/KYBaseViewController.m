//
//  KYBaseViewController.m
//  KYVedioPlayer
//
//  Created by kingly on 16/9/8.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import "KYBaseViewController.h"
#import "KYVideo.h"

@interface KYBaseViewController ()

@end

@implementation KYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor  whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  获得视频列表
 **/
- (void)getVideoListWithURLString:(NSString *)URLString  success:(onSuccess)success failed:(onFailed)failed{
    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
    dispatch_async(global_t, ^{
        NSURL *url = [NSURL URLWithString:URLString];
        NSMutableArray *listArray = [NSMutableArray array];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *  data, NSError *  connectionError) {
            if (connectionError) {
                NSLog(@"错误%@",connectionError);
                failed(connectionError);
            }else{
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *videoList = [dict objectForKey:@"videoList"];
                for (NSDictionary * video in videoList) {
                    KYVideo * model = [[KYVideo alloc] init];
                    model.title = [video objectForKey:@"title"];
                    model.image = [video objectForKey:@"cover"];
                    model.video = [video objectForKey:@"m3u8_url"];
                    [listArray addObject:model];
                }
                success(listArray);
            }
            
        }];
        
    });
    
}

- (void)addProgressHUD{

    if (!_progressHUD) {
        _progressHUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}
- (void)addProgressHUDWithMessage:(NSString*)message{

    if (!_progressHUD)
    {
        _progressHUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _progressHUD.label.text=message;
    }
    
}

- (void)removeProgressHUD{
    
    if (_progressHUD) {
        [_progressHUD removeFromSuperview];
        _progressHUD=nil;
    }
}


@end
