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
    UILabel *label1 = [FactoryMethods labelWithTitle:ABOUTSTRING_1 textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    label1.frame = CGRectMake(starP.x, starP.y, 276, 30);
    [self.view addSubview:label1];
    
    starP.y += 30;
    
    UILabel *label2 = [FactoryMethods labelWithTitle:ABOUTSTRING_2 textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    label2.frame = CGRectMake(starP.x, starP.y, 276, 30);
    [self.view addSubview:label2];

    starP.y += 30;
    
    UILabel *label3 = [FactoryMethods labelWithTitle:ABOUTSTRING_3 textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    label3.frame = CGRectMake(starP.x, starP.y, 276, 30);
    [self.view addSubview:label3];

    starP.y += 30;
    
    UILabel *label4 = [FactoryMethods labelWithTitle:ABOUTSTRING_4 textFont:ABOUTSTRING_FONT normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    label4.frame = CGRectMake(starP.x, starP.y, 276, 30);
    [self.view addSubview:label4];
    
    UIImageView *discriminateImage = [[UIImageView alloc] initWithFrame:CGRectMake(( self.view.frame.size.width - 100)/2, 280, 100, 100)];
    discriminateImage.image = [UIImage imageNamed:@"土曼百达科技二维码.jpeg"];
    
    discriminateImage.layer.borderWidth = 1;
    discriminateImage.layer.borderColor = RGB(221, 221, 221, 1).CGColor;
    [self.view addSubview:discriminateImage];
    
    UILabel *copyrightLab = [FactoryMethods labelWithTitle:COPYRIGHT_STRING textFont:[UIFont systemFontOfSize:10.0f] normalColor:ABOUTSTRING_TEXTCOLOR backColor:ABOUTSTRING_BACKCOLOR];
    NSLog(@"%f",CGRectGetHeight(self.view.frame));
    copyrightLab.frame = CGRectMake(100, CGRectGetHeight(self.view.frame) - (IS_IOS7? 10:30) , 125, 30);
    copyrightLab.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:copyrightLab];

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
