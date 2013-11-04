//
//  TryViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "TryViewController.h"
#import "TryAdjustViewController.h"
#import "MMProgressHUD.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImage+Tool.h"


@interface TryViewController ()

-(void)didFinishedCapture:(UIImage*)_img;
-(void)foucusStatus:(BOOL)isadjusting;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

- (void)scale:(UIPinchGestureRecognizer*)sender;

@end

@implementation TryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    bounds.size.height = [[UIScreen mainScreen] bounds].size.height;
    self.view.bounds = bounds;
    
    _photoView = [[UIView alloc] initWithFrame:bounds];
    [self.view addSubview:_photoView];
    
    _cameraView = [[CameraImageHelper alloc] init];
    [_cameraView embedPreviewInView:_photoView];
    [_cameraView changePreviewOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    [_cameraView setDelegate:self];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [self.view addGestureRecognizer:pinch];
    
    UIImage *img = nil;
    NSInteger style = [[NSUserDefaults standardUserDefaults] integerForKey:WatchStyleStatus];
    if (style == wBlack) {
        img = [UIImage imageNamed:@"黑扣.png"];
    }else if (style == wRed){
        img = [UIImage imageNamed:@"红扣.png"];
    }else if (style == wBlue){
        img = [UIImage imageNamed:@"蓝扣.png"];
    }
    _bgView = [[UIImageView alloc] initWithImage:img];
    _bgView.center = self.view.center;
    _bgView.userInteractionEnabled = YES;
    [self.view addSubview:_bgView];
    
    _cameraButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-50.0)/2, bounds.size.height-70.0, 50.0, 50.0)];
    [_cameraButton setImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateNormal];
    [_cameraButton setImage:[UIImage imageNamed:@"拍照-push.png"] forState:UIControlStateHighlighted];
    [_cameraButton addTarget:self action:@selector(captureImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraButton];
    
    _topView = [self.view viewWithTag:1322];
    _topView.frame = CGRectMake(0, 0,  CGRectGetWidth(self.view.frame), 44.0);
    _topView.backgroundColor = [UIColor blackColor];
    _topView.alpha = 0.6;
    for (UIView *subView in _topView.subviews) {
        CGRect frame = subView.frame;
        frame.origin.y -= 20.0;
        subView.frame = frame;
    }
    [self.view bringSubviewToFront:_topView];
    [_topView viewWithTag:1323].hidden = YES;//hide line
    
    
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-47.0, 9.0, 25.0, 25.0)];
    [_shareButton setImage:[UIImage imageNamed:@"camera-share.png"] forState:UIControlStateNormal];
    [_shareButton setImage:[UIImage imageNamed:@"camera-share-push.png"] forState:UIControlStateHighlighted];
    [_shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_shareButton];
    _shareButton.hidden = YES;
    
    _scale = 1.0;

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)share:(id)sender
{
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo, ShareTypeTencentWeibo, ShareTypeQQSpace, ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeRenren, ShareTypeDouBan, nil];
    
    UIImage *img = _tryAdjustViewController.shareImage;
    id<ISSCAttachment> shareImage = nil;
    SSPublishContentMediaType shareType = SSPublishContentMediaTypeText;
    if(img)
    {
        shareImage = [ShareSDK pngImageWithImage:img];
        shareType = SSPublishContentMediaTypeNews;
    }
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"土曼share"
                                       defaultContent:@"帮我看看，戴着这块表够土豪吗？"
                                                image:shareImage
                                                title:@"土曼手表分享"
                                                  url:@"http://www.tomoon.cn"
                                          description:@""
                                            mediaType:shareType];
    
    id<ISSShareOptions> op = [ShareSDK defaultShareOptionsWithTitle:nil oneKeyShareList:shareList qqButtonHidden:YES wxSessionButtonHidden:NO wxTimelineButtonHidden:NO showKeyboardOnAppear:NO shareViewDelegate:nil friendsViewDelegate:nil picViewerViewDelegate:nil];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: op
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if (!_tryAdjustViewController) {
        // 开始实时取景
        [_cameraView startRunning];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [_cameraView stopRunning];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)captureImage:(id)sender
{
    [_cameraView CaptureStillImage];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error != NULL){
        [MMProgressHUD dismissWithError:@"保存图片到相册失败" title:@"" afterDelay:1.5];
    }else{
        [MMProgressHUD dismissWithSuccess:@"图片已成功保存到相册" title:@"" afterDelay:1.5];
    }
}

- (void)scale:(UIPinchGestureRecognizer*)sender
{
    //当手指离开屏幕时,将lastscale设置为1.0
    if([sender state] == UIGestureRecognizerStateEnded) {
        _lastScale = 1.0;
        return;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    _scale *= scale;
    if (_scale>1.0) {
        _scale = 1.0;
    }
    if (_scale<0.5) {
        _scale = 0.5;
    }
    CGAffineTransform newTransform = CGAffineTransformScale(CGAffineTransformIdentity, _scale, _scale);
    
    [_bgView setTransform:newTransform];
    _lastScale = [sender scale];
}

#pragma mark -
#pragma mark - AVHelperDelegate method

- (void)didFinishedCapture:(UIImage*)_img
{
    [_cameraView stopRunning];
    
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    [MMProgressHUD showWithTitle:@"" status:@"图片处理中..."];
    
    CGSize size = self.view.bounds.size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    size = CGSizeMake(size.width*scale, size.height*scale);
    UIImage *image = [_img scaleToScale:size.width/_img.size.width];
    
    UIImage *img = nil;
    NSInteger style = [[NSUserDefaults standardUserDefaults] integerForKey:WatchStyleStatus];
    if (style == wBlack) {
        img = [UIImage imageNamed:@"黑扣.png"];
    }else if (style == wRed){
        img = [UIImage imageNamed:@"红扣.png"];
    }else if (style == wBlue){
        img = [UIImage imageNamed:@"蓝扣.png"];
    }
    
    scale *= _scale;
    UIImage *scaleImage = [img scaleToScale:scale];
    
    UIImage *finalImage = [image drawCenterImage:scaleImage];
    
    _tryAdjustViewController = [[TryAdjustViewController alloc] initWithFrame:self.view.bounds image:finalImage];
    [self addChildViewController:_tryAdjustViewController];
    _tryAdjustViewController.view.alpha = 0.0;
    [self.view insertSubview:_tryAdjustViewController.view belowSubview:_topView];
    _shareButton.hidden = NO;
    
    [UIView animateWithDuration:0.5
                     animations:^(void){
                         _tryAdjustViewController.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         _bgView = nil;
                     }];
    
    UIImageWriteToSavedPhotosAlbum(finalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

-(void)foucusStatus:(BOOL)isadjusting
{
    
}

@end
