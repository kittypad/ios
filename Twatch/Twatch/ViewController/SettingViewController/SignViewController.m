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
    signtextfield.returnKeyType = UIReturnKeyDone;
    signtextfield.textAlignment = NSTextAlignmentCenter;
    UIColor *color = [UIColor getColor:@"ffffff"];
    signtextfield.layer.borderColor = color.CGColor;

    [bgView addSubview:signtextfield];
    self.signtextfield = signtextfield;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}


-(void)keyboardWillShow:(NSNotification*)notification{
    //调整UI位置
    NSTimeInterval animationDuration = 0.25f;
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = CGRectMake(0, -90, 320, self.view.frame.size.height);
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

-(NSString *) getstring:(NSString *)string length:(int)length
{
    int n = string.length;
    NSString *backStr = @"";
    int nTemp = 0;
    for (int i =0; i<n; i++)
    {
        NSString *str = [string substringWithRange:NSMakeRange(i,1)];
        char* p = (char*)[str cStringUsingEncoding:NSUnicodeStringEncoding];
        p++;
        if (*p) {
            nTemp +=2;
        }
        else
        {
            nTemp +=1;
        }
        if (nTemp > 10)
        {
            return  backStr;
        }
        else
        {
            backStr = [NSString stringWithFormat:@"%@%@",backStr,str];
        }
    }
    
    return backStr;

}
- (int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.signtextfield.text = [self getstring:textField.text length:5];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}
-(void)share :(id)sender
{
    ;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
