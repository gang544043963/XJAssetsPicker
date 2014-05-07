//
//  XJAssetsViewController.h
//  XJAssetsPicker
//
//  Created by LuPengDa on 14-1-17.
//  Copyright (c) 2014年 xj2014. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "XJAssetsPickerController.h"
#import "XJAssetsViewController.h"
#import "XJAssetsCell.h"
#import "XJAsset.h"
#import "MBProgressHUD.h"
#import "XJAssetsBrowerViewController.h"
#import "XJAssetsMediaPlayerViewController.h"

@interface XJAssetsViewController ()<XJAssetDelegate>{
    UIButton *_buttonSend;      ///<发送按钮
    UIButton *_buttonPreview;   ///<预览图片
//    NSMutableArray *_arrayAsset;           ///<资源列表Group所包含的所有XJAsset
}

@end

@implementation XJAssetsViewController
#pragma mark - 生命周期
#pragma mark 初始化
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.selectCount=0;
    }
    return self;
}
#pragma mark 界面加载完成viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    [self initialBar];
    self.navigationController.toolbarHidden=NO;
    //tableView设置
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self initialAsset];
    
}
#pragma mark 界面将要显示viewWillAppear
- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark 旋转方向发生改变时
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];

}
#pragma mark 初始化Bar
- (void)initialBar
{
    //leftBarButtonItem设置 返回
    UIButton *buttonLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonLeft.titleLabel.font=[UIFont systemFontOfSize:15];
    buttonLeft.bounds=CGRectMake(0, 0, 50, 29);
    [buttonLeft setTitle:@"  返回" forState:UIControlStateNormal];
    [buttonLeft setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/back.png"] forState:UIControlStateNormal];
    [buttonLeft setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/back_highlighted.png"] forState:UIControlStateHighlighted];
    [buttonLeft addTarget:self.parent action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItemLeft=[[UIBarButtonItem alloc]initWithCustomView:buttonLeft];
    self.navigationItem.leftBarButtonItem=barItemLeft;
    //rightBarButtonItem设置 取消
    UIButton *buttonRight=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonRight.titleLabel.font=[UIFont systemFontOfSize:15];
    buttonRight.bounds=CGRectMake(0, 0, 50, 29);
    [buttonRight setTitle:@"取消" forState:UIControlStateNormal];
    [buttonRight setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/cancel.png"] forState:UIControlStateNormal];
    [buttonRight setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/cancel_highlighted.png"] forState:UIControlStateHighlighted];
    [buttonRight addTarget:self.parent action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItemRight=[[UIBarButtonItem alloc]initWithCustomView:buttonRight];
    self.navigationItem.rightBarButtonItem=barItemRight;
    //toolbar设置 预览
    UIButton *buttonPreview=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonPreview.titleLabel.font=[UIFont systemFontOfSize:12];
    buttonPreview.bounds=CGRectMake(0, 0, 50, 29);
    [buttonPreview setTitle:@"预览" forState:UIControlStateNormal];
    [buttonPreview setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/cancel.png"] forState:UIControlStateNormal];
    [buttonPreview setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/cancel_highlighted.png"] forState:UIControlStateHighlighted];
    [buttonPreview addTarget:self action:@selector(preview:) forControlEvents:UIControlEventTouchUpInside];
    _buttonPreview=buttonPreview;
    UIBarButtonItem * barItemPreview=[[UIBarButtonItem alloc]initWithCustomView:buttonPreview];
    barItemPreview.enabled=NO;
    //toolbar设置 发送
    UIButton *buttonSend=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonSend.titleLabel.font=[UIFont systemFontOfSize:12];
    buttonSend.bounds=CGRectMake(0, 0, 50, 29);
    XJAssetsPickerController *picker=(XJAssetsPickerController *)self.parent;
    [buttonSend setTitle:picker.titleButtonSure forState:UIControlStateNormal];
    [buttonSend setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/send.png"] forState:UIControlStateNormal];
    [buttonSend setBackgroundImage:[UIImage imageNamed:@"XJAssetsPicker.bundle/send_highlighted.png"] forState:UIControlStateHighlighted];
    [buttonSend addTarget:self action:@selector(sendImage:) forControlEvents:UIControlEventTouchUpInside];
    _buttonSend=buttonSend;
    UIBarButtonItem * barItemSend=[[UIBarButtonItem alloc]initWithCustomView:buttonSend];
    barItemSend.enabled=NO;
    
    UIBarButtonItem * space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems=@[barItemPreview,space,barItemSend];
    
}
#pragma mark 初始化Asset
- (void)initialAsset
{
    _arrayAsset=[[NSMutableArray alloc]init];
    [_arrayAsset removeAllObjects];
    //显示指示器
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    // 获取全局调度队列,后面的标记永远是0
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 创建调度群组
    dispatch_group_t group = dispatch_group_create();
    // 向调度群组添加异步任务，并指定执行的队列
    dispatch_group_async(group, queue, ^{
        //遍历AssetsGroup,并给赋值给_arrayAsset
        [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                XJAsset *asset=[[XJAsset alloc]initWithAsset:result];
                asset.parent=self;
                [_arrayAsset addObject:asset];
            }else{
//                _arrayAsset=[[[_arrayAsset reverseObjectEnumerator] allObjects]mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //隐藏指示器
                    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    //重新刷新数据
                    [self.tableView reloadData];
                });
            }
        }];
    });
}
#pragma mark - BarButton事件
#pragma mark 跳到预览界面
- (void)preview:(id)sender
{
    [self toPreviewFromCurrentView:self showViewAtIndex:0];
}
#pragma mark 完成选择图片
- (void)sendImage:(id)sender
{
    NSMutableArray *arrayInfo=[[NSMutableArray alloc]init];
    for (XJAsset *asset in _arrayAsset) {
        if (asset.selected) {
            [arrayInfo addObject:asset.asset];
        }
    }
    [self.parent selectedAssets:arrayInfo original:NO];
}

#pragma mark - TableView数据源及委托事件
#pragma mark 返回tableView的组数:section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark 返回组数所对应的行数:row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    XJAssetsCell *cell=[[XJAssetsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    int count=_arrayAsset.count/cell.columnsCount;
    int count1=_arrayAsset.count%cell.columnsCount>0?1:0;
    return count+count1;
}
#pragma mark 返回tableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellPortrait = @"CellPortrait";
    static NSString *CellLandscape=@"CellLandscape";
    XJAssetsCell *cell=nil;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellLandscape];
        if (cell==nil) {
            cell=[[XJAssetsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellLandscape];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellPortrait];
        if (cell==nil) {
            cell=[[XJAssetsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellPortrait];
        }
    }
    int columnsCount=cell.columnsCount;
    // 截取的开始位置
    int location = indexPath.row * columnsCount;
    // 截取的长度
    int length = columnsCount;
    // 如果截取的范围越界
    if (location + length >= _arrayAsset.count) {
        length = _arrayAsset.count - location;
    }
    // 截取范围
    NSRange range = NSMakeRange(location, length);
    // 根据截取范围，获取这行所需的产品
    NSArray *arrayRowAssets = [_arrayAsset subarrayWithRange:range];
    // 设置这个行Cell所需的产品数据
    cell.arrayRowAssets=arrayRowAssets;
    
    __unsafe_unretained XJAssetsViewController *assetView=self;
    cell.blockPreview=^(XJAsset *asset){
        int index=[assetView.arrayAsset indexOfObject:asset];
        [assetView toPreviewFromCurrentView:assetView showViewAtIndex:index+1];
    };
    return cell;
}
#pragma mark 返回UITableViwCell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_SIZE+CELL_SPACE_DISTANCE*2;
}
#pragma mark - 自定义方法
#pragma mark 跳转到预览界面具体方法
- (void)toPreviewFromCurrentView:(XJAssetsViewController *)assetsView showViewAtIndex:(NSInteger)index
{
    XJAssetsPickerController *assetsPicker=(XJAssetsPickerController *)assetsView.parent;
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    if (assetsPicker.AssetType==AssetsPickerAssetPhoto) {
        XJAssetsBrowerViewController *browerViewController=[[XJAssetsBrowerViewController alloc]initWithNibName:nil bundle:nil];
        XJAssetsPickerController *picker=(XJAssetsPickerController *)self.parent;
        browerViewController.titleButtonSure=picker.titleButtonSure;
        browerViewController.parent=assetsView.parent;
        browerViewController.selectCount=assetsView.selectCount;
        NSMutableArray *arraySelect=[[NSMutableArray alloc]init];
        if (index==0) {
            browerViewController.currentIndex=index;
            for (XJAsset *xjAsset in assetsView.arrayAsset) {
                if (xjAsset.selected) {
                    [arraySelect addObject:xjAsset];
                }
            }
        }else{
            browerViewController.currentIndex=index-1;
            arraySelect=assetsView.arrayAsset;
        }
        browerViewController.arrayAsset=arraySelect;
        [assetsView.navigationController pushViewController:browerViewController animated:NO];
    }
    if (assetsPicker.AssetType==AssetsPickerAssetVideo) {
        XJAssetsMediaPlayerViewController *mediaPlayer=[[XJAssetsMediaPlayerViewController alloc]initWithNibName:nil bundle:nil];
        XJAssetsPickerController *picker=(XJAssetsPickerController *)self.parent;
        mediaPlayer.titleButtonSure=picker.titleButtonSure;
        mediaPlayer.parent=assetsView.parent;
        if (index==0) {
            for (XJAsset *xjAsset in assetsView.arrayAsset) {
                if (xjAsset.selected) {
                    mediaPlayer.xjAsset=xjAsset;
                    break;
                }
            }
        }else{
            mediaPlayer.xjAsset=assetsView.arrayAsset[index-1];
        }
        
        [assetsView.navigationController pushViewController:mediaPlayer animated:NO];
    }
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:assetsView.navigationController.view cache:NO];
    [UIView commitAnimations];
}
#pragma mark - 委托事件
#pragma mark 确定该资源是否可以选择
- (BOOL)assetShouldSelect:(XJAsset *)asset
{
    BOOL shouldSelect=YES;
    if (asset.selected) {
        self.selectCount--;
    }else{
        if((shouldSelect=[self.parent shouldSelectAsset:asset previousCount:self.selectCount])){
            self.selectCount++;
        }
    }
    XJAssetsPickerController *picker=(XJAssetsPickerController *)self.parent;
    NSString *titleSend=@"";
    NSString *titlePreview=@"";
    if (self.selectCount==0) {
        _buttonSend.enabled=NO;
        _buttonPreview.enabled=NO;
        titleSend=picker.titleButtonSure;
        titlePreview=@"预览";
    }else{
        _buttonSend.enabled=YES;
        _buttonPreview.enabled=YES;
        titleSend=[NSString stringWithFormat:@"%@(%d)",picker.titleButtonSure,self.selectCount];
        titlePreview=[NSString stringWithFormat:@"预览(%d)",self.selectCount];
    }
    [_buttonSend setTitle:titleSend forState:UIControlStateNormal];
    [_buttonPreview setTitle:titlePreview forState:UIControlStateNormal];
    return shouldSelect;
}

@end
