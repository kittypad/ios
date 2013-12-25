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

#import "UIImage+Tool.h"

#import "MMProgressHUD.h"

#import "AFDownloadRequestOperation.h"

#import "BLEManager.h"

@interface WatchStyleViewController ()
{
    UIImageView *_imageView;
    UIImage *_image;
}

- (void)_handleButtonPressed:(id)sender;

- (void)_albumButtonPressed:(id)sender;

- (void)_cameraButtonPressed:(id)sender;

- (NSString *)_cacheFilePath;

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
    
    UIImage *image = [UIImage imageNamed:@"蓝边圆角按钮.png"];
    CGFloat p1 = image.size.width/2;
    CGFloat p2 = image.size.height/2;
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(p2, p1, p2, p1)];
    
    NSString *title = NSLocalizedString(@"Album", nil);
    CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:15.0]];
    CGFloat w = 77.0;
    if (size.width > 41.0) {
        w = size.width + 46.0;
    }
    IconButton *albumButton = [[IconButton alloc] initWithFrame:CGRectMake(145.0-w, y, w, 30.0)];
    albumButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [albumButton setTitleColor:[UIColor colorWithHex:@"333333"] forState:UIControlStateNormal];
    [albumButton setTitle:title forState:UIControlStateNormal];
    [albumButton setImage:[UIImage imageNamed:@"相册.png"] forState:UIControlStateNormal];
    [albumButton setImage:[UIImage imageNamed:@"相册-按下.png"] forState:UIControlStateHighlighted];
    [albumButton setBackgroundImage:image forState:UIControlStateNormal];
    [albumButton setBackgroundImage:image forState:UIControlStateHighlighted];
    [albumButton addTarget:self action:@selector(_albumButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumButton];
    
    title = NSLocalizedString(@"Camera", nil);
    size = [title sizeWithFont:[UIFont systemFontOfSize:15.0]];
    w = 77.0;
    if (size.width > 41.0) {
        w = size.width + 46.0;
    }
    IconButton *cameraButton = [[IconButton alloc] initWithFrame:CGRectMake(175.0, y, w, 30.0)];
    cameraButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [cameraButton setTitleColor:[UIColor colorWithHex:@"333333"] forState:UIControlStateNormal];
    [cameraButton setTitle:title forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"相机.png"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"相机-按下.png"] forState:UIControlStateHighlighted];
    [cameraButton setBackgroundImage:image forState:UIControlStateNormal];
    [cameraButton setBackgroundImage:image forState:UIControlStateHighlighted];
    [cameraButton addTarget:self action:@selector(_cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    
    BGColorButton *handleButton = [[BGColorButton alloc] initWithFrame:CGRectMake(22.0, self.view.frame.size.height-55.0, 276.0, 40.0)];
    handleButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    handleButton.titleLabel.textColor = [UIColor whiteColor];
    handleButton.titleLabel.text = NSLocalizedString(@"SendToWatch", nil);
    [handleButton setBackgroundColor:[UIColor colorWithHex:@"6fc6fc"] forState:UIControlStateNormal];
    [handleButton setBackgroundColor:[UIColor colorWithHex:@"1ca1f6"] forState:UIControlStateHighlighted];
    [handleButton addTarget:self action:@selector(_handleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:handleButton];
    
    y = (self.view.frame.size.height + CGRectGetMaxY(cameraButton.frame) - 215.0)/2.0;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100.0, y, 120.0, 160.0)];
    [self.view addSubview:_imageView];
    
    _image = [UIImage imageWithContentsOfFile:[self _cacheFilePath]];
    if (_image) {
        _imageView.image = _image;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_handleButtonPressed:(id)sender
{
    [[BLEManager sharedManager] sendBackgroundImageDataCommand:[self _cacheFilePath]];
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
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:type]) {
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.sourceType = type;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (NSString *)_cacheFilePath
{
    return [[AFDownloadRequestOperation cacheFolder] stringByAppendingPathComponent:@"imageData.jpg"];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    [MMProgressHUD showWithTitle:@"" status:NSLocalizedString(@"Processing", nil)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *newImage = [UIImage imageWithImage:[image scaleToSize:image.size]
                                    withColorMatrix:colormatrix_huaijiu];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [MMProgressHUD dismissWithSuccess:NSLocalizedString(@"Done", nil)];
            [self dismissViewControllerAnimated:NO completion:^(void){
                WatchStyleEditingViewController *vc = [[WatchStyleEditingViewController alloc] initWithNibName:nil bundle:nil];
                vc.delegate = self;
                [self presentViewController:vc animated:NO completion:^(void){
                    [vc setImage:newImage];
                }];
            }];
        });
    });
}

#pragma mark - WatchStyleEditingViewControllerDelegate

- (void)didEndEditingImage:(UIImage *)image
{
    _image = image;
    _imageView.image = image;
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:[self _cacheFilePath] atomically:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
