//
//  SettingTimerPowerViewController.m
//  Twatch
//
//  Created by yugong on 14-5-28.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SettingTimerPowerViewController.h"
#import "BlEServerManager.h"

#define DATEPICKER_POWERON_TAG 2001
#define DATEPICKER_POWEROFF_TAG 2002


@interface SettingTimerPowerViewController ()

@property (nonatomic,strong)UILabel* powerontext;

@property (nonatomic,strong)UILabel* powerofftext;

@property (nonatomic)BOOL autoPower;

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
    
    UILabel* openpPowerlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, IS_IOS7?65:45, 250, 30)];
    openpPowerlabel.backgroundColor = [UIColor clearColor];
    [openpPowerlabel setText:@"开启自动开关机"];
    [self.view addSubview:openpPowerlabel];
    UISwitch *openpPowerSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, IS_IOS7?65:45, 50, 30)];
    [openpPowerSwitch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openpPowerSwitch];
    
    //开机时间
    UILabel* PowerOnlabel = [[UILabel alloc] initWithFrame:CGRectMake(10, IS_IOS7?100:80, 300, 30)];
    PowerOnlabel.backgroundColor = [UIColor clearColor];
    [PowerOnlabel setText:@"开机时间"];
    [self.view addSubview:PowerOnlabel];
    UILabel *poweronText = [[UILabel alloc] initWithFrame:CGRectMake(250, IS_IOS7?105:85, 50, 30)];
    poweronText.text = @"7:00";
    poweronText.textColor = [UIColor blueColor];
    poweronText.font = [UIFont fontWithName:@"Helvetica" size:12];
    poweronText.backgroundColor = [UIColor clearColor];
    self.powerontext = poweronText;
    [self.view addSubview:self.powerontext];
    UIDatePicker* powerOnPicker = [[UIDatePicker alloc] init];
    //powerOnPicker.backgroundColor = [UIColor greenColor];
    powerOnPicker.datePickerMode = UIDatePickerModeTime;
    powerOnPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [powerOnPicker setFrame:CGRectMake(10, IS_IOS7?135:115, 300, 80)];
    [powerOnPicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    powerOnPicker.tag = DATEPICKER_POWERON_TAG;
    NSDateFormatter *ondateFormatter = [[NSDateFormatter alloc] init];
    [ondateFormatter setDateFormat: @"HH:mm"];
    NSDate *onDate= [ondateFormatter dateFromString:poweronText.text];
    powerOnPicker.date = onDate;
    [self.view addSubview:powerOnPicker];
    
    //关机时间
    UILabel* OpenPowerLabel= [[UILabel alloc] initWithFrame:CGRectMake(10, IS_IOS7?295:275, 300, 30)];
    OpenPowerLabel.backgroundColor = [UIColor clearColor];
    [OpenPowerLabel setText:@"关机时间"];
    [self.view addSubview:OpenPowerLabel];
    UILabel* powerofftext = [[UILabel alloc] initWithFrame:CGRectMake(250, IS_IOS7?295:275, 50, 30)];
    powerofftext.text = @"22:00";
    powerofftext.textColor = [UIColor blueColor];
    powerofftext.font = [UIFont fontWithName:@"Helvetica" size:12];
    powerofftext.backgroundColor = [UIColor clearColor];
    self.powerofftext = powerofftext;
    [self.view addSubview:self.powerofftext];
    
    UIDatePicker* powerOffPicker = [[UIDatePicker alloc] init];
     powerOnPicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        powerOffPicker.frame = CGRectMake(10, IS_IOS7?325:305, 300, 20);
    powerOffPicker.datePickerMode = UIDatePickerModeTime;
    powerOffPicker.tag =  DATEPICKER_POWEROFF_TAG;
    NSDateFormatter *offdateFormatter = [[NSDateFormatter alloc] init];
    [offdateFormatter setDateFormat: @"HH:mm"];
    NSDate *offDate= [offdateFormatter dateFromString:powerofftext.text];
    [powerOffPicker setDate:offDate];
    [powerOffPicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    //powerOffPicker.backgroundColor = [UIColor redColor];
    [self.view addSubview:powerOffPicker];
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, IS_IOS7?490:470, 140, 30)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor grayColor]];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelsetbtn"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    UIButton* settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, IS_IOS7?490:470, 140, 30)];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setBackgroundColor:[UIColor grayColor]];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"setbtn"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    
}

-(void)dateChanged:(id)sender
{
    UIDatePicker* powerPicker = (UIDatePicker*)sender;
    NSDate* powerondate = powerPicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm"]; 
    NSString *destDateString = [dateFormatter stringFromDate:powerondate];
    if (powerPicker.tag == DATEPICKER_POWERON_TAG)
    {
        [self.powerontext setText: destDateString];
    }
    else if (powerPicker.tag == DATEPICKER_POWEROFF_TAG)
    {
        [self.powerofftext setText: destDateString];
    }
    
}

-(void)switchClick: (id)sender
{
    UISwitch* switchview = (UISwitch*)sender;
    self.autoPower = [switchview isOn];
}

-(void)cancelClicked
{
    [self goBack];
}

-(void)settingClicked
{
    if (![[BLEServerManager sharedManager] isBLEPoweredOn]) {
        return;
    }
    if (![[BLEServerManager sharedManager] isBLEConnected]) {
        return;
    }
    
    NSString* enabled;
    if (self.autoPower) {
        enabled = @"true";
    }
    else
    {
        enabled = @"false";
    }
    
    //发送自动开机设置
    NSArray* powerOntime = [self.powerontext.text componentsSeparatedByString:@":"];
    NSString* powerOnHour = [powerOntime objectAtIndex:0];
    NSString* powerOnMinute = [powerOntime objectAtIndex:1];
    [[BLEServerManager sharedManager] sendPowerOnWatch:powerOnHour minute:powerOnMinute enabled:enabled finish:^(void){
        NSLog(@"自动开机时间设置成功");
    }];
    
    //发送自动关机设置
    NSArray* powerOfftime = [self.powerofftext.text componentsSeparatedByString:@":"];
    NSString* powerOffHour = [powerOfftime objectAtIndex:0];
    NSString* powerOffMinute = [powerOfftime objectAtIndex:1];
    [[BLEServerManager sharedManager] sendPowerOffWatch:powerOffHour minute:powerOffMinute enabled:enabled finish:^(void){
        NSLog(@"自动关机时间设置成功");
    }];
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
