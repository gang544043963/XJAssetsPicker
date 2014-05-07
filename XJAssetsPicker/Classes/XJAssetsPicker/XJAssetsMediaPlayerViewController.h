//
//  XJAssetsMediaPlayerViewController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-2-12.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJAssetSelectionDelegate.h"

@class XJAsset;

@interface XJAssetsMediaPlayerViewController : UIViewController

@property(nonatomic,weak) id<XJAssetSelectionDelegate> parent;
///浏览资源列表
@property(nonatomic,strong) XJAsset *xjAsset;
///确定按钮的标题
@property(nonatomic,strong) NSString *titleButtonSure;
@end
