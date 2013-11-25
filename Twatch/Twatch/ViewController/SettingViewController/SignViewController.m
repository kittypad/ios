//
//  SignViewController.m
//  Twatch
//
//  Created by wangjizeng on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "SignViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImage+Tool.h"
#import "ShareViewController.h"
#import "FXLabel.h"

@interface SignViewController ()

@property (nonatomic, strong) UITextField *signtextfield;

@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic, strong) FXLabel *label;

@end


@implementation SignViewController

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
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"rooView_bg.png"]];
    
//    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-47.0, (IS_IOS7 ? 64 :44) - 25 -7.0 , 25.0, 25.0)];
    
    UIButton *shareButton = [FactoryMethods buttonWWithNormalImage:@"share.png" hiliteImage:@"share-push.png" target:self selector:@selector(share:)];
    shareButton.frame = CGRectChangeOrigin(shareButton.frame,self.view.frame.size.width - CGRectGetWidth(shareButton.frame)-15, (IS_IOS7 ? 64 :44) - CGRectGetHeight(shareButton.frame) - 5);
//    [shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
//    [shareButton setImage:[UIImage imageNamed:@"share-push.png"] forState:UIControlStateHighlighted];
//    [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    UIImage *img = [UIImage imageNamed:@"表扣-蓝.png"];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    bgView.center = CGPointMake(self.view.center.x, self.view.center.y + 20);// self.view.center;
    [self.view addSubview:bgView];
    self.bgView = bgView;
    
    NSInteger style = [[NSUserDefaults standardUserDefaults] integerForKey:WatchStyleStatus];
    if (style == wBlack) {
        bgView.image = [UIImage imageNamed:@"表扣-黑.png"];
    }else if (style == wRed){
        bgView.image = [UIImage imageNamed:@"表扣-红.png"];
    }else if (style == wBlue){
        bgView.image = [UIImage imageNamed:@"表扣-蓝.png"];
    }
    bgView.userInteractionEnabled = YES;
    
    UITextField *signtextfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 89, 30.0)];
    signtextfield.center = CGPointMake(img.size.width/2+2, img.size.height/2+45);
    signtextfield.backgroundColor = [UIColor clearColor];
    signtextfield.textColor = [UIColor whiteColor];
    signtextfield.font = [UIFont systemFontOfSize:20.0f];
    signtextfield.layer.borderWidth = 0.5;
    signtextfield.delegate = self;
    signtextfield.placeholder = NSLocalizedString(@"Input", nil);
    signtextfield.returnKeyType = UIReturnKeyDone;
    signtextfield.textAlignment = NSTextAlignmentCenter;
    UIColor *color = [UIColor colorWithHex:@"ffffff"];
    signtextfield.layer.borderColor = color.CGColor;

    [bgView addSubview:signtextfield];
    self.signtextfield = signtextfield;
    
    FXLabel *label = [[FXLabel alloc] initWithFrame:signtextfield.frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.shadowOffset = CGSizeMake(1.0, 1.0);
    label.innerShadowOffset = CGSizeMake(0.0, 1.0);
    label.hidden = YES;
    
    [bgView addSubview:label];
    self.label = label;
    
    if (style == wBlack) {
        label.textColor = [UIColor colorWithHex:@"4b4a4a"];
        label.innerShadowColor = [UIColor colorWithHex:@"1d0008"];
        label.shadowColor = [UIColor colorWithHex:@"555555"];
    }else if (style == wRed){
        label.textColor = [UIColor colorWithHex:@"952328"];
        label.innerShadowColor = [UIColor colorWithHex:@"1d0008"];
        label.shadowColor = [UIColor colorWithHex:@"cf444b"];
    }else if (style == wBlue){
        label.textColor = [UIColor colorWithHex:@"09437d"];
        label.innerShadowColor = [UIColor colorWithHex:@"1d0008"];
        label.shadowColor = [UIColor colorWithHex:@"14508f"];
    }
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [signtextfield becomeFirstResponder];
}


-(void)keyboardWillShow:(NSNotification*)notification{
    //调整UI位置
    NSTimeInterval animationDuration = 0.25f;
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.bgView.center = CGPointMake(self.view.center.x, self.view.center.y-70);
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSTimeInterval animationDuration = 0.25f;
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.bgView.center = self.view.center;
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    
    self.label.text = @"";
    self.label.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text sizeWithFont:[UIFont systemFontOfSize:13]].width > CGRectGetWidth(textField.frame)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LengthOvered", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    [textField resignFirstResponder];
    
    self.label.text = textField.text;
    self.label.hidden = NO;
    
    textField.text = @" ";
    
    return YES;
}

-(void)share:(id)sender
{
    UIImage *image = [UIImage imageFromView:self.bgView view:self.label];
    id<ISSCAttachment> shareImage = [ShareSDK pngImageWithImage:image];
    
    ShareViewController *vc = [[ShareViewController alloc] initWithContent:NSLocalizedString(@"EngravingshareView", nil)
                                                            defaultContent:NSLocalizedString(@"EngravingshareView", nil)
                                                                     image:shareImage
                                                                     title:NSLocalizedString(@"T-FrieShare", nil)
                                                                       url:@"r.tomoon.cn/kezi"
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
