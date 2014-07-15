//
//  SportMessageViewController.m
//  Twatch
//
//  Created by yugong on 14-6-7.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SportMessageViewController.h"

#import "FVImageSequence.h"
#import <ShareSDK/ShareSDK.h>
#import "ShareViewController.h"

#import "BLEServerManager.h"

@interface SportMessageViewController ()
{
    UILabel* allstep;
    UILabel* firstdaystep;
    UILabel* seconddaystep;
    UILabel* threedaystep;
    
    UILabel* firstdate;
    UILabel* seconddate;
    UILabel* threedate;
    
    UILabel* allheat;
    UILabel* firstdayheat;
    UILabel* seconddayheat;
    UILabel* threedayheat;
    
    
}

@end

@implementation SportMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[BLEServerManager sharedManager ] sendSearchWatchCommand];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton* shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(260, IS_IOS7?25:5, 30, 30)];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"sportshare"] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"selectsportshare"] forState:UIControlStateSelected|UIControlStateHighlighted];
    [shareBtn addTarget:self action:@selector(shareClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
    UIImageView* sportImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30,self.view.frame.size.height/2-130 , 260, 260)];
    [sportImageView setImage:[UIImage imageNamed:@"sport"]];
    [self.view addSubview:sportImageView];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd"];
    
    UILabel* all = [[UILabel alloc] initWithFrame:CGRectMake(90, self.view.frame.size.height/2-40, 60, 40)];
    all.backgroundColor = [UIColor clearColor];
    all.font = [UIFont systemFontOfSize:12];
    all.text = @"汇总";
    all.textColor = [UIColor greenColor];
    
    [self.view addSubview:all];
    
    allstep =[[UILabel alloc] initWithFrame:CGRectMake(130, self.view.frame.size.height/2-20, 60, 40)];
    allstep.backgroundColor = [UIColor clearColor];
    allstep.font = [UIFont systemFontOfSize:12];
    allstep.text = @"0步";
    allstep.textColor = [UIColor greenColor];
    [self.view addSubview:allstep];
    
    allheat = [[UILabel alloc] initWithFrame:CGRectMake(130, self.view.frame.size.height/2, 60, 40)];
    allheat.backgroundColor = [UIColor clearColor];
    allheat.text = @"0卡路里";
    allheat.textColor = [UIColor greenColor];
    allheat.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:allheat];
    
    firstdate = [[UILabel alloc] initWithFrame:CGRectMake(100, self.view.frame.size.height/2-150, 60, 40)];
    firstdate.backgroundColor = [UIColor clearColor];
    NSDate* currentDay = [[NSDate alloc] init];
    firstdate.text = [dateFormatter stringFromDate:currentDay];
    firstdate.textColor = [UIColor colorWithHex:@"E55100"];
    firstdate.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:firstdate];
    
    firstdaystep =[[UILabel alloc] initWithFrame:CGRectMake(160, self.view.frame.size.height/2-170, 60, 40)];
    firstdaystep.backgroundColor = [UIColor clearColor];
    firstdaystep.text = @"0步";
    firstdaystep.textColor = [UIColor colorWithHex:@"E55100"];
    firstdaystep.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:firstdaystep];
    
    firstdayheat = [[UILabel alloc] initWithFrame:CGRectMake(160, self.view.frame.size.height/2-130, 60, 40)];
    firstdayheat.backgroundColor = [UIColor clearColor];
    firstdayheat.text = @"0卡路里";
    firstdayheat.textColor = [UIColor colorWithHex:@"E55100"];
    firstdayheat.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:firstdayheat];
    
    seconddate = [[UILabel alloc] initWithFrame:CGRectMake(90, self.view.frame.size.height/2+110, 60, 40)];
    seconddate.backgroundColor = [UIColor clearColor];
    NSDate *yesterday = [[NSDate alloc] initWithTimeIntervalSinceNow:-24*3600];
    seconddate.text = [dateFormatter stringFromDate:yesterday];
    seconddate.textColor = [UIColor colorWithHex:@"FF8400"];
    seconddate.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:seconddate];
    
    seconddaystep =[[UILabel alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height/2+90, 60, 40)];
    seconddaystep.backgroundColor = [UIColor clearColor];
    seconddaystep.text = @"0步";
    seconddaystep.textColor = [UIColor colorWithHex:@"FF8400"];
    seconddaystep.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:seconddaystep];
    
    seconddayheat = [[UILabel alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height/2+130, 60, 40)];
    seconddayheat.backgroundColor = [UIColor clearColor];
    seconddayheat.text = @"0卡路里";
    seconddayheat.textColor = [UIColor colorWithHex:@"FF8400"];
    seconddayheat.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:seconddayheat];
    
    threedate = [[UILabel alloc] initWithFrame:CGRectMake(190, self.view.frame.size.height/2+110, 60, 40)];
    threedate.backgroundColor = [UIColor clearColor];
    NSDate *preday = [[NSDate alloc] initWithTimeIntervalSinceNow:-2*24*3600];
    threedate.text = [dateFormatter stringFromDate:preday];
    threedate.textColor = [UIColor colorWithHex:@"FFC000"];
    threedate.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:threedate];
    
    threedaystep =[[UILabel alloc] initWithFrame:CGRectMake(240, self.view.frame.size.height/2+90, 60, 40)];
    threedaystep.backgroundColor = [UIColor clearColor];
    threedaystep.text = @"0步";
    threedaystep.textColor = [UIColor colorWithHex:@"FFC000"];
    threedaystep.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:threedaystep];
    
    threedayheat = [[UILabel alloc] initWithFrame:CGRectMake(240, self.view.frame.size.height/2+130, 60, 40)];
    threedayheat.backgroundColor = [UIColor clearColor];
    threedayheat.text = @"0卡路里";
    threedayheat.textColor = [UIColor colorWithHex:@"FFC000"];
    threedayheat.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:threedayheat];
}

-(void)shareClicked
{

    //支持retina高分的关键
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(self.view.frame.size);
    }
    
    //获取图像
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    ShareViewController *vc = [[ShareViewController alloc] initWithContent:NSLocalizedString(@"Share Sport Message", nil)
                                                            defaultContent:NSLocalizedString(@"Share Sport Message", nil)
                                                                     image:[ShareSDK jpegImageWithImage:image quality:1.0]
                                                                     title:NSLocalizedString(@"T-FrieShare", nil)
                                                                       url:@"r.tomoon.cn/rotate"
                                                               description:@""
                                                                 mediaType:SSPublishContentMediaTypeNews];
    [self.navigationController pushViewController:vc animated:YES];
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
