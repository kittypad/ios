//
//  WatchStyleViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "WatchStyleViewController.h"

#import "BGColorButton.h"

#import "IconButton.h"

@interface WatchStyleViewController ()
{
    UIImageView *_imageView;
}

- (void)_handleButtonPressed:(id)sender;

- (void)_albumButtonPressed:(id)sender;

- (void)_cameraButtonPressed:(id)sender;

@end

@implementation WatchStyleViewController

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
    // Do any additional setup after loading the view from its nib.
    
    CGFloat y = IS_IOS7 ? 95.0 : 75.0;
    IconButton *albumButton = [[IconButton alloc] initWithFrame:CGRectMake(68.0, y, 77.0, 30.0)];
    albumButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [albumButton setTitleColor:[UIColor colorWithHex:@"333333"] forState:UIControlStateNormal];
    [albumButton setTitle:NSLocalizedString(@"Album", nil) forState:UIControlStateNormal];
    [albumButton setImage:[UIImage imageNamed:@"相册.png"] forState:UIControlStateNormal];
    [albumButton setImage:[UIImage imageNamed:@"相册-按下.png"] forState:UIControlStateHighlighted];
    [albumButton setBackgroundImage:[UIImage imageNamed:@"蓝边圆角按钮.png"] forState:UIControlStateNormal];
    [albumButton setBackgroundImage:[UIImage imageNamed:@"蓝边圆角按钮.png"] forState:UIControlStateHighlighted];
    [albumButton addTarget:self action:@selector(_albumButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumButton];
    
    IconButton *cameraButton = [[IconButton alloc] initWithFrame:CGRectMake(175.0, y, 77.0, 30.0)];
    cameraButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [cameraButton setTitleColor:[UIColor colorWithHex:@"333333"] forState:UIControlStateNormal];
    [cameraButton setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"相机.png"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"相机-按下.png"] forState:UIControlStateHighlighted];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"蓝边圆角按钮.png"] forState:UIControlStateNormal];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"蓝边圆角按钮.png"] forState:UIControlStateHighlighted];
    [albumButton addTarget:self action:@selector(_cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    
    BGColorButton *handleButton = [[BGColorButton alloc] initWithFrame:CGRectMake(22.0, self.view.frame.size.height-55.0, 276.0, 40.0)];
    handleButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    handleButton.titleLabel.textColor = [UIColor whiteColor];
    handleButton.titleLabel.text = NSLocalizedString(@"Handle", nil);
    [handleButton setBackgroundColor:[UIColor colorWithHex:@"6fc6fc"] forState:UIControlStateNormal];
    [handleButton setBackgroundColor:[UIColor colorWithHex:@"1ca1f6"] forState:UIControlStateHighlighted];
    [handleButton addTarget:self action:@selector(_handleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:handleButton];
    
    y = (self.view.frame.size.height + CGRectGetMaxY(cameraButton.frame) - 215.0)/2.0;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100.0, y, 120.0, 160.0)];
    [self.view addSubview:_imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_handleButtonPressed:(id)sender
{
    
}

- (void)_albumButtonPressed:(id)sender
{
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:type]) {
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.sourceType = type;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)_cameraButtonPressed:(id)sender
{
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    _imageView.image = image;
}

@end
