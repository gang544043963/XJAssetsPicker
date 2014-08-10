//
//  XJAssetsPickerController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-17.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

static NSString *const AssetsPickerMediaName=@"mediaName";             ///<媒体名称 String

static NSString *const AssetsPickerImageThumbnail=@"thumnail";         ///<缩略图  Image
static NSString *const AssetsPickerImageFullScreen=@"fullScreen";      ///<全屏图  Image
static NSString *const AssetsPickerImageOriginal=@"original";          ///<原图    Image

static NSString *const AssetsPickerVedioCompress=@"compress";          ///<视频压缩 Url

/**
 *  选择器类型
 */
typedef enum {
	AssetsPickerAssetPhoto=1,   ///<图片
    AssetsPickerAssetVideo=2    ///<视频
} AssetsPickerAssetType;

#import <UIKit/UIKit.h>

@class ALAssetsLibrary;
@class XJAssetsPickerController;

@protocol XJAssetsPickerDelegate <UINavigationControllerDelegate>
/**
 *  图片选择结束后调用该委托，获取选择的图片
 *
 *  @param assetsPicker XJAssetsPickerController
 *  @param info         图片信息
 */
- (void)assetsPicker:(XJAssetsPickerController *)assetsPicker didFinishPickingMediaWithInfo:(NSArray *)info;
@end

@interface XJAssetsPickerController : UINavigationController
@property(nonatomic,weak) id<XJAssetsPickerDelegate> delegate;
///最大选择资源数
@property(nonatomic,assign) NSInteger maxSelectCount;
///资源类型
@property(nonatomic,assign,readonly) AssetsPickerAssetType AssetType;
///确定按钮的标题
@property(nonatomic,strong) NSString *titleButtonSure;
/**
 *  init图片选择器
 *
 *  @return 当前类
 */
- (id)initPhotosPicker;
/**
 *  init视频选择器
 *
 *  @return 当前类
 */
- (id)initVideosPicker;

@end