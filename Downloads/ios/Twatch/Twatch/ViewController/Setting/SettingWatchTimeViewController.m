//
//  SettingWatchTimeViewController.m
//  Twatch
//
//  Created by yugong on 14-5-28.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SettingWatchTimeViewController.h"
#import "SettingTimeZoneViewController.h"
#import "BLEServerManager.h"
#import "BlockUIAlertView.h"

#import "UIViewController+KNSemiModal.h"
#import "SettingTimeFormatViewController.h"

#define SWITCH_TIME24_TAG 1010
#define SWITCH_AUTOTIMEZONE_TAG 1011

@interface SettingWatchTimeViewController ()
{
    NSString* autotime;
    NSDate* date;
    NSString* timeZome;
    NSString* isTwentyfour;
    SettingTimeFormatViewController* timeFormatController;
    SettingTimeZoneViewController* timeZoneController;
}

@property (nonatomic ,strong)NSArray* datesetList;

@end
@implementation SettingWatchTimeViewController

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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset
                                                                           , CGRectGetWidth(self.view.frame), self.height-50) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50;
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    self.datesetList = [NSArray arrayWithObjects:@"设置时间",
                                   @"设置日期",
                                   @"使用24小时制",
                                   @"设置日期格式",
                                   nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTimeFormat:) name:@"settimeformat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTimeZone:) name:@"settimezone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCancel) name:@"setcancel" object:nil];
    
    timeFormatController = [[SettingTimeFormatViewController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if(section == 1)
    {
        return [self.datesetList count];
    }
    else if (section == 2)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil) {
    }
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor colorWithHex:@"333333"];
    int section = indexPath.section;
    int row = indexPath.row;
    switch (section) {
        case 0:
        {
            cell.textLabel.text = @"自动同步时间和日期\n使用网络提供的时间和日期";
            break;
        }
        case 1:
        {
            if (row == 2) {
                UISwitch* autoTime24 = [[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 51, 31)];
                autoTime24.tag = SWITCH_TIME24_TAG;
                [autoTime24 addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:autoTime24];
            }
            cell.textLabel.text = [self.datesetList objectAtIndex:row];
            break;
        }
        case 2:
        {
            if (row == 0) {
                UISwitch* autoTimeZone = [[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 51, 31)];
                autoTimeZone.tag = SWITCH_AUTOTIMEZONE_TAG;
                [autoTimeZone addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:autoTimeZone];
                cell.textLabel.text = @"自动时区\n使用网络提供的时区信息";
            }
            else if(row == 1)
            {
                cell.textLabel.text = @"选择时区";
            }
            else
            {
            }
            
            break;
        }
        default:
            break;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.rowHeight - .5, CGRectGetWidth(tableView.frame) , .5)];
    line.backgroundColor = [UIColor colorWithHex:@"cfe1f5"];
    [cell addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int section = indexPath.section;
    int row = indexPath.row;
    switch (section) {
        case 0:
        {
            if (![[BLEServerManager sharedManager] isBLEPoweredOn]) {
                return;
            }
            if (![[BLEServerManager sharedManager] isBLEConnected]) {
                return;
            }
            NSDate *timedate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm"];
            NSString *strDate = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Confirm Time Proofread", nil),[dateFormatter stringFromDate:timedate]];
            
            BlockUIAlertView *alertView = [[BlockUIAlertView alloc] initWithTitle:@"" message:strDate cancelButtonTitle:NSLocalizedString(@"OK", nil)  otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"No", nil), nil] buttonBlock:^(NSInteger indexButton){
                NSLog(@"%d",indexButton);
                if (indexButton == 0) {
                    [[BLEServerManager sharedManager] sendTimeCommand:date finish:^(void){
                        [ViewUtils showToast:@"时间校对成功"];
                    }];
                }
            }];
            [alertView show];
            break;
        }
        case 1:
        {
            if (row == 0)
            {
                UIView* timeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
                timeView.backgroundColor = [UIColor grayColor];
                
                UIDatePicker* timePicker = [[UIDatePicker alloc] init];
                timePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                timePicker.frame = CGRectMake(0, 0, 320, 170);
                timePicker.datePickerMode = UIDatePickerModeTime;
                NSDateFormatter *offdateFormatter = [[NSDateFormatter alloc] init];
                [offdateFormatter setDateFormat: @"HH:mm"];
                NSDate *time= [offdateFormatter dateFromString:@"08:00"];
                [timePicker setDate:time];
                //[timePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
                timePicker.backgroundColor = [UIColor grayColor];
                [timeView addSubview:timePicker];
                
                UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, timePicker.frame.size.height+5, 140, 30)];
                [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelsetbtn"] forState:UIControlStateNormal];
                [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                [cancelBtn setBackgroundColor:[UIColor redColor]];
                [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
                [timeView addSubview:cancelBtn];
                
                UIButton* setTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(170, timePicker.frame.size.height+5, 140, 30)];
                [setTimeBtn setBackgroundImage:[UIImage imageNamed:@"setbtn"] forState:UIControlStateNormal];
                [setTimeBtn setBackgroundColor:[UIColor redColor]];
                [setTimeBtn setTitle:@"设置" forState:UIControlStateNormal];
                [setTimeBtn addTarget:self action:@selector(setTimeClicked) forControlEvents:UIControlEventTouchUpInside];
                [timeView addSubview:setTimeBtn];
                
                [self presentSemiView:timeView];
            }
            else if (row == 1)
            {
                UIView* dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
                dateView.backgroundColor = [UIColor grayColor];
                
                UIDatePicker* datePicker = [[UIDatePicker alloc] init];
                datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                datePicker.frame = CGRectMake(10, 0, 320, 100);
                datePicker.datePickerMode = UIDatePickerModeDate;
                NSDateFormatter *offdateFormatter = [[NSDateFormatter alloc] init];
                [offdateFormatter setDateFormat: @"yyyy-MM-dd"];
                NSDate *currentdate= [offdateFormatter dateFromString:@"2014-06-04"];
                [datePicker setDate:currentdate];
                //[datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
                datePicker.backgroundColor = [UIColor grayColor];
                [dateView addSubview:datePicker];
                
                UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, datePicker.frame.size.height+5, 140, 30)];
                [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelsetbtn"] forState:UIControlStateNormal];
                [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                [cancelBtn setBackgroundColor:[UIColor redColor]];
                [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
                [dateView addSubview:cancelBtn];
                
                UIButton* setDateBtn = [[UIButton alloc] initWithFrame:CGRectMake(170, datePicker.frame.size.height+5, 140, 30)];
                [setDateBtn setBackgroundImage:[UIImage imageNamed:@"setbtn"] forState:UIControlStateNormal];
                [setDateBtn setBackgroundColor:[UIColor redColor]];
                [setDateBtn setTitle:@"设置" forState:UIControlStateNormal];
                [setDateBtn addTarget:self action:@selector(setDateClicked) forControlEvents:UIControlEventTouchUpInside];
                [dateView addSubview:setDateBtn];
                
                [self presentSemiView:dateView];
            }
            else if (row == 2)
            {
            }
            else
            {
                [self presentSemiViewController:timeFormatController];
            }
            break;
        }
        case 2:
        {
            if (row == 1)
            {
                timeZoneController = [[SettingTimeZoneViewController alloc] init];
                timeZoneController.backName = @"时区设置";
                [self.navigationController pushViewController:timeZoneController animated:YES];
                //[self presentViewController:setWatchTimeController animated:YES completion:nil];
            }
            else if(row == 0)
            {
            }
            break;
        }
        default:
            break;
    }

}

-(void)switchClick: (id)sender
{
    UISwitch* switchview = (UISwitch*)sender;
    BOOL bswitch = [switchview isOn];
    NSString* strSwitch;
    if (bswitch) {
        strSwitch = @"true";
    }
    else
    {
        strSwitch = @"false";
    }
    UISwitch *switchBtn = (UISwitch *)sender;
    if (switchBtn.tag == SWITCH_TIME24_TAG)
    {
        isTwentyfour = strSwitch;
        [self setSwitchTime];
    }
    else if (switchBtn.tag == SWITCH_AUTOTIMEZONE_TAG)
    {
    }
    else
    {
    }
}

-(void)cancelClicked
{
    [self dismissSemiModalView];
}

-(void)setTimeClicked
{
    [self setSwitchTime];
    [self dismissSemiModalView];
}

-(void)setDateClicked
{
    [self setSwitchTime];
    [self dismissSemiModalView];
}

-(void)setCancel
{
    [self dismissSemiModalView];
}

-(void)setSwitchTime
{
    if (![[BLEServerManager sharedManager] isBLEPoweredOn]) {
        return;
    }
    if (![[BLEServerManager sharedManager] isBLEConnected]) {
        return;
    }
    
    [[BLEServerManager sharedManager] sendWatchTime:autotime date:date timeZome:timeZome istwentyfour:isTwentyfour dateformat:self.dateFormat finish:^(void){
    }];
}

-(void)setTimeFormat:(NSNotification *)notification
{
    self.dateFormat = notification.object;
    [self setSwitchTime];
    [self dismissSemiModalView];
}

-(void)setTimeZone:(NSNotification *)notification
{
    timeZome = notification.object;
    [self setSwitchTime];
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
