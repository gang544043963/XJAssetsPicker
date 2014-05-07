//
//  XJAssetsGroupViewController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-17.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJAssetSelectionDelegate.h"
@class ALAssetsLibrary;

@interface XJAssetsGroupViewController : UITableViewController
@property(nonatomic,weak) id<XJAssetSelectionDelegate> parent;

@end
