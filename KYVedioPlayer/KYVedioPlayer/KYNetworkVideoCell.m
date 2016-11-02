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
