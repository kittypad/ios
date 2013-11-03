//
//  TryViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "TryViewController.h"
#import "TryAdjustViewController.h"
#import "UIImage+Tool.h"
#import "MMProgressHUD.h"
#import <ShareSDK/ShareSDK.h>


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
        img = [UIImage imageNamed:@"黑展开.png"];
    }else if (style == wRed){
        img = [UIImage imageNamed:@"红展开.png"];
    }else if (style == wBlue){
        img = [UIImage imageNamed:@"蓝展开.png"];
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
    
    CGRect frame = self.view.bounds;
    frame.size.height = 40.0;
    _topView = [[UIView alloc] initWithFrame:frame];
    _topView.backgroundColor = [UIColor blackColor];
    _topView.alpha = 0.6;
    [self.view addSubview:_topView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(22.0, 5.0, 25.0, 25.0)];
    [backButton setImage:[UIImage imageNamed:@"camera-back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"camera-back-push.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:backButton];
    
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-47.0, 7.0, 25.0, 25.0)];
    [_shareButton setImage:[UIImage imageNamed:@"camera-share.png"] forState:UIControlStateNormal];
    [_shareButton setImage:[UIImage imageNamed:@"camera-share-push.png"] forState:UIControlStateHighlighted];
    [_shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_shareButton];
    _shareButton.hidden = YES;
    
    _scale = 1.0;

}

- (void)share:(id)sender
{
//    [self shareTitle:@"" content:@"帮我看看，戴着这块表够土豪吗？" image:_tryAdjustViewController.shareImage];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_tryAdjustViewController) {
        // 开始实时取景
        [_cameraView startRunning];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    UIImage *image = [_img scaleToSize:size];
    
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
    size = CGSizeMake(img.size.width*scale, img.size.height*scale);
    UIImage *scaleImage = [img scaleToSize:size];
    
    UIImage *finalImage = [image drawCenterImage:scaleImage];
    
    _tryAdjustViewController = [[TryAdjustViewController alloc] initWithFrame:self.view.bounds image:finalImage];
    [self addChildViewController:_tryAdjustViewController];
    [self.view insertSubview:_tryAdjustViewController.view belowSubview:_topView];
    _shareButton.hidden = NO;
    
    UIImageWriteToSavedPhotosAlbum(finalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

-(void)foucusStatus:(BOOL)isadjusting
{
    
}

@end
