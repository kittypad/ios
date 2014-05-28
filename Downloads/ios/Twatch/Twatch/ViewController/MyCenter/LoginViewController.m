//
//  LoginViewController.m
//  Twatch
//
//  Created by yugong on 14-5-23.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (nonatomic) UITextField* phoneNum;
@property (nonatomic) UITextField* password;
@property (nonatomic) UITextField* passwordagain;
@property (nonatomic) UITextField* captcha;

@end

@implementation LoginViewController

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
    [self.backBtn setHidden:YES];
    
    UIButton* backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?25:5, 30, 30)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:backBtn];
    
    self.phoneNum = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?74:54, 300, 40)];
    [self.phoneNum setBackgroundColor:[UIColor whiteColor]];
    [self.phoneNum setPlaceholder:@"填入手机号"];
    self.phoneNum.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.phoneNum.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.phoneNum];
    
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?124:104, 300, 40)];
    [self.password setBackgroundColor:[UIColor whiteColor]];
    self.password.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.password setPlaceholder:@"密码，不能少于4位"];
    self.password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.password];
    
    self.passwordagain = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?174:154, 300, 40)];
    [self.passwordagain setBackgroundColor:[UIColor whiteColor]];
    [self.passwordagain setPlaceholder:@"确认密码"];
    self.passwordagain.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordagain.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.passwordagain];
    
    self.captcha = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?224:204, 140, 40)];
    [self.captcha setBackgroundColor:[UIColor whiteColor]];
    self.captcha.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.captcha setPlaceholder:@"验证码"];
    self.captcha.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.captcha];
    
    UIButton* loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, IS_IOS7?224:204, 150, 40)];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"loginbtn"] forState:UIControlStateNormal];
    [loginBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(postCaptchaClicked) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:loginBtn];
    
     UIButton* captchaBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?274:254, 300, 40)];
     [captchaBtn setBackgroundImage:[UIImage imageNamed:@"loginbtn"] forState:UIControlStateNormal];
     [captchaBtn setTitle:@"注册" forState:UIControlStateNormal];
     [captchaBtn addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:captchaBtn];
     
    //处理虚拟键盘
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)postCaptchaClicked
{
}

-(void)loginClicked
{
    
}

- (void)backClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
