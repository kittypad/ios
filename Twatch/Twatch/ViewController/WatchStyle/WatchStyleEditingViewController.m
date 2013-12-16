//
//  WatchStyleEditingViewController.m
//  Twatch
//
//  Created by 龚涛 on 12/13/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "WatchStyleEditingViewController.h"
#import "UIImage+Tool.h"
#import "MMProgressHUD.h"

@interface WatchStyleEditingViewController ()
{
    UIImage *_image;
    UIImageView *_imageView;
    
    UIImageView *_frameView;
    
    CGFloat _degree;
}

- (void)_buttonPressed:(id)sender;

- (void)_updateImageView;

- (void)_rotateImageViewByDegree:(CGFloat)degree;

- (UIImage *)_imageFromEditingImage:(UIImage *)editingImage;

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
    
    _frameView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 160.0)];
    _frameView.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    _frameView.layer.borderWidth = 1.0;
    _frameView.layer.borderColor = [UIColor colorWithHex:@"00a8ff"].CGColor;
    [self.view addSubview:_frameView];
    
    NSArray *array = @[@"删除", @"左转", @"右转", @"保存"];
    
    CGRect frame = CGRectMake(65.0, self.view.frame.size.height - 63.0, 40.0, 40.0);
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", array[i]]]
                forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-按下.png", array[i]]]
                forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.view addSubview:button];
        frame.origin.x += 50.0;
    }
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

#pragma mark - Private

- (UIImage *)_imageFromEditingImage:(UIImage *)editingImage
{
    UIGraphicsBeginImageContext(CGSizeMake(240.0, 320.0));
    // 绘制图片
    CGFloat x = 2 * (_imageView.frame.origin.x - _frameView.frame.origin.x);
    CGFloat y = 2 * (_imageView.frame.origin.y - _frameView.frame.origin.y);
    CGFloat w = 2 * _imageView.frame.size.width;
    CGFloat h = 2 * _imageView.frame.size.height;
    
    [editingImage drawInRect:CGRectMake(x, y, w, h)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return image;
}

- (void)_buttonPressed:(id)sender
{
    switch ([sender tag]) {
        case 0: {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1: {
            [self _rotateImageViewByDegree:-90];
            break;
        }
        case 2: {
            [self _rotateImageViewByDegree:90];
            break;
        }
        case 3: {
            [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
            [MMProgressHUD showWithTitle:@"" status:NSLocalizedString(@"Processing", nil)];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                UIImage *resultImage = [self _imageFromEditingImage:[_image imageRotatedByDegrees:_degree]];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [MMProgressHUD dismissWithSuccess:NSLocalizedString(@"Done", nil)];
                    [_delegate didEndEditingImage:resultImage];
                    
                });
            });
            break;
        }
        default:
            break;
    }
}

- (void)_updateImageView
{
    CGFloat p = _imageView.frame.size.width / _imageView.frame.size.height;
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
}

- (void)_rotateImageViewByDegree:(CGFloat)degree
{
    _degree += degree;
    if (_degree > 360) {
        degree -= 360;
    }
    else if (_degree < 0) {
        _degree += 360;
    }
    _imageView.transform = CGAffineTransformMakeRotation(_degree * M_PI / 180);
    [self _updateImageView];
}

#pragma mark - Public

- (void)setImage:(UIImage *)image
{
    _imageView.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [self _updateImageView];
    _imageView.image = image;
    _image = image;
}

@end
