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

-(void)viewWillDisappear:(BOOL)animated
{
    [self.imageSquence removeFromSuperview];
}

-(void)share:(id)sender
{
    //定义菜单分享列表
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeRenren, ShareTypeDouBan, nil];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:NSLocalizedString(@"PanoramicshareView", nil)
                                       defaultContent:NSLocalizedString(@"PanoramicshareView", nil)
                                                image:[ShareSDK jpegImageWithImage:self.imageSquence.image quality:1.0]
                                                title:NSLocalizedString(@"T-FrieShare", nil)
                                                  url:@"r.tomoon.cn/rotate"
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSShareOptions> op = [ShareSDK defaultShareOptionsWithTitle:nil oneKeyShareList:shareList qqButtonHidden:YES wxSessionButtonHidden:NO wxTimelineButtonHidden:NO showKeyboardOnAppear:NO shareViewDelegate:nil friendsViewDelegate:nil picViewerViewDelegate:nil];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: op
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
