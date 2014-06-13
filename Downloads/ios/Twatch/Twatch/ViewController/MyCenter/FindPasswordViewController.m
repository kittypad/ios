//
//  FindPasswordViewController.m
//  Twatch
//
//  Created by yugong on 14-6-13.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "FindPasswordViewController.h"
#import "DataManager.h"
#import <SBJson.h>

@interface FindPasswordViewController ()
{
    NSURLConnection *sendfindcodeconnection;
    NSURLConnection *findpasswordconnection;
}

@property (nonatomic) UITextField* phoneNum;
@property (nonatomic) UITextField* password;
@property (nonatomic) UITextField* passwordagain;
@property (nonatomic) UITextField* captcha;

@end

@implementation FindPasswordViewController

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
    
    self.passwordagain = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?174:154, 300, 40)];
    [self.passwordagain setBackgroundColor:[UIColor whiteColor]];
    [self.passwordagain setPlaceholder:@"确认密码"];
    [self.passwordagain setSecureTextEntry:YES];
    self.passwordagain.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordagain.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.passwordagain];
    
    self.captcha = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?224:204, 140, 40)];
    [self.captcha setBackgroundColor:[UIColor whiteColor]];
    self.captcha.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.captcha setPlaceholder:@"验证码"];
    self.captcha.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:self.captcha];
    
    UIButton* captchaBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, IS_IOS7?224:204, 150, 40)];
    [captchaBtn setBackgroundImage:[UIImage imageNamed:@"loginbtn"] forState:UIControlStateNormal];
    [captchaBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [captchaBtn addTarget:self action:@selector(postCaptchaClicked) forControlEvents:UIControlEventTouchUpInside];
    captchaBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:captchaBtn];
    
    UIButton* rigisterBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?274:254, 300, 40)];
    [rigisterBtn setBackgroundImage:[UIImage imageNamed:@"loginbtn"] forState:UIControlStateNormal];
    [rigisterBtn setTitle:@"找回密码" forState:UIControlStateNormal];
    [rigisterBtn addTarget:self action:@selector(getPasswordClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rigisterBtn];
    
    //处理虚拟键盘
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
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

-(void)postCaptchaClicked
{
    NSString* user = self.phoneNum.text;
    if (user==nil || [user isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"您还没有输入手机号码！"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    sendfindcodeconnection = [self sendSMS:HTTPBASE_URL user:self.phoneNum.text];
}

-(void)getPasswordClicked
{
    NSString* user = self.phoneNum.text;
    NSString* password = self.password.text;
    NSString* rePassword = self.passwordagain.text;
    NSString* captchatext = self.captcha.text;
    
    if (user==nil || [user isEqualToString:@""] || password==nil || [password isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"手机号码或密码为空了！"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (captchatext==nil || [captchatext isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"您还没有输入验证码！"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (password.length<4) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"密码不能少于4个！"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (![password isEqualToString:rePassword]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:@"您输入的确认密码与密码不一致！"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    findpasswordconnection =  [self GetBackePassword:HTTPBASE_URL user:user password:password identifycode:captchatext];
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

//找回密码
-(NSURLConnection*)GetBackePassword:(NSString*)url user:(NSString*) user password:(NSString*)password identifycode:(NSString*)identifycode
{
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request1 setHTTPMethod:@"POST"];
    
    NSString *uuid1 =[[NSUUID UUID] UUIDString];
    [request1 setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request1 setValue:@"forgetPassword" forHTTPHeaderField:@"ACTION"];
    [request1 setValue:@"1.0" forHTTPHeaderField:@"APIVersion"];
    [request1 setValue:uuid1 forHTTPHeaderField:@"UUID"];
    [request1 setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [request1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"userName",[[DataManager sharedManager] md5:password],@"userPassNew",identifycode, @"userCode", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    [request1 setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request1 delegate:self];
    
    return connection;
}

//发送短信
-(NSURLConnection*)sendSMS:(NSString*)url user:(NSString*)user
{
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request1 setHTTPMethod:@"POST"];
    
    NSString *uuid1 =[[NSUUID UUID] UUIDString];
    [request1 setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request1 setValue:@"getValidateCode" forHTTPHeaderField:@"ACTION"];
    [request1 setValue:@"1.0" forHTTPHeaderField:@"APIVersion"];
    [request1 setValue:uuid1 forHTTPHeaderField:@"UUID"];
    [request1 setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [request1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"phoneNum",@"1",@"forgetPassword", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    [request1 setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request1 delegate:self];
    
    return connection;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
}

//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == sendfindcodeconnection) {
        NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        NSLog(@"data:%@",result);
    }
    else if(connection == findpasswordconnection)
    {
        NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        NSLog(@"data:%@",result);
    }
}
//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}
//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    MBProgressHUD *hud= [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = [error localizedDescription];
    hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:2];
    NSLog(@"%@",[error localizedDescription]);
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
