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

#import "UpdateWatchControllerViewController.h"
#import "ViewUtils.h"
#import "BLEServerManager.h"

#import "ConnectionViewController.h"
#import "MoreSettingViewController.h"
#import "SettingTimerPowerViewController.h"

#import "SettingWatchTimeViewController.h"
#import "SettingMoreViewController.h"
#import "TMNavigationController.h"

#import "UIViewController+KNSemiModal.h"


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
{
    UILabel* sleepLabel;    //休眠时间
    UILabel* powerTimeLabel;    //定时开关机
    BOOL bBound;
    NSString* PowerOntext;
    NSString* PowerOfftext;
    
    UITableView* tableView;
    
    SettingTimerPowerViewController* powerController;
}
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
    
    self.titleArray = [NSArray arrayWithObjects: NSLocalizedString(@"Date Time", @"时间日期"),
                       NSLocalizedString(@"Timer Switch", @"定时开关"),
                       NSLocalizedString(@"Update Watch", @"固件升级"), nil];
    self.subviewControllerArray = [NSArray arrayWithObjects:@"SettingWatchTimeViewController",
                                   @"SettingTimerPowerViewController",
                                   @"UpdateWatchController",nil];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset
                                                                           , CGRectGetWidth(self.view.frame), self.height-50) style:UITableViewStyleGrouped];
        
                                   
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50;
    [tableView setEditing:NO];
    //tableView.scrollEnabled = NO;
    //tableView.tableHeaderView = [self tableHeaderView];
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    self.settingList = [NSMutableArray arrayWithObjects:NSLocalizedString(@"Bound Watch", @"绑定手表"),NSLocalizedString(@"Call Watch", @"呼叫手表"), NSLocalizedString(@"Open Shock", @"开启震动"), NSLocalizedString(@"Sleep Time", @"休眠时间"), NSLocalizedString(@"InVerse Color", @"黑白反色"),
                                   /*NSLocalizedString(@"Lock Screen", @"锁屏设置"),*/ NSLocalizedString(@"Date Time", @"时间日期"),NSLocalizedString(@"Timer Switch", @"定时开关"),NSLocalizedString(@"Update Watch", @"固件升级"),NSLocalizedString(@"One Set", @"一键优化设置"),NSLocalizedString(@"more settings", @"更多设置"),nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSleepTime:) name:@"setsleeptime" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCancel) name:@"setcancel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVibrate:) name:@"watchisvibrate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setInversecolor:) name:@"watchisinversecolor" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPowerOn:) name:@"PowerOnWatch" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPowerOff:) name:@"PowerOffWatch" object:nil];

    bBound = [[NSUserDefaults standardUserDefaults] boolForKey:@"isWatchConnected"];
//    if (bBound) {
//         [self getWatchSet];
//    }

    sleepTimeController = [[SettingSleepTimeViewController alloc] init];
//    self.anObserver =[[NSNotificationCenter defaultCenter] addObserverForName:kBLEChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//        if ([[BLEServerManager sharedManager] isBLEConnectedWithoutAlert]) {
//            bBound = YES;
//            
//            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
//            
//
////
////            [[BLEServerManager sharedManager] getInverseColor];
//            
//        }else{
//            bBound = NO;
//        }
//    }];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWatchConnected:) name:kBLEChangedNotification object:nil];
}

-(void)changeWatchConnected:(NSNotification *)notification
{
     bBound = [[NSUserDefaults standardUserDefaults] boolForKey:@"isWatchConnected"];
    if (bBound) {
        [self getWatchSet];
    }
}

-(void)getWatchSet
{
    [[BLEServerManager sharedManager] getIsVibrate:^(void){
        [[BLEServerManager sharedManager] getInverseColor:^(void){
        }];
    }];

//    [[BLEServerManager sharedManager] sendWatchLanguage:@"" finish:^(void){
//    }];
//    sleep(2);
//    [[BLEServerManager sharedManager] sendWatchSleepTime:@"" finish:^(void){
//    }];
//    sleep(2);
//    [[BLEServerManager sharedManager] getIsVibrate];
//    if (![[BLEServerManager sharedManager] isSending]) {
//        [[BLEServerManager sharedManager] getInverseColor];
//    }
    
//    sleep(2);
//    [[BLEServerManager sharedManager] getPowerOnWatch];
//    sleep(2);
//    [[BLEServerManager sharedManager] getPowerOffWatch];
}

-(void)setCancel
{
    [self dismissSemiModalView];
}

-(void)setSleepTime:(NSNotification *)notification
{
    NSString* sleepTime = notification.object;
    int isleepTime = [sleepTime intValue]/1000;
    if (isleepTime>59)
    {
        isleepTime = isleepTime/60;
        [sleepLabel setText:[NSString stringWithFormat:@"%d分钟", isleepTime]];
    }
    else
    {
        [sleepLabel setText:[NSString stringWithFormat:@"%d秒", isleepTime]];
    }
    [ViewUtils showToast:@"设置休眠时间成功"];
    
    [tableView reloadData];
}

-(void)setVibrate:(NSNotification *)notification
{
    BOOL bVibrate = [[notification.object objectForKey:@"enabled"] boolValue];
    if (bVibrate)
    {
        [switchVibrate setOn:YES];
    }
    else
    {
        [switchVibrate setOn:NO];
    }
}

-(void)setInversecolor:(NSNotification *)notification
{
    BOOL bInversecolor = [[notification.object objectForKey:@"enabled"] boolValue];
    if (bInversecolor)
    {
        [switchInverse setOn:YES];
    }
    else
    {
        [switchInverse setOn:NO];
    }
}

-(void)setPowerOn:(NSNotification *)notification
{
    NSDictionary* dicValue = [notification.object objectForKey:@"value"];
    PowerOntext = [NSString stringWithFormat:@"%d:%d", [dicValue objectForKey:@"hour"],[dicValue objectForKey:@"minute"]];
}

-(void)setPowerOff:(NSNotification *)notification
{
    NSDictionary* dicValue = [notification.object objectForKey:@"value"];
    PowerOfftext = [NSString stringWithFormat:@"%d:%d", [dicValue objectForKey:@"hour"],[dicValue objectForKey:@"minute"]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1)
    {
        return 3;
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *cellIdentifier = @"MoreSettingsCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (!cell)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    else
//    {
//        while ([cell.contentView.subviews lastObject] != nil) {
//            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
//        }
//    }
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];//以indexPath来唯一确定cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor colorWithHex:@"333333"];
    
    cell.userInteractionEnabled = bBound;
    cell.textLabel.enabled = bBound;
    cell.detailTextLabel.enabled = bBound;
    
    int section = indexPath.section;
    NSLog(@"%d",section);
    int row = indexPath.row;
    switch (section) {
        case 0:
        {
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (row==0) {
                cell.userInteractionEnabled = YES;
                cell.textLabel.enabled = YES;
                cell.detailTextLabel.enabled = YES;
            }
            if (row==1) {
                [cell setEditing:NO];
            }
            break;
        }
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+2];
            if (row == 0) {
                if (switchVibrate) {
                    [switchVibrate removeFromSuperview];
                    switchVibrate = nil;
                }
                
                switchVibrate = [[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 51, 31)];
                switchVibrate.tag = SWITCH_VIBRATE_TAG;
                [switchVibrate addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:switchVibrate];
            }
            else if(row == 1)
            {
                if (!sleepLabel) {
                    [sleepLabel removeFromSuperview];
                    sleepLabel = nil;
                }
                sleepLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 10, 71, 31)];
                sleepLabel.text = [NSString stringWithFormat:@"%@秒", @"15"];
                sleepLabel.textColor = [UIColor blueColor];
                sleepLabel.font = [UIFont systemFontOfSize:10.0];
                [cell addSubview:sleepLabel];
            }
            else if(row == 2)
            {
                if (switchInverse) {
                    [switchInverse removeFromSuperview];
                    switchInverse = nil;
                }
                switchInverse = [[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 51, 31)];
                switchInverse.tag = SWITCH_INVERSE_TAG;
                [switchInverse addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:switchInverse];
            }
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+2];
            break;
        }
        case 2:
        {
            [cell setHighlighted:NO];
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+5];
            if (row == 0) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if(row == 1)
            {
                if (!powerTimeLabel) {
                    [powerTimeLabel removeFromSuperview];
                    powerTimeLabel = nil;
                }
                powerTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 10, 111, 31)];
                powerTimeLabel.text = [NSString stringWithFormat:@"%@开机  %@关机", PowerOntext, PowerOfftext];
                powerTimeLabel.textColor = [UIColor blueColor];
                powerTimeLabel.font = [UIFont systemFontOfSize:10.0];
                [cell addSubview:powerTimeLabel];
            }
            break;
        }
        case 3:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+8];
            cell.textLabel.textColor = [UIColor colorWithHex:@"B800F5"];
            break;
        }
        case 4:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [self.settingList objectAtIndex:indexPath.row+9];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int section = indexPath.section;
    int row = indexPath.row;
    switch (section)
    {
        case 0:
        {
            if (row == 0)
            {
                ConnectionViewController *aController = [[ConnectionViewController alloc] init];
                aController.backName = NSLocalizedString(@"SynConnection", nil);
                [self.navigationController pushViewController:aController animated:YES];
            }
            else
            {
                 [[BLEServerManager sharedManager] sendSearchWatchCommand];
            }

            break;
        }
        case 1:
        {
            if (row == 1) {
                [self presentSemiViewController:sleepTimeController];
            }
            else if (row==3)
            {
                [[BLEServerManager sharedManager] sendWatchSleepSet:@"true" finish:^(void){
                    [ViewUtils showToast:@"设置为简洁锁屏成功"];
                }];
            }

            break;
        }
        case 2:
        {
            NSString *className = self.subviewControllerArray[row];
            UIViewController *aController = [[NSClassFromString(className) alloc] initWithNibName:nil bundle:nil];
            ((NaviCommonViewController*)aController).backName = self.titleArray[row];
            if (row == 0)
            {
            }
            else if(row == 1)
            {
                ((NaviCommonViewController*)aController).backName = @"开关机设置";
            }
            [self.navigationController pushViewController:aController animated:YES];

            break;
        }
        case 3:
        {
            [self settingAll];
            break;
        }
        case 4:
        {
            SettingMoreViewController* setMoreController = [[SettingMoreViewController alloc] init];
            setMoreController.backName = NSLocalizedString(@"more settings", @"更多设置");
            [self.navigationController pushViewController:setMoreController animated:YES];
            break;
        }
        default:
            break;
    }
}

-(void)switchClick: (id)sender
{
    UISwitch *switchBtn = (UISwitch *)sender;
    BOOL bsetYES = [switchBtn isOn];
    NSString* set;
    if (bsetYES) {
        set = @"true";
    }
    else
    {
        set = @"false";
    }
    if (switchBtn.tag == SWITCH_INVERSE_TAG) {
        if([[BLEServerManager sharedManager] isBLEConnected])
        {
            [[BLEServerManager sharedManager] sendInverseColor:set finish:^(void){
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
            [[BLEServerManager sharedManager] sendVibrateSetting:set finish:^(void){
                [ViewUtils showToast:@"设置震动成功"];
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
    else
    {
    }
}

/*
 * 一键优化设置
 */
-(void)settingAll
{
    if (![[BLEServerManager sharedManager] isBLEPoweredOn]) {
        return;
    }
    if (![[BLEServerManager sharedManager] isBLEConnected]) {
        return;
    }
    
    //设置休眠时间为15秒
    [[BLEServerManager sharedManager] sendWatchSleepTime:@"15000" finish:^(void){

    }];
    //关闭反色设置
    [[BLEServerManager sharedManager] sendInverseColor:@"false" finish:^(void){

    }];
    
    //打开震动
    [[BLEServerManager sharedManager] sendVibrateSetting:@"ture" finish:^(void){

    }];
    
//    //打开锁屏时钟
//    [[BLEServerManager sharedManager] sendWatchSleepSet:@"true" finish:^(void){
//        
//    }];
    
    //同步手机的时间和日期，打开24小时制
    
    
    //设置开关机时间
    [[BLEServerManager sharedManager] sendPowerOnWatch:@"7" minute:@"0" enabled:@"true" finish:^(void){

    }];
    [[BLEServerManager sharedManager] sendPowerOffWatch:@"22" minute:@"0" enabled:@"true" finish:^(void){

    }];
    
    //设置语言为中文简体
    [[BLEServerManager sharedManager] sendWatchLanguage:@"中文简体" finish:^(void){

    }];
    
    [ViewUtils showToast:@"设置语言成功"];
}
            
@end
