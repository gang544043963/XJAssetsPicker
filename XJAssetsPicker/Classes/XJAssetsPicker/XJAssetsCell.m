//
//  XJAssetsCell.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-17.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#define IMAGE_SPACE_DISTANCE_MIN 2 //图片的最小间距
#define TAG_START 100   //tag起始值
#define IMAGE_CHECK_SIZE 21 //选中标记图片大小

#import <AssetsLibrary/AssetsLibrary.h>
#import "XJAssetsCell.h"
#import "XJAsset.h"

@implementation XJAssetsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        //buttom的Frame
        UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
        CGFloat screenWidht=0;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            screenWidht=[UIScreen mainScreen].bounds.size.height;
        }else{
            screenWidht=[UIScreen mainScreen].bounds.size.width;
        }
        int columnsCount=self.columnsCount;
        CGFloat spaceDistance=IMAGE_SPACE_DISTANCE_MIN+(screenWidht-columnsCount*(IMAGE_SIZE+IMAGE_SPACE_DISTANCE_MIN))/(columnsCount+1);
        //添加Button
        for (int i=0; i<columnsCount; i++) {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            //去除点击Button高亮
            button.adjustsImageWhenHighlighted=YES;
            button.highlighted=NO;
            //frame设置
            button.frame=CGRectMake(spaceDistance+(IMAGE_SIZE+spaceDistance)*i, CELL_SPACE_DISTANCE, IMAGE_SIZE, IMAGE_SIZE);
            button.tag=TAG_START+i;
            //button事件
            [button addTarget:self action:@selector(manageAsstes:event:) forControlEvents:UIControlEventTouchUpInside];
            //给Button添加长按事件
            UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(browerPicture:)];
            longPressGesture.minimumPressDuration=0.3;
            [button addGestureRecognizer:longPressGesture];
            
            [self.contentView addSubview:button];
        }
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    [super setSelected:selected animated:animated];
}
#pragma mark 长按事件，浏览图片
- (void)browerPicture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state==UIGestureRecognizerStateBegan) {
        if (self.blockPreview) {
            int index=sender.view.tag-TAG_START;
            self.blockPreview(self.arrayRowAssets[index]);
        }
    }
}
#pragma mark Button事件，选择数据
- (void)manageAsstes:(UIButton *)sender event:(UIEvent *)event
{
    int tag=sender.tag-TAG_START;
    //选中状态修改
    XJAsset *asset=self.arrayRowAssets[tag];
    BOOL original=asset.selected;
    asset.selected=!asset.selected;
    //获取Button子视图，等于nil时没有选择该资源，添加该资源选中
    UIView *checkView=[sender viewWithTag:ASSETS_CHECK_TAG];
    if (original==NO&&asset.selected==YES) {
        UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check.png"]];
        imageView.tag=ASSETS_CHECK_TAG;
        CGFloat x=sender.bounds.size.width-IMAGE_CHECK_SIZE-5;
        CGFloat y=sender.bounds.size.height-IMAGE_CHECK_SIZE-5;
        imageView.frame=CGRectMake(x, y, IMAGE_CHECK_SIZE, IMAGE_CHECK_SIZE);
        [sender addSubview:imageView];
    }else{
        [checkView removeFromSuperview];
    }
}
- (NSInteger)columnsCount
{
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
    CGFloat screenWidht=0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        screenWidht=[UIScreen mainScreen].bounds.size.height;
    }else{
        screenWidht=[UIScreen mainScreen].bounds.size.width;
    }
    NSInteger columnsCount=screenWidht/(IMAGE_SIZE+IMAGE_SPACE_DISTANCE_MIN);
    return columnsCount;
}
#pragma mark 重写setArrayRowAssets，设置UITableViewCell的显示数据
- (void)setArrayRowAssets:(NSArray *)arrayRowAssets
{
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
    CGFloat screenWidht=0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        screenWidht=[UIScreen mainScreen].bounds.size.height;
    }else{
        screenWidht=[UIScreen mainScreen].bounds.size.width;
    }
    int columnsCount=self.columnsCount;
    CGFloat spaceDistance=IMAGE_SPACE_DISTANCE_MIN+(screenWidht-columnsCount*(IMAGE_SIZE+IMAGE_SPACE_DISTANCE_MIN))/(columnsCount+1);
    for (int i=0; i<columnsCount; i++) {
        int tag=i+TAG_START;
        UIButton *button=(UIButton *)[self.contentView viewWithTag:tag];
        button.frame=CGRectMake(spaceDistance+(IMAGE_SIZE+spaceDistance)*i, CELL_SPACE_DISTANCE, IMAGE_SIZE, IMAGE_SIZE);
        if(i>arrayRowAssets.count-1){
            button.hidden=YES;
        }else{
            XJAsset *asset=(XJAsset *)arrayRowAssets[i];
            [button setImage:[UIImage imageWithCGImage:[asset.asset thumbnail]] forState:UIControlStateNormal];
            button.hidden=NO;
            //重新构造勾选图片
            UIView *checkView=[button viewWithTag:ASSETS_CHECK_TAG];
            [checkView removeFromSuperview];
            if (asset.selected) {
                UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check.png"]];
                imageView.tag=ASSETS_CHECK_TAG;
                CGFloat x=button.bounds.size.width-IMAGE_CHECK_SIZE-5;
                CGFloat y=button.bounds.size.height-IMAGE_CHECK_SIZE-5;
                imageView.frame=CGRectMake(x, y, IMAGE_CHECK_SIZE, IMAGE_CHECK_SIZE);
                [button addSubview:imageView];
            }
        }
    }
    _arrayRowAssets=arrayRowAssets;
}

@end
