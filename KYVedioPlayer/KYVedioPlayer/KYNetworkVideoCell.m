//
//  KYNetworkVideoCell.m
//  KYVedioPlayer
//
//  Created by kingly on 16/9/12.
//  Copyright © 2016年 https://github.com/kingly09/KYVedioPlayer kingly  inc . All rights reserved.
//

#import "KYNetworkVideoCell.h"
#define kVerticalSpace 10

@interface KYNetworkVideoCell(){

    UILabel *title;
    UIImageView *vedioBg;
    UIButton *playBtn;
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
        

        vedioBg= [[UIImageView alloc]init];
        vedioBg.contentMode = UIViewContentModeScaleToFill;
        vedioBg.userInteractionEnabled = YES;
        UITapGestureRecognizer *panGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(vedioBgTapGesture:)];
        vedioBg.userInteractionEnabled = YES;
        [vedioBg addGestureRecognizer:panGesture];
        [self.contentView  addSubview:vedioBg];
        
        
        playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [playBtn setImage:[UIImage imageNamed:@"video_cover_play_nor"]  forState:UIControlStateNormal];
        [playBtn adjustsImageWhenHighlighted];
        [playBtn adjustsImageWhenDisabled];
        playBtn.backgroundColor = [UIColor clearColor];
        playBtn.imageView.contentMode = UIViewContentModeCenter;
        [playBtn addTarget:self action:@selector(onClickVideoPlay:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView  addSubview:playBtn];

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
        vedioBg.frame =  CGRectMake(0, title.frame.size.height , kScreenWidth,200);
        [vedioBg sd_setImageWithURL:[NSURL URLWithString:video.image] placeholderImage:[UIImage imageNamed:@"PlayerBackground"]];
        playBtn.frame = CGRectMake((kScreenWidth - 72)/2, title.frame.size.height+ (vedioBg.frame.size.height - 72)/2  , 72, 72);
        _video.curCellHeight = vedioBg.frame.origin.y + vedioBg.frame.size.height;
        
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

-(void)onClickVideoPlay:(id)sender{

    if (_mydelegate && [_mydelegate respondsToSelector:@selector(networkVideoCellOnClickVideoPlay:)]) {
        [_mydelegate networkVideoCellOnClickVideoPlay:_video];
    }
}

@end
