//
//  SettingsViewController.m
//  Twatch
//
//  Created by yugong on 14-5-27.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingCell.h"
#import "AppCenterViewController.h"
#import "MBProgressHUD.h"
//#import "BLEManager.h"
#import "UpdateWatchControllerViewController.h"
#import "ViewUtils.h"
#import "BLEServerManager.h"

#import "ConnectionViewController.h"
#import "MoreSettingViewController.h"
#import "SettingTimerPowerViewController.h"

#define SWITCH_TIMEADJUST_TAG  1001
#define SWITCH_DISCOVERYWATCH_TAG  1002
#define SWITCH_PUSHSETTING_TAG  1003
#define SWITCH_CONNECTTESTING_TAG  1004

#define SWITCH_VIBRATE_TAG 1005
#define SWITCH_INVERSE_TAG 1006

@implementation MoreSettingsCell

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setFrame:CGRectMake(20, 15,20, 20)];
    
    [self.textLabel setFrame:CGRectMake(50, 10, 200, 30)];
}

@end

@interface SettingsViewController ()
@property(nonatomic,strong)NSArray *subviewControllerArray;
@property(nonatomic,strong)NSArray *titleArray;

@property(nonatomic,strong)NSMutableArray* settingList;

@property(nonatomic,strong)id         anObserver;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //glc 2014-5-22 添加tabbar
        UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Settings", @"设置") image:[UIImage imageNamed:@"tabsetting"] tag:3];
        self.tabBarItem = item;
        self.backName = NSLocalizedString(@"Settings", @"设置");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.titleArray = [NSArray arrayWithObjects: NSLocalizedString(@"Watch Version", nil),
                       NSLocalizedString(@"Account Bound", nil),
                       NSLocalizedString(@"Settings", nil), nil];
    self.subviewControllerArray = [NSArray arrayWithObjects:@"UpdateWatchController",
                                   @"AGAuthViewController",
                                   @"MoreSettingViewController",
                                   nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset
                                                                           , CGRectGetWidth(self.view.frame), self.height-50) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50;
    //tableView.scrollEnabled = NO;
    //tableView.tableHeaderView = [self tableHeaderView];
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    self.settingList = [NSMutableArray arrayWithObjects:NSLocalizedString(@"Bound Watch", @"绑定手表"),NSLocalizedString(@"Call Watch", @"呼叫手表"), NSLocalizedString(@"Open Shock", @"开启震动"), NSLocalizedString(@"Sleep Time", @"休眠时间"), NSLocalizedString(@"InVerse Color", @"黑白反色"),
                                   NSLocalizedString(@"Lock Screen", @"锁屏设置"), NSLocalizedString(@"Date Time", @"时间日期"),NSLocalizedString(@"Timer Switch", @"定时开关"),NSLocalizedString(@"Update Watch", @"固件升级"),NSLocalizedString(@"One Set", @"一键优化设置"),NSLocalizedString(@"more settings", @"更多设置"),nil];
    
}

- (UIView *)tableHeaderView
{
    UIControl *headerView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    [headerView addTarget:self action:@selector(boundButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectOffset(headerView.frame, 20, 0)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    [headerView addSubview:titleLabel];
    
    UIImageView *statusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"单选"]];
    statusImageView.center = CGPointMake(CGRectGetWidth(headerView.frame) - CGRectGetWidth(statusImageView.frame) - 5, CGRectGetHeight(headerView.frame)/2);
    [headerView addSubview:statusImageView];
    
    self.anObserver =[[NSNotificationCenter defaultCenter] addObserverForName:kBLEChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([[BLEServerManager sharedManager] isBLEConnectedWithoutAlert]) {
            titleLabel.text = NSLocalizedString(@"Unbound Watch", @"绑定手表");
            statusImageView.image = [UIImage imageNamed:@"单选-选中"];
        }else{
            titleLabel.text = NSLocalizedString(@"Bound Watch", @"绑定手表");
            statusImageView.image = [UIImage imageNamed:@"单选"];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEChangedNotification object:nil];
    
    return headerView;
}

- (void)boundButtonClicked:(id)sender
{
    if([[BLEServerManager sharedManager] isBLEConnected])
    {
        [[BLEServerManager sharedManager] sendUnboundCommand];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"未连接手表"
                                                       delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.anObserver];
    self.anObserver = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1)
    {
        return 4;
    }
    else if (section == 2)
    {
        return 3;
    }
    else if (section == 3)
    {
        return 1;
    }
    else if (section == 4)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SettingCell";
    MoreSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil) {
    }
    if (!cell)
    {
        cell = [[MoreSettingsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor colorWithHex:@"333333"];
    int section = indexPath.section;
    int row = indexPath.row;
    switch (section) {
        case 0:
        {
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (row==1) {
                [cell setEditing:NO];
            }
            break;
        }
        case 1:
        {
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+2];
            if (row == 0) {
                UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 50.5, 10)];
                switchBtn.tag = SWITCH_VIBRATE_TAG;
                [switchBtn addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:switchBtn];
            }
            else if(row == 2)
            {
                UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 50.5, 10)];
                switchBtn.tag = SWITCH_INVERSE_TAG;
                [switchBtn addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:switchBtn];
            }
            break;
        }
        case 2:
        {
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+6];
            if (row == 0) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        }
        case 3:
        {
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+9];
             break;
        }
        case 4:
        {
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+10];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
            if (row == 0) {
                ConnectionViewController *aController = [[ConnectionViewController alloc] init];
                aController.backName = NSLocalizedString(@"SynConnection", nil);
                //[self.navigationController pushViewController:aController animated:YES];
                [self presentViewController:aController animated:YES completion:nil];
            }
            else
            {
                
            }

            break;
        }
        case 1:
        {
            if (row == 0) {

            }
            
            break;
        }
        case 2:
        {
            if (row == 0)
            {
            }
            else if(row == 1)
            {
                SettingTimerPowerViewController* powerController = [[SettingTimerPowerViewController alloc] init];
                [self presentViewController:powerController animated:YES completion:nil];
            }
            break;
        }
        case 3:
        {
            break;
        }
        case 4:
        {
//            NSString *className =（NSString*)self.subviewControllerArray[2];
//            UIViewController *aController = [[NSClassFromString(className) alloc] initWithNibName:nil bundle:nil];
//            
//            ((NaviCommonViewController*)aController).backName = self.titleArray[indexPath.row - 2];
//            [self.navigationController pushViewController:aController animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - ToggleViewDelegate

- (void)selectLeftButton :(id)sender
{
    UIView *view = (UIView *)sender;
    if (view.tag == SWITCH_TIMEADJUST_TAG)
    {
    }
    else if(view.tag == SWITCH_DISCOVERYWATCH_TAG)
    {
    }
    else if (view.tag == SWITCH_CONNECTTESTING_TAG)
    {
    }
    NSLog(@"LeftButton Selected");
}

-(void)switchClick: (id)sender
{
    UISwitch *switchBtn = (UISwitch *)sender;
    if (switchBtn.tag == SWITCH_INVERSE_TAG) {
        if([[BLEServerManager sharedManager] isBLEConnected])
        {
            [[BLEServerManager sharedManager] sendInverseColor:@"true" finish:^(void){
                [ViewUtils showToast:@"设置反转成功"];
            }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"未连接手表"
                                                           delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
    else if (switchBtn.tag == SWITCH_VIBRATE_TAG)
    {
        if([[BLEServerManager sharedManager] isBLEConnected])
        {
            [[BLEServerManager sharedManager] sendVibrateSetting:@"true" finish:^(void){
                [ViewUtils showToast:@"设置反转成功"];
            }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"未连接手表"
                                                           delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
}

@end
