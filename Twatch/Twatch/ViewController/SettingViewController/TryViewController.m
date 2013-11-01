//
//  TryViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "TryViewController.h"

@interface TryViewController ()

-(void)didFinishedCapture:(UIImage*)_img;
-(void)foucusStatus:(BOOL)isadjusting;

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
    
    _photoView = [[UIView alloc] initWithFrame:bounds];
    [self.view addSubview:_photoView];
    
    _cameraView = [[CameraImageHelper alloc] init];
    [_cameraView embedPreviewInView:_photoView];
    [_cameraView changePreviewOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    [_cameraView setDelegate:self];
    
    UIImage *img = nil;
    NSInteger style = [[NSUserDefaults standardUserDefaults] integerForKey:WatchStyleStatus];
    if (style == wBlack) {
        img = [UIImage imageNamed:@"黑展开.png"];
    }else if (style == wRed){
        img = [UIImage imageNamed:@"红展开.png"];
    }else if (style == wBlue){
        img = [UIImage imageNamed:@"蓝展开.png"];
    }
    UIImageView *bgView = [[UIImageView alloc] initWithImage:img];
    bgView.center = self.view.center;
    [self.view addSubview:bgView];
    
    _cameraButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-50.0)/2, bounds.size.height-70.0, 50.0, 50.0)];
    [_cameraButton setImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateNormal];
    [_cameraButton setImage:[UIImage imageNamed:@"拍照-push.png"] forState:UIControlStateHighlighted];
    [_cameraButton addTarget:self action:@selector(captureImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 开始实时取景
    [_cameraView startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_cameraView stopRunning];
}

- (void)captureImage:(id)sender
{
    [_cameraView CaptureStillImage];
}

#pragma mark -
#pragma mark - AVHelperDelegate method

-(void)didFinishedCapture:(UIImage*)_img
{
    [_cameraView stopRunning];
}

-(void)foucusStatus:(BOOL)isadjusting
{
    
}

@end
