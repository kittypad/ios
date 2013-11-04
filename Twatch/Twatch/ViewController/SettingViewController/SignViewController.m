//
//  SignViewController.m
//  Twatch
//
//  Created by wangjizeng on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "SignViewController.h"

@interface SignViewController ()

@property (nonatomic, strong) UITextField *signtextfield;

@property (nonatomic, strong) UIImageView *bgView;
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
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-47.0, (IS_IOS7 ? 64 :44) - 25 -7.0 , 25.0, 25.0)];
    [shareButton setImage:[UIImage imageNamed:@"camera-share.png"] forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"camera-share-push.png"] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
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
    
    UITextField *signtextfield = [[UITextField alloc] initWithFrame:CGRectMake(89, 130, 89, 37.5)];
//    signtextfield.borderStyle = UITextBorderStyleRoundedRect;
    signtextfield.backgroundColor = [UIColor clearColor];
    signtextfield.textColor = [UIColor whiteColor];
    signtextfield.font = [UIFont systemFontOfSize:13.0f];
    signtextfield.layer.borderWidth = 0.5;
    signtextfield.delegate = self;
    signtextfield.placeholder = NSLocalizedString(@"Input", nil);
    signtextfield.returnKeyType = UIReturnKeyDone;
    signtextfield.textAlignment = NSTextAlignmentCenter;
    UIColor *color = [UIColor getColor:@"ffffff"];
    signtextfield.layer.borderColor = color.CGColor;

    [bgView addSubview:signtextfield];
    self.signtextfield = signtextfield;
    
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
    self.bgView.center = CGPointMake(self.view.center.x, self.view.center.y-40);
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text sizeWithFont:[UIFont systemFontOfSize:13]].width > CGRectGetWidth(textField.frame)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LengthOvered", nil) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    [textField resignFirstResponder];
    return YES;
}

-(void)share :(id)sender
{
#warning need share feature

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
