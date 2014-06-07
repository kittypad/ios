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

@interface SettingWatchTimeViewController ()
{
    NSString* autotime;
    NSDate* date;
    NSString* timeZome;
    NSString* isTwentyfour;
    NSString* dateformat;
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
            cell.textLabel.text = [self.datesetList objectAtIndex:row];
            break;
        }
        case 2:
        {
            if (row == 0) {
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
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm"];
            NSString *strDate = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Confirm Time Proofread", nil),[dateFormatter stringFromDate:date]];
            
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
                UIDatePicker* timePicker = [[UIDatePicker alloc] init];
                timePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                //timePicker.frame = CGRectMake(10, 0, 300, 100);
                timePicker.datePickerMode = UIDatePickerModeTime;
                NSDateFormatter *offdateFormatter = [[NSDateFormatter alloc] init];
                [offdateFormatter setDateFormat: @"HH:mm"];
                NSDate *time= [offdateFormatter dateFromString:@"08:00"];
                [timePicker setDate:time];
                //[timePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
                timePicker.backgroundColor = [UIColor grayColor];
                
                UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, timePicker.frame.size.height-40, 140, 30)];
                [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelsetbtn"] forState:UIControlStateNormal];
                [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                [cancelBtn setBackgroundColor:[UIColor redColor]];
                [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
                [timePicker addSubview:cancelBtn];
                
                UIButton* setTimeBtn = [[UIButton alloc] initWithFrame:CGRectMake(170, timePicker.frame.size.height-40, 140, 30)];
                [setTimeBtn setBackgroundImage:[UIImage imageNamed:@"setbtn"] forState:UIControlStateNormal];
                [setTimeBtn setBackgroundColor:[UIColor redColor]];
                [setTimeBtn setTitle:@"设置" forState:UIControlStateNormal];
                [setTimeBtn addTarget:self action:@selector(setTimeClicked) forControlEvents:UIControlEventTouchUpInside];
                [timePicker addSubview:setTimeBtn];
                
                [self presentSemiView:timePicker];
            }
            else if (row == 1)
            {
                UIDatePicker* datePicker = [[UIDatePicker alloc] init];
                datePicker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                //datePicker.frame = CGRectMake(10, 0, 300, 100);
                datePicker.datePickerMode = UIDatePickerModeDate;
                NSDateFormatter *offdateFormatter = [[NSDateFormatter alloc] init];
                [offdateFormatter setDateFormat: @"yyyy-MM-dd"];
                NSDate *date= [offdateFormatter dateFromString:@"2014-06-04"];
                [datePicker setDate:date];
                //[datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
                datePicker.backgroundColor = [UIColor grayColor];
                
                UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, datePicker.frame.size.height-40, 140, 30)];
                [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelsetbtn"] forState:UIControlStateNormal];
                [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                [cancelBtn setBackgroundColor:[UIColor redColor]];
                [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
                [datePicker addSubview:cancelBtn];
                
                UIButton* setDateBtn = [[UIButton alloc] initWithFrame:CGRectMake(170, datePicker.frame.size.height-40, 140, 30)];
                [setDateBtn setBackgroundImage:[UIImage imageNamed:@"setbtn"] forState:UIControlStateNormal];
                [setDateBtn setBackgroundColor:[UIColor redColor]];
                [setDateBtn setTitle:@"设置" forState:UIControlStateNormal];
                [setDateBtn addTarget:self action:@selector(setDateClicked) forControlEvents:UIControlEventTouchUpInside];
                [datePicker addSubview:setDateBtn];
                
                [self presentSemiView:datePicker];
            }
            else if (row == 2)
            {
            }
            else
            {
            }
            break;
        }
        case 2:
        {
            if (row == 1)
            {
                SettingTimeZoneViewController* setWatchTimeController = [[SettingTimeZoneViewController alloc] init];
                setWatchTimeController.backName = @"选择时区";
                [self.navigationController pushViewController:setWatchTimeController animated:YES];
                //[self presentViewController:setWatchTimeController animated:YES completion:nil];
            }
            break;
        }
        default:
            break;
    }

}

-(void)cancelClicked
{
    [self dismissSemiModalView];
}

-(void)setTimeClicked
{
    [[BLEServerManager sharedManager] sendWatchTime:autotime date:date timeZome:timeZome istwentyfour:isTwentyfour dateformat:dateformat finish:^(void){
    }];
    [self dismissSemiModalView];
}

-(void)setDateClicked
{
    [[BLEServerManager sharedManager] sendWatchTime:autotime date:date timeZome:timeZome istwentyfour:isTwentyfour dateformat:dateformat finish:^(void){
    }];
    [self dismissSemiModalView];
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
