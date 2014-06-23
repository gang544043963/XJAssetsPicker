//
//  AssetsPickerDemoViewController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-5-6.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetsPickerDemoViewController : UIViewController
- (IBAction)choosePicture:(UIButton *)sender;
- (IBAction)chooseVedio:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *showPicture;

@end
