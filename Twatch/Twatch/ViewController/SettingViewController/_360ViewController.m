//
//  360ViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "_360ViewController.h"
#import "FVImageSequence.h"
#import <ShareSDK/ShareSDK.h>
#import "ShareViewController.h"

@interface _360ViewController ()
@property(nonatomic,strong)FVImageSequence *imageSquence;
//@property (nonatomic, strong) UIImageView *bgView;
@end

@implementation _360ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *shareButton = [FactoryMethods buttonWWithNormalImage:@"share.png" hiliteImage:@"share-push.png" target:self selector:@selector(share:)];
    shareButton.frame = CGRectChangeOrigin(shareButton.frame,self.view.frame.size.width - CGRectGetWidth(shareButton.frame)-15, (IS_IOS7 ? 64 :44) - CGRectGetHeight(shareButton.frame) - 5);
    [self.view addSubview:shareButton];
    
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(shareButton.frame)+5, 320, 568)];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    
    
    FVImageSequence *imageSquence = [[FVImageSequence alloc] initWithImage:[UIImage imageNamed:@"0_0.jpg"]];
    imageSquence.frame = CGRectChangeSize(imageSquence.frame,640,360);
    imageSquence.center = self.view.center;
    imageSquence.userInteractionEnabled = YES;
    [self.view addSubview:imageSquence];
    self.imageSquence = imageSquence;
    
    //Set slides extension
	[imageSquence setExtension:@"jpg"];
	
	//Set slide prefix prefix
	[imageSquence setPrefix:@"0_"];
	
	//Set number of slides
	[imageSquence setNumberOfImages:24];
    
}

- (void)goBack
{
    [super goBack];
    [self.imageSquence removeFromSuperview];
}

-(void)share:(id)sender
{
    ShareViewController *vc = [[ShareViewController alloc] initWithContent:NSLocalizedString(@"PanoramicshareView", nil)
                                                            defaultContent:NSLocalizedString(@"PanoramicshareView", nil)
                                                                     image:[ShareSDK jpegImageWithImage:self.imageSquence.image quality:1.0]
                                                                     title:NSLocalizedString(@"T-FrieShare", nil)
                                                                       url:@"r.tomoon.cn/rotate"
                                                               description:@""
                                                                 mediaType:SSPublishContentMediaTypeNews];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
