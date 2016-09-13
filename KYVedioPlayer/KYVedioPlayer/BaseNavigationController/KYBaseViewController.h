//
//  KYBaseViewController.h
//  KYVedioPlayer
//
//  Created by kingly on 16/9/8.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

typedef void(^onSuccess)(NSArray *videoArray);
typedef void(^onFailed)(NSError *error);

@interface KYBaseViewController : UIViewController

@property (nonatomic,retain) MBProgressHUD* progressHUD;


- (void)addProgressHUD;
- (void)addProgressHUDWithMessage:(NSString*)message;
- (void)removeProgressHUD;

- (void)getVideoListWithURLString:(NSString *)URLString  success:(onSuccess)success failed:(onFailed)failed;

@end
