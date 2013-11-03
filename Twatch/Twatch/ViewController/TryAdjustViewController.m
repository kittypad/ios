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
    frame.size.height = 60.0;
    frame.origin.y = self.view.frame.size.height-frame.size.height;
    UIView *bottomView = [[UIView alloc] initWithFrame:frame];
    bottomView.backgroundColor = [UIColor blackColor];
    bottomView.alpha = 0.6;
    [self.view addSubview:bottomView];
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

- (void)filter:(id)sender
{
    
}

@end
