//
//  AboutViewController.m
//  Twatch
//
//  Created by wangjizeng on 13-10-31.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    
    CGPoint starP = CGPointMake(22, IS_IOS7 ? 94 :74);
    UILabel *label1_1 = [ViewUtils labelWithTitle:NSLocalizedString(@"AboutText1_1", nil) textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    CGFloat width = [label1_1.text sizeWithFont:ABOUTSTRING_FONT].width;
    label1_1.frame = CGRectMake(starP.x, starP.y, width, 30);
    [self.view addSubview:label1_1];
    
    UIButton *btn = [ViewUtils buttonWWithTitle:NSLocalizedString(@"AboutBtnText", nil) normalBg:nil hiliteBg:nil target:self selector:@selector(goTohomePage)];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.titleLabel.font = ABOUTSTRING_FONT;
    btn.frame = CGRectMake(label1_1.frame.origin.x + width, starP.y + 1, [NSLocalizedString(@"AboutBtnText", nil) sizeWithFont:ABOUTSTRING_FONT].width, 30);
    [self.view addSubview:btn];
    
    UILabel *label1_2 = [ViewUtils labelWithTitle:NSLocalizedString(@"AboutText1_2", nil) textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    label1_2.frame = CGRectMake(CGRectGetWidth(btn.frame) + btn.frame.origin.x, starP.y, [NSLocalizedString(@"AboutText1_2", nil) sizeWithFont:ABOUTSTRING_FONT].width, 30);
    [self.view addSubview:label1_2];
    
    starP.y += 30;
    
    UILabel *label2 = [ViewUtils labelWithTitle:NSLocalizedString(@"AboutText2", nil) textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    label2.frame = CGRectMake(starP.x, starP.y, 276, 30);
    [self.view addSubview:label2];

    starP.y += 30;
    
    UILabel *label3 = [ViewUtils labelWithTitle:NSLocalizedString(@"AboutText3", nil) textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    label3.frame = CGRectMake(starP.x, starP.y, 276, 30);
    [self.view addSubview:label3];

    starP.y += 30;
    
    UILabel *label4 = [ViewUtils labelWithTitle:NSLocalizedString(@"AboutText4", nil) textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    label4.frame = CGRectMake(starP.x, starP.y, 276, 30);
    [self.view addSubview:label4];
    
    UIImageView *discriminateImage = [[UIImageView alloc] initWithFrame:CGRectMake(( self.view.frame.size.width - 100)/2, 280, 100, 100)];
    discriminateImage.image = [UIImage imageNamed:@"土曼百达科技二维码.jpg"];
    
    discriminateImage.layer.borderWidth = 1;
    discriminateImage.layer.borderColor = RGB(221, 221, 221, 1).CGColor;
    [self.view addSubview:discriminateImage];
    
    UILabel *copyrightLab = [ViewUtils labelWithTitle:NSLocalizedString(@"AboutCopyRight", nil) textFont:[UIFont systemFontOfSize:10.0f] normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    NSLog(@"%f",CGRectGetHeight(self.view.frame));
    copyrightLab.frame = CGRectMake(85, CGRectGetHeight(self.view.frame) - (IS_IOS7? 10:30) , 150, 30);
    copyrightLab.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:copyrightLab];

    
    
}
-(void)goTohomePage
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.tomoon.cn/"]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
