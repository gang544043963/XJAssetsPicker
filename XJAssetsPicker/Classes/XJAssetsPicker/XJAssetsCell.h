//
//  XJAssetsCell.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-17.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#define IMAGE_SIZE 76    //图片高宽
#define CELL_SPACE_DISTANCE 2  //Cell间距
#define ASSETS_CHECK_TAG 222    //选中资源标记的tag
#import <UIKit/UIKit.h>
@class XJAsset;

@interface XJAssetsCell : UITableViewCell

@property(nonatomic,assign,readonly) NSInteger columnsCount;

@property(nonatomic,strong) NSArray *arrayRowAssets;

@property(nonatomic,copy) void (^blockPreview)(XJAsset *xjAsset);

@end
