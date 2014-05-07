//
//  XJAssetsViewController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-17.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJAssetSelectionDelegate.h"
@class ALAssetsGroup;

@interface XJAssetsViewController : UITableViewController

@property(nonatomic,weak) id<XJAssetSelectionDelegate> parent;
@property(nonatomic,strong) ALAssetsGroup *assetsGroup;
@property(nonatomic,assign) NSInteger selectCount;              //选择数量

@property(nonatomic,strong) NSMutableArray *arrayAsset;         //选择发送的资源集合

@end
