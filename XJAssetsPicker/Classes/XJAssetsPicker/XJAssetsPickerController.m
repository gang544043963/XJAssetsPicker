//
//  XJAssetsPickerController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-17.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "XJAssetsPickerController.h"

#import "XJVideoCompress.h"
#import "XJAssetsGroupViewController.h"
#import "XJAssetSelectionDelegate.h"
#import "MBProgressHUD.h"
#import "XJAsset.h"

@interface XJAssetsPickerController ()<XJAssetSelectionDelegate,UIAlertViewDelegate>{
    MBProgressHUD *_progressHUD;
    NSArray *_arrayVedio;
}

@end

@implementation XJAssetsPickerController

- (id)initPhotosPicker
{
    XJAssetsGroupViewController *group=[[XJAssetsGroupViewController alloc]initWithStyle:UITableViewStylePlain];
    self = [super initWithRootViewController:group];
    if (self) {
        self.title=@"照片";
        self.titleButtonSure=@"发送";
        self.maxSelectCount=6;
        _AssetType=AssetsPickerAssetPhoto;
        group.parent=self;
    }
    return self;
}
- (id)initVideosPicker
{
    XJAssetsGroupViewController *group=[[XJAssetsGroupViewController alloc]initWithStyle:UITableViewStylePlain];
    self = [super initWithRootViewController:group];
    if (self) {
        self.title=@"视频";
        self.titleButtonSure=@"发送";
        self.maxSelectCount=1;
        _AssetType=AssetsPickerAssetVideo;
        group.parent=self;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //navigationBar、toolbar透明效果
    self.toolbar.translucent=YES;
    self.toolbar.alpha=0.8;
    self.navigationBar.translucent=YES;
    self.navigationBar.alpha=0.8;
    //title color
    self.navigationBar.tintColor=[UIColor whiteColor];
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue]>=7) {
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    }
    //navigationBar、toolbar背景设置
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/bar_background.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/bar_background.png"] forBarMetrics:UIBarMetricsDefault];
}
#pragma mark ios7 状态栏颜色设置
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - 方法重写 最大选择数量
- (void)setMaxSelectCount:(NSInteger)maxSelectCount
{
    _maxSelectCount=maxSelectCount;
    if (self.AssetType==AssetsPickerAssetVideo) {
        _maxSelectCount=1;
    }
}
#pragma mark - 自定义方法
#pragma mark 退出选择器
- (void)exit:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark 返回选择器
- (void)back:(id)sender
{
    [self popViewControllerAnimated:YES];
}
#pragma mark size转string
- (NSString *)stringFromSize:(NSNumber *)size
{
    NSString *result=@"";
    double byteSize=size.doubleValue;
    char units[3]={'K','M','G'};
    int unit=0;
    
    do{
        byteSize/=1024.f;
        unit++;
    }while (byteSize>=1024.f);
    unit--;
    
    if (unit==0) {
        byteSize=[self number:byteSize precision:1];
        if (byteSize<1) {
            byteSize=1;
        }
        result=[NSString stringWithFormat:@"%.0lf%c",byteSize,units[unit]];
    }else{
        byteSize=[self number:byteSize precision:2];
        result=[NSString stringWithFormat:@"%.2lf%c",byteSize,units[unit]];
    }
    
    return result;
}
#pragma mark 数字精度设置
- (double)number:(double)num precision:(double)pre
{
    double result;
    result=num*pow(10,pre)+0.5;
    result=result/pow(10,pre);
    return result;
}
#pragma mark - 委托事件实现
#pragma mark 确定该资源是否可以选择
- (BOOL)shouldSelectAsset:(XJAsset *)asset previousCount:(NSUInteger)previousCount
{
    BOOL shouldSelect=previousCount<self.maxSelectCount;
    if (!shouldSelect) {
        MBProgressHUD *progressHUD=[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        progressHUD.userInteractionEnabled=NO;
        progressHUD.mode=MBProgressHUDModeText;
        progressHUD.margin = 10.f;
        progressHUD.yOffset = 150.f;
        progressHUD.alpha=0.75;
        progressHUD.labelText=[NSString stringWithFormat:@"你最多只能选择%d个%@",self.maxSelectCount,self.title];
        progressHUD.removeFromSuperViewOnHide = YES;
        [progressHUD hide:YES afterDelay:2];
    }
    return shouldSelect;
}
#pragma mark 传递已选资源集合
- (void)selectedAssets:(NSArray *)assets original:(BOOL)original
{
    if (self.AssetType==AssetsPickerAssetPhoto) {         //图片发送
        NSMutableArray *arrayInfo=[[NSMutableArray alloc]init];
        for (ALAsset *asset in assets) {
            ALAssetRepresentation *rep=[asset defaultRepresentation];
            
            NSMutableDictionary *dictionaryMedia=[[NSMutableDictionary alloc]init];
            [dictionaryMedia setValue:rep.filename forKey:AssetsPickerMediaName];
            
            UIImage *imageThumbnail=[UIImage imageWithCGImage:[asset thumbnail]];
            UIImage *imageFullScreen=[UIImage imageWithCGImage:[rep fullScreenImage]];
            [dictionaryMedia setObject:imageThumbnail forKey:AssetsPickerImageThumbnail];
            [dictionaryMedia setObject:imageFullScreen forKey:AssetsPickerImageFullScreen];
            
//            [dictionaryMedia setObject:UIImageJPEGRepresentation(imageThumbnail, 0.5) forKey:AssetsPickerImageDataThumbnail];
//            [dictionaryMedia setObject:UIImageJPEGRepresentation(imageFullScreen, 0.5) forKey:AssetsPickerImageDataFullScreen];
            
            //发送原图
            if (original) {
//                Byte *imageBuffer = (Byte*)malloc((long)rep.size);
//                NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0 length:(long)rep.size error:nil];
//                NSData *dataOriginal = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
//                [dictionaryMedia setObject:dataOriginal forKey:AssetsPickerImageDataOriginal];
                UIImage *imageOriginal=[UIImage imageWithCGImage:[rep fullResolutionImage]];
                [dictionaryMedia setObject:imageOriginal forKey:AssetsPickerImageOriginal];
            }
            [arrayInfo addObject:dictionaryMedia];
        }
        [self.delegate assetsPicker:self didFinishPickingMediaWithInfo:arrayInfo];
        [self dismissViewControllerAnimated:YES completion:^{
            [_progressHUD hide:NO];
        }];
    }else{                                                  //视频发送
        _progressHUD=[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        _progressHUD.removeFromSuperViewOnHide = YES;
        _progressHUD.alpha=0.75;
        _progressHUD.labelText=@"正在压缩...";
        
        _arrayVedio=[[NSMutableArray alloc]init];
        
        ALAsset *alAsset=assets.lastObject;
        ALAssetRepresentation *rep=[alAsset defaultRepresentation];
        NSMutableDictionary *dictionaryMedia=[[NSMutableDictionary alloc]init];
        
        //构建压缩后的视频路径
        NSString *catchPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        NSString *vedioName=[NSString stringWithFormat:@"%@.3GP",cfuuidString];
        NSString *vedioFilePath=[catchPath stringByAppendingPathComponent:[NSString stringWithFormat:@"VedioRecord/%@", vedioName]];
        //判断目录是否存在不存在则创建
        NSString *vedioDirectories = [vedioFilePath stringByDeletingLastPathComponent];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:vedioDirectories]) {
            [fileManager createDirectoryAtPath:vedioDirectories withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //视频压缩
        XJVideoCompress *videoCompress=[[XJVideoCompress alloc]initWithInputURL:[rep url] outputURL:[NSURL fileURLWithPath:vedioFilePath] presentName:AVAssetExportPresetLowQuality outputFileType:AVFileType3GPP];
        [videoCompress executeWithCompletionHandler:^(BOOL result) {
            [_progressHUD hide:NO];
            if (result) {
                [dictionaryMedia setValue:vedioName forKey:AssetsPickerMediaName];
                [dictionaryMedia setObject:[NSURL fileURLWithPath:vedioFilePath] forKey:AssetsPickerVedioCompress];
                _arrayVedio=[[NSArray alloc]initWithObjects:dictionaryMedia, nil];
                //计算文件大小
                NSDictionary *attributes =[fileManager attributesOfItemAtPath:vedioFilePath error:nil];
                NSString *vedioSize=[self stringFromSize:[attributes objectForKey:NSFileSize]];
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"视频压缩后文件大小为%@,确定要选择吗？",vedioSize] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:self.titleButtonSure, nil];
                [alertView show];
            }else{
                UIAlertView *alertView=[[UIAlertView alloc]init];
                alertView.title=@"提示";
                alertView.message=@"视频压缩失败,请重试!";
                [alertView show];
            }
        }];
    }
}
#pragma mark alertview委托事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {           //取消发送
        NSFileManager *fileManager=[NSFileManager defaultManager];
        for (NSDictionary *dic in _arrayVedio) {
            [fileManager removeItemAtURL:[dic objectForKey:AssetsPickerVedioCompress] error:nil];
        }
    }else if (buttonIndex==1) {     //发送
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate assetsPicker:self didFinishPickingMediaWithInfo:_arrayVedio];
        }];
    }
}

@end
