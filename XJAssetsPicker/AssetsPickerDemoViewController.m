//
//  AssetsPickerDemoViewController.m
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-5-6.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import "AssetsPickerDemoViewController.h"
#import "XJAssetsPickerController.h"

#import <MediaPlayer/MediaPlayer.h>

@interface AssetsPickerDemoViewController ()<XJAssetsPickerDelegate>{
    MPMoviePlayerController *_moviePlay;
}

@end

@implementation AssetsPickerDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)choosePicture:(UIButton *)sender {
    XJAssetsPickerController *assetsPicker=[[XJAssetsPickerController alloc]initPhotosPicker];
    assetsPicker.delegate=self;
    assetsPicker.maxSelectCount=4;
    [self presentViewController:assetsPicker animated:YES completion:nil];
}

- (IBAction)chooseVedio:(UIButton *)sender {
    XJAssetsPickerController *assetsPicker=[[XJAssetsPickerController alloc]initVideosPicker];
    assetsPicker.titleButtonSure=@"确定";
    assetsPicker.delegate=self;
    //assetsPicker.maxSelectCount=4; 设置无效，默认为1
    [self presentViewController:assetsPicker animated:YES completion:nil];
}
#pragma mark - XJAssetsPicker Delegate
- (void)assetsPicker:(XJAssetsPickerController *)assetsPicker didFinishPickingMediaWithInfo:(NSArray *)info
{
    //图片
    if (assetsPicker.AssetType==AssetsPickerAssetPhoto) {
        int i=0;
        for (UIView *view in self.showPicture.subviews) {
            [view removeFromSuperview];
        }
        for (NSDictionary *dic in info) {
            NSLog(@"媒体名称：%@",dic[AssetsPickerMediaName]);
            UIImageView *imageView=[[UIImageView alloc]initWithImage:dic[AssetsPickerImageFullScreen]];
            imageView.frame=CGRectMake(self.showPicture.bounds.size.width*i++, 0, self.showPicture.bounds.size.width, self.showPicture.bounds.size.height);
            [self.showPicture addSubview:imageView];
        }
        self.showPicture.contentSize=CGSizeMake(self.showPicture.bounds.size.width*info.count, self.showPicture.bounds.size.height);
    }
    //视频
    if (assetsPicker.AssetType==AssetsPickerAssetVideo) {
        for (NSDictionary *dic in info) {
            NSLog(@"媒体名称：%@",dic[AssetsPickerMediaName]);
            NSLog(@"视频路径：%@",dic[AssetsPickerVedioCompress]);
        }
    }
}
@end
