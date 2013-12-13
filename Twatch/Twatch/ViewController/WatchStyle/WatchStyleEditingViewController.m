//
//  WatchStyleEditingViewController.m
//  Twatch
//
//  Created by 龚涛 on 12/13/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "WatchStyleEditingViewController.h"

@interface WatchStyleEditingViewController ()

@end

@implementation WatchStyleEditingViewController

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
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    _imageView = [[UIImageView alloc] init];
    [self.view addSubview:_imageView];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Public

- (void)setImage:(UIImage *)image
{
    CGFloat p = image.size.width / image.size.height;
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    CGFloat p1 = w / h;
    if (p >= p1) {
        h = w / p;
        y = (self.view.bounds.size.height-h)/2;
    }
    else {
        w = h * p;
        x = (self.view.bounds.size.width-w)/2;
    }
    _imageView.frame = CGRectMake(x, y, w, h);
    _imageView.image = image;
}

@end
