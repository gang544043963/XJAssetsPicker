//
//  XJAssetsBrowerViewController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-22.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#define TAG_START 200   //默认开始tag
#define TAG_DELEGATE 199    //是否触发委托的tag标记

#import "XJAssetsBrowerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XJAsset.h"

@interface XJAssetsBrowerViewController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    UIButton *_buttonOriginal;  ///<原图按钮
    UIButton *_buttonSend;      ///<发送按钮
    UIButton *_buttonSelect;    ///<选择按钮
    
    BOOL _original;             ///<YES发送原图，NO不发送
    BOOL _scrollFlag;           ///<是否执行滚动
    CGFloat _beginDraggingContentOffsetX;  ///<开始拖拽的X坐标
}

@property(nonatomic,assign) long long originalSize;

@end

@implementation XJAssetsBrowerViewController
#pragma mark - 生命周期
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue]>=7) {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    _original=NO;
    [self initialBar];
    [self initialScrollView];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:NO];
}
#pragma mark IOS7 隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark 旋转方向发生改变时
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_scrollView removeFromSuperview];
    [self initialScrollView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark 初始化barItem
- (void)initialBar
{
    //navigation设置 返回
    UIButton *buttonBack=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.titleLabel.font=[UIFont systemFontOfSize:12];
    buttonBack.bounds=CGRectMake(0, 0, 50, 29);
    [buttonBack setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/back_arrows.png"] forState:UIControlStateNormal];
    [buttonBack setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/back_arrows_highlighted.png"] forState:UIControlStateHighlighted];
    [buttonBack addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:buttonBack];
    //navigation设置 选择
    UIButton *buttonSelect=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonSelect.titleLabel.font=[UIFont systemFontOfSize:12];
    buttonSelect.bounds=CGRectMake(0, 0, 50, 29);
    XJAsset *xjAsset=self.arrayAsset[self.currentIndex];
    if (xjAsset.selected) {
        [buttonSelect setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check.png"] forState:UIControlStateNormal];
    }else{
        [buttonSelect setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check_no.png"] forState:UIControlStateNormal];
    }
    [buttonSelect addTarget:self action:@selector(selectAsset:) forControlEvents:UIControlEventTouchUpInside];
    _buttonSelect=buttonSelect;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:buttonSelect];
    //toolbar设置 原图
    UIButton *buttonOriginal=[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOriginal setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    buttonOriginal.titleLabel.font=[UIFont systemFontOfSize:12];
    buttonOriginal.bounds=CGRectMake(0, 0, 80, 29);
    [buttonOriginal setTitle:@"原图" forState:UIControlStateNormal];
    [buttonOriginal setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/original_no.png"] forState:UIControlStateNormal];
    [buttonOriginal addTarget:self action:@selector(selectOriginal:) forControlEvents:UIControlEventTouchUpInside];
    _buttonOriginal=buttonOriginal;
    UIBarButtonItem * barItemOriginal=[[UIBarButtonItem alloc]initWithCustomView:buttonOriginal];
    //toolbar设置 发送
    UIButton *buttonSend=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonSend.titleLabel.font=[UIFont systemFontOfSize:12];
    buttonSend.bounds=CGRectMake(0, 0, 50, 29);
    [buttonSend setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/send.png"] forState:UIControlStateNormal];
    [buttonSend setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/send_highlighted.png"] forState:UIControlStateHighlighted];
    [buttonSend addTarget:self action:@selector(sendImage:) forControlEvents:UIControlEventTouchUpInside];
    _buttonSend=buttonSend;
    UIBarButtonItem * barItemSend=[[UIBarButtonItem alloc]initWithCustomView:buttonSend];
    NSString *title=@"";
    if (self.selectCount==0) {
        barItemSend.enabled=NO;
        title=self.titleButtonSure;
    }else{
        barItemSend.enabled=YES;
        title=[NSString stringWithFormat:@"%@(%d)",self.titleButtonSure,self.selectCount];
    }
    [buttonSend setTitle:title forState:UIControlStateNormal];
    
    UIBarButtonItem * space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems=@[barItemOriginal,space,barItemSend];
}
#pragma mark 初始化scrollView
- (void)initialScrollView
{
    UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
    CGFloat screenWidht=0;
    CGFloat screenHeight=0;
    if (orientation==UIInterfaceOrientationLandscapeLeft||orientation==UIInterfaceOrientationLandscapeRight) {
        screenWidht=[UIScreen mainScreen].bounds.size.height;
        screenHeight=[UIScreen mainScreen].bounds.size.width;
    }else{
        screenWidht=[UIScreen mainScreen].bounds.size.width;
        screenHeight=[UIScreen mainScreen].bounds.size.height;
    }
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidht, screenHeight)];
    _scrollView.backgroundColor=[UIColor blackColor];
    //标记tag，触发委托事件
    _scrollView.tag=TAG_DELEGATE;
    
    CGFloat heightStatus=[UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect frameNav=self.navigationController.navigationBar.frame;
    CGRect frameTool=self.navigationController.toolbar.frame;
    int indexStart=(self.currentIndex-1)<0?0:(self.currentIndex-1);
    int indexEnd=(self.currentIndex+1)>=self.arrayAsset.count?self.currentIndex:(self.currentIndex+1);
    for (int i=indexStart; i<=indexEnd; i++) {
        //子图片显示区域设置
        CGRect frameLast=[((UIView *)[[_scrollView subviews]lastObject]) frame];
        CGRect frame=CGRectMake(frameLast.origin.x+frameLast.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        [self createScrollView:_scrollView withFrame:frame withSVIndex:_scrollView.subviews.count withAssetIndex:i];
    }
    //显示当前所选择的图片
    int indexCount=self.currentIndex-indexStart;
    CGPoint pointOffset=_scrollView.contentOffset;
    pointOffset.x=indexCount*_scrollView.frame.size.width;
    _scrollView.contentOffset=pointOffset;
    //ContentSize设置
    CGSize contentSize=_scrollView.frame.size;
    contentSize.width=(indexEnd-indexStart+1)*_scrollView.frame.size.width;
    contentSize.height-=(heightStatus+frameNav.size.height+frameTool.size.height);
    _scrollView.contentSize=contentSize;
    _scrollView.pagingEnabled=YES;
    
    //滚动条
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    //允许弹动
    _scrollView.alwaysBounceHorizontal=YES;
    _scrollView.alwaysBounceVertical=NO;
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(barShowState:)];
    [_scrollView addGestureRecognizer:tap];
    _scrollView.delegate=self;
    [self.view addSubview:_scrollView];
}
#pragma mark - target事件方法
#pragma mark 手势，单击显／隐
- (void)barShowState:(UITapGestureRecognizer *)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    [self.navigationController setToolbarHidden:!self.navigationController.toolbarHidden animated:YES];
}
#pragma mark 返回选择器
- (void)back:(id)sender
{
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.375];
    [self.navigationController popViewControllerAnimated:YES];
    [UIView commitAnimations];
}
#pragma mark 选择图片
- (void)selectAsset:(UIButton *)sender
{
    int index=_scrollView.contentOffset.x/_scrollView.frame.size.width;
    UIView *subSV=_scrollView.subviews[index];
    XJAsset *xjAsset=self.arrayAsset[subSV.tag-TAG_START];
    BOOL nowSelected=xjAsset.selected;
    xjAsset.selected=!xjAsset.selected;
    if (nowSelected!=xjAsset.selected) {
        if (xjAsset.selected) {
            self.selectCount++;
        }else{
            self.selectCount--;
        }
        
        if (_original) {
            long long newSize=[xjAsset.asset defaultRepresentation].size;
            if (xjAsset.selected) {
                _originalSize+=newSize;
            }else{
                _originalSize-=newSize;
            }
            self.originalSize=_originalSize;
        }
    }
}
#pragma mark 原图发送
- (void)selectOriginal:(UIButton *)sender
{
    _originalSize=0;
    _original=!_original;
    if (_original) {
        for (XJAsset *xjAsset in self.arrayAsset) {
            ALAsset *asset=xjAsset.asset;
            if (xjAsset.selected) {
                _originalSize+=[asset defaultRepresentation].size;//原始图片大小
//                UIImage *image=[UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
//                NSData *data=UIImageJPEGRepresentation(image, 1);   //高清图片大小
//                _originalSize+=data.length;
                
//                NSLog(@"%lld,%d",[asset defaultRepresentation].size,data.length);
                
            }
        }
        if (_originalSize==0) {
            int index=_scrollView.contentOffset.x/_scrollView.frame.size.width;
            XJAsset *xjAsset=self.arrayAsset[index];
            xjAsset.selected=YES;
            self.selectCount++;
            self.originalSize=[xjAsset.asset defaultRepresentation].size;
        }else{
            self.originalSize=_originalSize;
        }
    }else{
        [sender setTitle:@"原图" forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/original_no.png"] forState:UIControlStateNormal];
    }
}
#pragma mark 发送选择图片
- (void)sendImage:(id)sender
{
    NSMutableArray *arrayInfo=[[NSMutableArray alloc]init];
    for (XJAsset *asset in self.arrayAsset) {
        if (asset.selected) {
            [arrayInfo addObject:asset.asset];
        }
    }
    [self.parent selectedAssets:arrayInfo original:_original];
}
#pragma mark - 方法重写
#pragma mark 重写selectCount方法
- (void)setSelectCount:(NSInteger)selectCount
{
    if (self.selectCount<selectCount) {
        [_buttonSelect setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check.png"] forState:UIControlStateNormal];
    }else{
        [_buttonSelect setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check_no.png"] forState:UIControlStateNormal];
    }
    _selectCount=selectCount;
    NSString *title=@"";
    if (self.selectCount==0) {
        _buttonSend.enabled=NO;
        title=self.titleButtonSure;
    }else{
        _buttonSend.enabled=YES;
        title=[NSString stringWithFormat:@"%@(%d)",self.titleButtonSure,self.selectCount];
    }
    [_buttonSend setTitle:title forState:UIControlStateNormal];
}
#pragma mark 重写originalSize方法
- (void)setOriginalSize:(long long)originalSize
{
    _originalSize=originalSize;
    if (self.selectCount==0) {
        [_buttonOriginal setTitle:@"原图" forState:UIControlStateNormal];
    }else{
        [_buttonOriginal setTitle:[NSString stringWithFormat:@"原图(%@)",[self stringFromSize:_originalSize]] forState:UIControlStateNormal];
    }
    [_buttonOriginal setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/original.png"] forState:UIControlStateNormal];
    
}
#pragma mark - 自定义方法
#pragma mark 交换scrollView视图
- (void)switchView:(UIScrollView *)scrollView
{
    CGPoint pointOffset=scrollView.contentOffset;
    //显示视图索引
    int index=scrollView.contentOffset.x/scrollView.frame.size.width;
    //显示的视图scrollview
    UIScrollView *subScrollView=(UIScrollView *)scrollView.subviews[index];
    //处在中间的视图位置不用调整
    if (scrollView.subviews.count==3&&index==1) {
        return;
    }
    //显示的图片在资源中的索引
    int indexAsset=subScrollView.tag-TAG_START;
    self.currentIndex=indexAsset;
    //在资源中间的图片位置调整
    if (indexAsset!=0&&indexAsset!=(self.arrayAsset.count-1)) {
        //右滑
        if (_beginDraggingContentOffsetX<scrollView.contentOffset.x) {
            for (int i=0; i<scrollView.subviews.count; i++) {
                UIScrollView *midScrollView=(UIScrollView *)scrollView.subviews[i];
                if (i==index-2) {
                    [self changeAttrForScrollView:midScrollView withFrameX:subScrollView.frame.origin.x withAssetIndex:(indexAsset+1)];
                }else{
                    if (index==2) {
                        midScrollView.frame=CGRectMake((i-1)*midScrollView.frame.size.width, 0, midScrollView.frame.size.width, midScrollView.frame.size.height);
                    }else{
                        midScrollView.frame=CGRectMake(i*midScrollView.frame.size.width, 0, midScrollView.frame.size.width, midScrollView.frame.size.height);
                    }
                }
            }
            //不存在第三个ScrollView，则创建
            if (scrollView.subviews.count<=2) {
                //子图片显示区域设置
                CGRect frame=CGRectMake(subScrollView.frame.origin.x+subScrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
                [self createScrollView:scrollView withFrame:frame withSVIndex:0 withAssetIndex:(indexAsset+1)];
                scrollView.contentSize=CGSizeMake(scrollView.contentSize.width/2*3, scrollView.contentSize.height);
            }
            //显示当前所选择的图片
            pointOffset.x=scrollView.frame.size.width;
            scrollView.contentOffset=pointOffset;
            //交换scrollview的子视图位置
            [scrollView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
            [scrollView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
            return;
        }
        //左滑
        if (_beginDraggingContentOffsetX>scrollView.contentOffset.x) {
            for (int i=0; i<scrollView.subviews.count; i++) {
                UIScrollView *midScrollView=(UIScrollView *)scrollView.subviews[i];
                if (i==index+2) {
                    [self changeAttrForScrollView:midScrollView withFrameX:0 withAssetIndex:(indexAsset-1)];
                }else{
                    midScrollView.frame=CGRectMake((i+1)*midScrollView.frame.size.width, 0, midScrollView.frame.size.width, midScrollView.frame.size.height);
                }
            }
            //不存在第三个ScrollView，则创建
            if (scrollView.subviews.count<=2) {
                //子图片显示区域设置
                CGRect frame=CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
                [self createScrollView:scrollView withFrame:frame withSVIndex:2 withAssetIndex:(indexAsset-1)];
                scrollView.contentSize=CGSizeMake(scrollView.contentSize.width+scrollView.bounds.size.width, scrollView.contentSize.height);
            }
            //显示当前所选择的图片
            pointOffset.x=scrollView.frame.size.width;
            scrollView.contentOffset=pointOffset;
            //交换scrollview的子视图位置
            [scrollView exchangeSubviewAtIndex:2 withSubviewAtIndex:1];
            [scrollView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
        }
    }
}
#pragma mark 改变scrollView的属性
- (void)changeAttrForScrollView:(UIScrollView *)scrollView withFrameX:(CGFloat)x withAssetIndex:(int)assetIndex
{
    //image
    XJAsset *xjAsset=self.arrayAsset[assetIndex];
    ALAsset *alAsset=xjAsset.asset;
    ALAssetRepresentation *repressentation=[alAsset defaultRepresentation];
    CGImageRef imageRef=[repressentation fullScreenImage];
    UIImage *imageScreen=[UIImage imageWithCGImage:imageRef];
    //imageView frame设置
    UIImageView *subIV=(UIImageView *)[scrollView viewWithTag:900];
    subIV.image=imageScreen;
    CGFloat heightStatus=[UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat imHeight=imageScreen.size.height;
    CGFloat imWidth=imageScreen.size.width;
    CGFloat scale=(scrollView.frame.size.height-heightStatus)/imHeight;
    imHeight*=scale;
    imWidth*=scale;
    if (imWidth>scrollView.frame.size.width) {
        scale=scrollView.frame.size.width/imWidth;
        imHeight*=scale;
        imWidth*=scale;
    }
    //初始化imageview的变换效果
    subIV.transform = CGAffineTransformIdentity;
    subIV.frame=CGRectMake(0, 0, imWidth, imHeight);
    subIV.center=CGPointMake(scrollView.bounds.size.width*0.5, (scrollView.bounds.size.height-heightStatus)*0.5);
    //scrollView 设置
    scrollView.tag=assetIndex+TAG_START;
    scrollView.contentSize=scrollView.bounds.size;
    scrollView.frame=CGRectMake(x, 0, scrollView.frame.size.width, scrollView.frame.size.height);
}
#pragma mark 创建scrollView
- (void)createScrollView:(UIScrollView *)scrollView withFrame:(CGRect)frame withSVIndex:(int)svIndex withAssetIndex:(int)assetIndex
{
    //image
    XJAsset *xjAsset=self.arrayAsset[assetIndex];
    ALAsset *alAsset=xjAsset.asset;
    ALAssetRepresentation *repressentation=[alAsset defaultRepresentation];
    CGImageRef imageRef=[repressentation fullScreenImage];
    UIImage *image=[UIImage imageWithCGImage:imageRef];
    //imageView
    UIImageView *subIV=[[UIImageView alloc]initWithImage:image];
    subIV.contentMode=UIViewContentModeScaleAspectFit;
    subIV.tag=900;
    CGFloat heightStatus=[UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat imHeight=image.size.height;
    CGFloat imWidth=image.size.width;
    CGFloat scale=(scrollView.frame.size.height-heightStatus)/imHeight;
    imHeight*=scale;
    imWidth*=scale;
    if (imWidth>scrollView.frame.size.width) {
        scale=scrollView.frame.size.width/imWidth;
        imHeight*=scale;
        imWidth*=scale;
    }
    subIV.frame=CGRectMake(0, 0, imWidth, imHeight);
    subIV.center=CGPointMake(scrollView.bounds.size.width*0.5, (scrollView.bounds.size.height-heightStatus)*0.5);
    //scrollView
    UIScrollView *subSV=[[UIScrollView alloc]initWithFrame:frame];
    subSV.backgroundColor=[UIColor clearColor];
    subSV.contentSize=subSV.bounds.size;
    subSV.showsHorizontalScrollIndicator=NO;
    subSV.showsVerticalScrollIndicator=NO;
    //边宽大小设置
//    subSV.contentInset=UIEdgeInsetsMake(0, 5, 0, 5);
    //可以使左右滚动和上下滚动同时只响应一个
    subSV.directionalLockEnabled=YES;
    //允许弹动
    subSV.alwaysBounceHorizontal=NO;
    subSV.alwaysBounceVertical=NO;
    //缩放设置
    subSV.maximumZoomScale=2.0;
    subSV.minimumZoomScale=1;
    
    subSV.scrollsToTop=NO;
    subSV.scrollEnabled=YES;
    
    subSV.delegate=self;
    subSV.tag=TAG_START+assetIndex;
    
    [subSV addSubview:subIV];
    [scrollView insertSubview:subSV atIndex:svIndex];
}
#pragma mark size转string
- (NSString *)stringFromSize:(long long)size
{
    NSString *result=@"";
    double byteSize=(double)size;
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
#pragma mark - scrollView委托事件
#pragma mark scroll开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.tag==TAG_DELEGATE) {
        _scrollFlag=YES;
        _beginDraggingContentOffsetX=scrollView.contentOffset.x;
    }
    NSLog(@"%d,%lf",scrollView.tag,_beginDraggingContentOffsetX);
}
#pragma mark scroll结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag==TAG_DELEGATE) {
        _scrollFlag=NO;
    }
}
#pragma mark scroll滚动过程
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag==TAG_DELEGATE&&_scrollFlag) {
        int index=_beginDraggingContentOffsetX/scrollView.frame.size.width;
        UIScrollView *view=scrollView.subviews[index];
        NSInteger assetIndex=view.tag-TAG_START;
        
        CGFloat offsetWidth=scrollView.contentOffset.x-_beginDraggingContentOffsetX;
        //当拖动到屏幕中间位置是，不管是左滑，还是右滑，都一律往左滑
        //左滑
        if (offsetWidth<=-scrollView.frame.size.width*0.5&&assetIndex>0) {
            assetIndex-=1;
        }
        //右滑
        if (offsetWidth>scrollView.frame.size.width*0.5&&assetIndex<self.arrayAsset.count-1) {
            assetIndex+=1;
        }
        //选中的图片状态切换
        XJAsset *xjAsset=self.arrayAsset[assetIndex];
        if (xjAsset.selected) {
            [_buttonSelect setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check.png"] forState:UIControlStateNormal];
        }else{
            [_buttonSelect setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check_no.png"] forState:UIControlStateNormal];
        }
    }
}
#pragma mark scroll结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag==TAG_DELEGATE) {
        int index=scrollView.contentOffset.x/scrollView.frame.size.width;
        UIScrollView *view=scrollView.subviews[index];
        NSInteger assetIndex=view.tag-TAG_START;
        XJAsset *xjAsset=self.arrayAsset[assetIndex];
        if (xjAsset.selected) {
            [_buttonSelect setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check.png"] forState:UIControlStateNormal];
        }else{
            [_buttonSelect setImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/check_no.png"] forState:UIControlStateNormal];
        }
        [self switchView:scrollView];
    }
}
#pragma mark scroll缩放视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(scrollView.tag!=TAG_DELEGATE){
        return scrollView.subviews.lastObject;
    }
    return nil;
}
#pragma mark scroll开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if (scrollView.tag!=TAG_DELEGATE) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}
#pragma mark scroll缩放过程
-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.tag!=TAG_DELEGATE) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        UIView *view=(UIView *)scrollView.subviews.lastObject;
        view.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);
    }
}
#pragma mark scroll结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scrollView.tag!=TAG_DELEGATE) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:0.4];
        view.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            scrollView.contentSize.height * 0.5 + offsetY);
        [UIView commitAnimations];
    }
}
@end
