//
//  MyCenterViewController.m
//  Twatch
//
//  Created by yugong on 14-5-22.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "MyCenterViewController.h"
#import "LoginViewController.h"
#import "DataManager.h"
#import <SBJson.h>

#import "MyCenterManagerViewController.h"
#import "FindPasswordViewController.h"
#import "NetDatamanager.h"

@interface MyCenterViewController ()
{
    MyCenterManagerViewController* myCenterManagerController;
    NSURLConnection *loginconnection;
    MBProgressHUD *hud;
    BOOL blogin;
}

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
    blogin = NO;
    
    self.phoneNum = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?74:54, 300, 40)];
    [self.phoneNum setBackgroundColor:[UIColor whiteColor]];
    [self.phoneNum setPlaceholder:@"填入手机号"];
    self.phoneNum.delegate = self;
    self.phoneNum.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.phoneNum.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.phoneNum];
    
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?124:104, 300, 40)];
    [self.password setBackgroundColor:[UIColor whiteColor]];
    self.password.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.password setPlaceholder:@"密码，不能少于4位"];
    [self.password setSecureTextEntry:YES];
    self.password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.password];
    
    UIButton* getBackPasswordBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, IS_IOS7?174:154, 100, 40)];
    getBackPasswordBtn.backgroundColor = [UIColor clearColor];
    [getBackPasswordBtn addTarget:self action:@selector(GetBackPasswordClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getBackPasswordBtn];
    
    UILabel* getPasswordLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, IS_IOS7?174:154, 100, 40)];
    getPasswordLabel.numberOfLines = 3;
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"找回密码"]];
    NSRange contentRange = {0,[content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    getPasswordLabel.attributedText = content;
    getPasswordLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:getPasswordLabel];
    
    UIButton* loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?224:204, 300, 40)];
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
    
    myCenterManagerController = [[MyCenterManagerViewController alloc] init];
}

//限制输入字符数量
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (temp.length > 11) {
        textField.text = [temp substringToIndex:11];
        return NO;
    }
    return YES;
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

-(void)GetBackPasswordClicked
{
    FindPasswordViewController* findPasswordController = [[FindPasswordViewController alloc] init];
    findPasswordController.backName = @"找回密码";
    [self.navigationController pushViewController:findPasswordController animated:YES];
}

-(void)loginClicked
{
    NSString* user = self.phoneNum.text;
    NSString* password = self.password.text;
    
    if (user==nil || [user isEqualToString:@""] || password==nil || [password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"手机号码或密码为空了，亲！"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (password.length<4) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"密码不能少于4个，亲！"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    hud= [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"登录中...";
    hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:hud];
    [hud show:YES];
    
   [[NetDatamanager sharedManager] login:user password:password success:^(id response, NSString* str){
        //        NSMutableDictionary* allmessagedic = response;
        
        if ([str isEqualToString:@"0"]) {
            [hud hide:YES];
            myCenterManagerController.backName = NSLocalizedString(@"My Center", @"个人中心");
            [self.navigationController pushViewController:myCenterManagerController animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logintomycenter" object:self.phoneNum.text];
        }
        else
        {
            hud.labelText = [[NetDatamanager sharedManager] alertMessage:str];
            [hud hide:YES afterDelay:2];
        }
    }failure:^(NSError* error){
        hud.labelText = [error localizedDescription];
        [hud hide:YES afterDelay:2];
    }];
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
