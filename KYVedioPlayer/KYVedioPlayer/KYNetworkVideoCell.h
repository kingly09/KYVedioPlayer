//
//  KYNetworkVideoCell.h
//  KYVedioPlayer
//
//  Created by kingly on 16/9/12.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KYVideo.h"

@protocol KYNetworkVideoCellDelegate;

@interface KYNetworkVideoCell : UITableViewCell

@property (nonatomic,weak) id<KYNetworkVideoCellDelegate>mydelegate;

+(NSString *) cellReuseIdentifier;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic,strong) KYVideo *video;

@end


@protocol KYNetworkVideoCellDelegate <NSObject>


-(void)networkVideoCellVedioBgTapGesture:(KYVideo *)video;

-(void)networkVideoCellOnClickVideoPlay:(KYVideo *)video;

@end