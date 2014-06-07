//
//  MyCenterViewController.m
//  Twatch
//
//  Created by yugong on 14-5-22.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "MyCenterViewController.h"
#import "LoginViewController.h"

#import "MyCenterManagerViewController.h"

@interface MyCenterViewController ()

@property (nonatomic) UITextField* phoneNum;
@property (nonatomic) UITextField* password;

@end

@implementation MyCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"My", @"我的") image:[UIImage imageNamed:@"tabmycenter"] tag:2];
        self.tabBarItem = item;
        self.backName = NSLocalizedString(@"My Center", @"个人中心");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    UIButton* loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?174:154, 300, 40)];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"loginbtn"] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:loginBtn];
    
    UIButton* rigisterBtn = [[UIButton alloc] initWithFrame:CGRectMake(240, IS_IOS7?25:5, 70, 30)];
    [rigisterBtn setBackgroundImage:[UIImage imageNamed:@"loginbtn"] forState:UIControlStateNormal];
    [rigisterBtn setTitle:@"注册" forState:UIControlStateNormal];
    [rigisterBtn addTarget:self action:@selector(rigisterClicked) forControlEvents:UIControlEventTouchUpInside];
    rigisterBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:rigisterBtn];
    
    //处理虚拟键盘
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    NSArray *subviews = [self.view subviews];
    for (id objInput in subviews) {
        if ([objInput isKindOfClass:[UITextField class]]) {
            UITextField *theTextField = objInput;
            if ([objInput isFirstResponder]) {
                [theTextField resignFirstResponder];
            }
        }
    }
}

-(void)loginClicked
{
    MyCenterManagerViewController* myCenterManagerController = [[MyCenterManagerViewController alloc] init];
    myCenterManagerController.backName = NSLocalizedString(@"My Center", @"个人中心");
    [self.navigationController pushViewController:myCenterManagerController animated:YES];
    
    NSDictionary* dic;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logintomycenter" object:dic];
}

-(void)rigisterClicked
{
    LoginViewController* loginView = [[LoginViewController alloc] init];
    loginView.backName = @"个人注册";
    [self.navigationController pushViewController:loginView animated:YES];
    //[self presentViewController:loginView animated:YES completion:nil];
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
