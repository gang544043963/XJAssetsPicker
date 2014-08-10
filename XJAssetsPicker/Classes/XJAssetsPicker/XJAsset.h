//
//  XJAsset.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-20.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ALAsset;
@class XJAsset;

@protocol XJAssetDelegate <NSObject>
/**
 *  确定该资源是否可以选择
 *
 *  @param asset 当前资源
 *
 *  @return YES:允许选择该资源，NO:当前资源数已达上限不允许选择
 */
- (BOOL)assetShouldSelect:(XJAsset *)asset;

@end

/**
 *  资源列表类
 */
@interface XJAsset : NSObject

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) id<XJAssetDelegate> parent;
/**
 *  初始化XJAsset
 *
 *  @param asset ALAsset资源
 *
 *  @return XJAsset
 */
- (id)initWithAsset:(ALAsset *)asset;

@end
