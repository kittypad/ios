//
//  SettingTimerPowerViewController.m
//  Twatch
//
//  Created by yugong on 14-5-28.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SettingTimerPowerViewController.h"

#define SWITCH_ISAUTOPOWER_TAG 1007
#define SWITCH_POWERON_TAG 1008
#define SWITCH_POWEROFF_TAG 1009

@interface SettingTimerPowerViewController ()

//@property (nonatomic,strong)UIDatePicker* powerOnPicker;
//
//@property (nonatomic,strong)UIDatePicker* powerOffPicker;

@end

@implementation SettingTimerPowerViewController

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
    
    UILabel* openpPowerlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, IS_IOS7?65:45, 250, 30)];
    openpPowerlabel.backgroundColor = [UIColor clearColor];
    [openpPowerlabel setText:@"开启自动开关机"];
    [self.view addSubview:openpPowerlabel];
    UISwitch *openpPowerSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, IS_IOS7?65:45, 50, 30)];
    openpPowerSwitch.tag = SWITCH_ISAUTOPOWER_TAG;
    [openpPowerSwitch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openpPowerSwitch];
    
    //开机时间
    UILabel* PowerOnlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, IS_IOS7?100:80, 300, 30)];
    PowerOnlabel.backgroundColor = [UIColor clearColor];
    [PowerOnlabel setText:@"开机时间"];
    [self.view addSubview:PowerOnlabel];
    UISwitch *poweronswitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, IS_IOS7?100:80, 50, 30)];
    poweronswitch.tag = SWITCH_POWERON_TAG;
    [poweronswitch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:poweronswitch];
    UIDatePicker* powerOnPicker = [[UIDatePicker alloc] init];
    powerOnPicker.backgroundColor = [UIColor greenColor];
    powerOnPicker.datePickerMode = UIDatePickerModeTime;
    powerOnPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [powerOnPicker setFrame:CGRectMake(10, IS_IOS7?135:115, 300, 80)];
    [self.view addSubview:powerOnPicker];
    
    //关机时间
    UILabel* OpenPowerSwitch = [[UILabel alloc] initWithFrame:CGRectMake(10, IS_IOS7?290:270, 300, 30)];
    OpenPowerSwitch.backgroundColor = [UIColor clearColor];
    [OpenPowerSwitch setText:@"关机时间"];
    [self.view addSubview:OpenPowerSwitch];
    UISwitch *poweroffswitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, IS_IOS7?290:270, 50, 30)];
    poweroffswitch.tag = SWITCH_POWEROFF_TAG;
    [poweroffswitch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:poweroffswitch];
    
    UIDatePicker* powerOffPicker = [[UIDatePicker alloc] init];
     powerOnPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        powerOffPicker.frame = CGRectMake(10, IS_IOS7?325:305, 300, 20);
    powerOffPicker.datePickerMode = UIDatePickerModeTime;
    powerOffPicker.backgroundColor = [UIColor redColor];
    [self.view addSubview:powerOffPicker];
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?490:470, 140, 30)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor grayColor]];
    [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    UIButton* settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, IS_IOS7?490:470, 140, 30)];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setBackgroundColor:[UIColor grayColor]];
    [settingBtn addTarget:self action:@selector(settingClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    
}

-(void)switchClick: (id)sender
{
    UISwitch *switchBtn = (UISwitch *)sender;
    if (switchBtn.tag == SWITCH_ISAUTOPOWER_TAG)
    {
    }
    else if (switchBtn.tag == SWITCH_POWERON_TAG)
    {
    }
    else if (switchBtn.tag == SWITCH_POWEROFF_TAG)
    {
    }
}

- (void)backClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancelClicked
{
}

-(void)settingClicked
{
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
