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
    
    CGFloat _degree;
}

- (void)_buttonPressed:(id)sender;

- (void)_updateImageView;

- (void)_rotateImageViewByDegree:(CGFloat)degree;

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
    
    NSArray *array = @[@"删除", @"左转", @"右转", @"保存"];
    
    CGRect frame = CGRectMake(20.0, self.view.frame.size.height - 45.0, 40.0, 40.0);
    for (int i = 0; i < array.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", array[i]]]
                forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-按下.png", array[i]]]
                forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.view addSubview:button];
        frame.origin.x += 80.0;
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

- (void)_buttonPressed:(id)sender
{
    switch ([sender tag]) {
        case 0: {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1: {
            [self _rotateImageViewByDegree:-90];
//            [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
//            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
//            [MMProgressHUD showWithTitle:@"" status:NSLocalizedString(@"Processing", nil)];
//            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//                UIImage *image = [_image imageRotatedByDegrees:270];
//                dispatch_async(dispatch_get_main_queue(), ^(void){
//                    [self setImage:image];
//                    [MMProgressHUD dismissWithSuccess:NSLocalizedString(@"Done", nil)];
//                });
//            });
            
            break;
        }
        case 2: {
            [self _rotateImageViewByDegree:90];
//            [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
//            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
//            [MMProgressHUD showWithTitle:@"" status:NSLocalizedString(@"Processing", nil)];
//            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//                UIImage *image = [_image imageRotatedByDegrees:90];
//                dispatch_async(dispatch_get_main_queue(), ^(void){
//                    [self setImage:image];
//                    [MMProgressHUD dismissWithSuccess:NSLocalizedString(@"Done", nil)];
//                });
//            });
            
            break;
        }
        case 3: {
            
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
