//
//  TryAdjustViewController.m
//  Twatch
//
//  Created by 龚涛 on 11/1/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "TryAdjustViewController.h"
#import "UIImage+Tool.h"

typedef enum{
    NormalStyle = 0,
    JapanStyle,
    FleetingStyle,
    HDRStyle,
    AxisStyle,
    ShowyStyle,
    EightsStyle,
}FilterStyle;

@interface TMFilterButton : UIButton

@end

@implementation TMFilterButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0.0, 39.0, 44.0, 18.0);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(6.0, 7.0, 32.0, 32.0);
}

@end

@interface TryAdjustViewController ()

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
        _shareImage = image;
        self.view.frame = frame;
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

    NSArray *array = @[NSLocalizedString(@"Default", nil), NSLocalizedString(@"Retro", nil), NSLocalizedString(@"Fleeting", nil), @"HDR",NSLocalizedString(@"Shift", nil), NSLocalizedString(@"Contrast", nil), @"80s"];
    NSArray *imgArray = @[@"默认", @"日系", @"流年", @"HDR", @"移轴", @"艳丽", @"80s"];
    frame = CGRectMake(6.0, 0.0, 44.0, 57.0);
    int i = 0;
    for (NSString *title in array) {
        TMFilterButton *button = [[TMFilterButton alloc] initWithFrame:frame];
        button.tag = i;
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [imgArray objectAtIndex:i]]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(filter:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
        frame.origin.x += frame.size.width;
        i++;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [UIImage freeTmpData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _image = nil;
    _shareImage = nil;
}

- (void)filter:(id)sender
{
    switch ([sender tag]) {
        case NormalStyle: {
            _shareImage = _image;
            break;
        }
        case JapanStyle: {
            _shareImage = [UIImage imageWithImage:_image withColorMatrix:colormatrix_danya];
            break;
        }
        case FleetingStyle: {
            _shareImage = [UIImage imageWithImage:_image withColorMatrix:colormatrix_qingning];
            break;
        }
        case HDRStyle: {
            _shareImage = [UIImage imageWithImage:_image withColorMatrix:colormatrix_landiao];
            break;
        }
        case AxisStyle: {
            _shareImage = [UIImage imageWithImage:_image withColorMatrix:colormatrix_gete];
            break;
        }
        case ShowyStyle: {
            _shareImage = [UIImage imageWithImage:_image withColorMatrix:colormatrix_ruise];
            break;
        }
        case EightsStyle: {
            _shareImage = [UIImage imageWithImage:_image withColorMatrix:colormatrix_huaijiu];
            break;
        }
        default:
            break;
    }
    [_imageView setImage:_shareImage];
}

@end
