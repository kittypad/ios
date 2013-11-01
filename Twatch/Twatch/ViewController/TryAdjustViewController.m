//
//  TryAdjustViewController.m
//  Twatch
//
//  Created by 龚涛 on 11/1/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "TryAdjustViewController.h"

@interface TryAdjustViewController ()

- (void)back:(id)sender;
- (void)share:(id)sender;
- (void)filter:(id)sender;

@end

@implementation TryAdjustViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
        self.view.frame = frame;
        self.view.alpha = 0.0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.image = _image;
    [self.view addSubview:_imageView];
    
    CGRect frame = self.view.bounds;
    frame.size.height = 40.0;
    UIView *topView = [[UIView alloc] initWithFrame:frame];
    topView.backgroundColor = [UIColor blackColor];
    topView.alpha = 0.6;
    [self.view addSubview:topView];
    
    frame = self.view.bounds;
    frame.size.height = 60.0;
    frame.origin.y = self.view.frame.size.height-frame.size.height;
    UIView *bottomView = [[UIView alloc] initWithFrame:frame];
    bottomView.backgroundColor = [UIColor blackColor];
    bottomView.alpha = 0.6;
    [self.view addSubview:bottomView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(22.0, 5.0, 25.0, 25.0)];
    [backButton setImage:[UIImage imageNamed:@"camera-back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"camera-back-push.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-47.0, 7.0, 25.0, 25.0)];
    [shareButton setImage:[UIImage imageNamed:@"camera-share.png"] forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"camera-share-push.png"] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:shareButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5
                     animations:^(void){
                         self.view.alpha = 1.0;
                     }];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)share:(id)sender
{
    
}

- (void)filter:(id)sender
{
    
}

@end
