//
//  FeedBackViewController.m
//  Twatch
//
//  Created by wangjizeng on 13-10-31.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "FeedBackViewController.h"
#import "UIPlaceHolderTextView.h"

#define TEXTMAX_INPUT 500
#define UMENG_APPKEY  @""
@interface FeedBackViewController ()

@property(nonatomic,strong)UIPlaceHolderTextView *feedBackTextField;
@property(nonatomic,strong)UITextField *contactField;
@property(nonatomic,strong)UMFeedback *myFeedback;
@end

@implementation FeedBackViewController

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
    
    UIPlaceHolderTextView *feedBackTextField = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(20, 80, 280, 160)];
    feedBackTextField.showsVerticalScrollIndicator = YES;
    feedBackTextField.showsHorizontalScrollIndicator = YES;
    [feedBackTextField setPlaceholder:@"亲，求意见^_^"];
    feedBackTextField.font = [UIFont fontWithName:@"Arial" size:12.0];
    [feedBackTextField setBackgroundColor:[UIColor whiteColor]];
    feedBackTextField.layer.borderWidth = 1;
    feedBackTextField.layer.borderColor = RGB(221, 221, 221, 1).CGColor;
    feedBackTextField.delegate = self;
    feedBackTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:feedBackTextField];
    
    self.feedBackTextField = feedBackTextField;
   
#warning 缺少二维码
    
    UITextField *contactTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(feedBackTextField.frame)-1, 280, 35)];
    [contactTextField setPlaceholder:@"联系方式"];
    contactTextField.font = [UIFont fontWithName:@"Arial" size:12.0];
    [contactTextField setBackgroundColor:[UIColor whiteColor]];
    contactTextField.layer.borderWidth = 1;
    contactTextField.layer.borderColor = RGB(221, 221, 221, 1).CGColor;
    contactTextField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:contactTextField];
    self.contactField = contactTextField;
        
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame =CGRectMake(240, CGRectGetMaxY(contactTextField.frame)+5, 60, 30);
    [sendBtn setTitleColor:RGB(165, 165, 165, 1) forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [sendBtn addTarget:self action:@selector(sendFeedBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    
    [UMFeedback setLogEnabled:YES];
    [UMFeedback checkWithAppkey:UMENG_APPKEY];
    [UMFeedback sharedInstance].delegate = self;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    //调整UI位置
    NSTimeInterval animationDuration = 0.25f;
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:animationDuration];
    if ([[UIScreen mainScreen] bounds].size.height < 568)
    {
        self.view.frame = CGRectMake(0, -45, 320, self.view.frame.size.height);
    }

    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSTimeInterval animationDuration = 0.25f;
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    [UIView commitAnimations];
}

//-(BOOL) textView :(UITextView *) textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *) text {
//    
//    if ([text isEqualToString:@"\n"])
//    {
//        [textView resignFirstResponder];
//    }
//    if(textView == self.feedBackTextField)
//    {
//        if(range.location >= TEXTMAX_INPUT)
//        {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"反馈内容超过上限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//            return NO;
//        }
//        else
//        {
//            
//        }
//    }
//    return YES;
//}

-(void)sendFeedBack
{
    if ([self.feedBackTextField.text length] == 0)
    {
        [self.feedBackTextField Shake];
        return;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.feedBackTextField.text forKey:@"content"];
    
    NSDictionary *contact = [NSDictionary dictionaryWithObject:self.contactField.text forKey:@"contact info"];
    [dictionary setObject:contact forKey:@"contact"];

    [[UMFeedback sharedInstance] post:dictionary];
}

- (void)getFinishedWithError: (NSError *)error
{
    ;
}
- (void)postFinishedWithError:(NSError *)error
{
    if (error == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"反馈成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"反馈失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];

    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
