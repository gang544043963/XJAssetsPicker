//
//  XJAssetSelectionDelegate.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-21.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XJAsset;

@protocol XJAssetSelectionDelegate <NSObject>

/**
 *  根据以前的资源数量确定当前的资源是否允许选择
 *
 *  @param asset         当前将要选择的资源
 *  @param previousCount 以前已选择的资源数
 *
 *  @return YES：当前资源允许选择；NO：当前资源数已达上限不允许选择
 */
- (BOOL)shouldSelectAsset:(XJAsset *)asset previousCount:(NSUInteger)previousCount;
/**
 *  传递已选资源集合
 *
 *  @param assets   资源集合
 *  @param original 是否发送原图
 */
- (void)selectedAssets:(NSArray *)assets original:(BOOL)original;
@end
