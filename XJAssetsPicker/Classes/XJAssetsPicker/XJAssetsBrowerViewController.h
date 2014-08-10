//
//  XJAssetsBrowerViewController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-22.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJAssetSelectionDelegate.h"

@interface XJAssetsBrowerViewController : UIViewController

@property(nonatomic,weak) id<XJAssetSelectionDelegate> parent;
///浏览资源列表
@property(nonatomic,strong) NSArray *arrayAsset;
///当前显示索引
@property(nonatomic,assign) NSInteger currentIndex;
///资源数量
@property(nonatomic,assign) NSInteger selectCount;
///确定按钮的标题
@property(nonatomic,strong) NSString *titleButtonSure;
@end
