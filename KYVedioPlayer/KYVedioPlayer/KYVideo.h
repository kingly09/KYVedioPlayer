//
//  KYVideo.h
//  KYVedioPlayer
//
//  Created by kingly on 16/9/10.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KYVideo : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * image;
@property (nonatomic, strong) NSString * video;

/**
 *自定义cell的高度
 */
@property (nonatomic,assign) CGFloat curCellHeight;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
