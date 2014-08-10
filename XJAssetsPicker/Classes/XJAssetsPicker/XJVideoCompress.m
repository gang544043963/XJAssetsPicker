//
//  XJVideoCompress.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-2-15.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import "XJVideoCompress.h"
#import <AVFoundation/AVAsset.h>

@interface XJVideoCompress(){
    NSURL *_urlVedioCaches;
}

@end

@implementation XJVideoCompress

- (id)initWithInputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL presentName:(NSString *)presetName outputFileType:(NSString *)outputFileType
{
    if (self=[super init]) {
        NSString *vedioCachesPath=[NSTemporaryDirectory() stringByAppendingPathComponent:@"VedioRecord/vediocaches.MOV"];
        //判断目录是否存在不存在则创建
        NSString *vedioDirectories = [vedioCachesPath stringByDeletingLastPathComponent];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:vedioDirectories]) {
            [fileManager createDirectoryAtPath:vedioDirectories withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _urlVedioCaches=[NSURL fileURLWithPath:vedioCachesPath];
        
        self.shouldOptimizeForNetworkUse=YES;
        
        self.inputURL=inputURL;
        self.outputURL=outputURL;
        self.presetName=presetName;
        self.outputFileType=outputFileType;
    }
    return self;
}

- (void)executeWithCompletionHandler:(void (^)(BOOL))handler
{
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:self.inputURL options:nil];
    AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:avAsset presetName:self.presetName];
    exportSession.shouldOptimizeForNetworkUse=self.shouldOptimizeForNetworkUse;
    //输出类型
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    //输出视频路径,文件不能已存在
    exportSession.outputURL = _urlVedioCaches;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                [self performSelectorOnMainThread:@selector(compressSizeWithCompletionHandler:) withObject:handler waitUntilDone:YES];
                break;
            case AVAssetExportSessionStatusFailed:
                [self performSelectorOnMainThread:@selector(convertFailWithCompletionHandler:) withObject:handler waitUntilDone:YES];
                break;
            default:
                break;
        }
        
    }];
}

- (void)compressSizeWithCompletionHandler:(void (^)(BOOL))handler{
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:_urlVedioCaches options:nil];
    AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
    exportSession.shouldOptimizeForNetworkUse=self.shouldOptimizeForNetworkUse;
    //输出类型
    if ([exportSession.supportedFileTypes containsObject:self.outputFileType]) {
        exportSession.outputFileType=self.outputFileType;
        //判断目录是否存在不存在则创建
        NSString *vedioDirectories = [self.outputURL.path stringByDeletingLastPathComponent];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:vedioDirectories]) {
            [fileManager createDirectoryAtPath:vedioDirectories withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //输出视频路径,文件不能已存在
        exportSession.outputURL = self.outputURL;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCompleted:
                    [self performSelectorOnMainThread:@selector(convertSuccessWithCompletionHandler:) withObject:handler waitUntilDone:YES];
                    break;
                case AVAssetExportSessionStatusFailed:
                    [self performSelectorOnMainThread:@selector(convertFailWithCompletionHandler:) withObject:handler waitUntilDone:YES];
                    break;
                default:
                    break;
            }
        }];
    }else{
        [self convertFailWithCompletionHandler:handler];
    }
}

- (void)convertSuccessWithCompletionHandler:(void (^)(BOOL))handler
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    [fileManager removeItemAtURL:_urlVedioCaches error:nil];
    if (handler) {
        handler(YES);
    }
}

- (void)convertFailWithCompletionHandler:(void (^)(BOOL))handler
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    [fileManager removeItemAtURL:_urlVedioCaches error:nil];
    if ([fileManager fileExistsAtPath:self.outputURL.relativePath]) {
        [fileManager removeItemAtURL:self.outputURL error:nil];
    }
    if (handler) {
        handler(NO);
    }
}
@end
