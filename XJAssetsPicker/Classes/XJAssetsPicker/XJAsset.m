//
//  XJAsset.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-20.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import "XJAsset.h"

@implementation XJAsset

- (id)initWithAsset:(ALAsset *)asset
{
    self=[super init];
    if (self) {
        self.asset=asset;
        self.selected=NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
   if (![self.parent assetShouldSelect:self]) {
       return;
   }
    _selected=selected;
}
@end
