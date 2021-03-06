//
//  MoreSettingViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingCell.h"
#import "AppCenterViewController.h"
#import "MBProgressHUD.h"
//#import "BLEManager.h"
#import "UpdateWatchControllerViewController.h"
#import "ViewUtils.h"
#import "BLEServerManager.h"

#define SWITCH_TIMEADJUST_TAG  1001
#define SWITCH_DISCOVERYWATCH_TAG  1002
#define SWITCH_PUSHSETTING_TAG  1003
#define SWITCH_CONNECTTESTING_TAG  1004

@implementation MoreSettingCell

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setFrame:CGRectMake(20, 15,20, 20)];
    
    [self.textLabel setFrame:CGRectMake(50, 10, 200, 30)];
}

@end

@interface SettingViewController ()
@property(nonatomic,strong)NSArray *subviewControllerArray;
@property(nonatomic,strong)NSArray *titleArray;

@property(nonatomic,strong)id         anObserver;
@end

@implementation SettingViewController

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
                                                                           , CGRectGetWidth(self.view.frame), self.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50;
    tableView.scrollEnabled = NO;
    tableView.tableHeaderView = [self tableHeaderView];
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
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
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"SettingCell";
    MoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil) {
    }
    if (!cell)
    {
        cell = [[MoreSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor colorWithHex:@"333333"];
    
    switch (indexPath.row)
    {
        case 0:
        {
            //cell.textLabel.text = NSLocalizedString(@"Time Proofread", nil);
            cell.textLabel.text = NSLocalizedString(@"Time Proofread", nil);
            cell.imageView.image = [UIImage imageNamed:@"时间"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //            UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 50.5, 10)];
            //            switchBtn.tag = SWITCH_TIMEADJUST_TAG;
            //            [switchBtn addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
            //            [cell addSubview:switchBtn];
//            ToggleView *toggleViewBaseChange = [[ToggleView alloc]initWithFrame:CGRectMake(250, 13, 51, 24) toggleViewType:ToggleViewTypeNoLabel toggleBaseType:ToggleBaseTypeChangeImage toggleButtonType:ToggleButtonTypeDefault];
//            toggleViewBaseChange.tag = SWITCH_TIMEADJUST_TAG;
//            toggleViewBaseChange.toggleDelegate = self;
//            [cell addSubview:toggleViewBaseChange];
            
        }
            break;
        case 1:
        {
            cell.textLabel.text = NSLocalizedString(@"Search Watch", nil);
            cell.imageView.image = [UIImage imageNamed:@"setting_Watch"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
            break;
//        case 2:
//        {
//            cell.textLabel.text = @"推送开关";
//            cell.imageView.image = [UIImage imageNamed:@"推送"];
////            UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(250, 10, 50.5, 10)];
////            switchBtn.tag = SWITCH_PUSHSETTING_TAG;
////            [switchBtn addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
////            [cell addSubview:switchBtn];
//            
//            ToggleView *toggleViewBaseChange = [[ToggleView alloc]initWithFrame:CGRectMake(250, 13, 51, 24) toggleViewType:ToggleViewTypeNoLabel toggleBaseType:ToggleBaseTypeChangeImage toggleButtonType:ToggleButtonTypeDefault];
//            toggleViewBaseChange.tag = SWITCH_PUSHSETTING_TAG;
//            toggleViewBaseChange.toggleDelegate = self;
//            [cell addSubview:toggleViewBaseChange];
//            
//        }
//            break;
//        case 2:
//        {
//            cell.textLabel.text = NSLocalizedString(@"Commucation Test", nil);
//            cell.imageView.image = [UIImage imageNamed:@"通信"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            
//        }
            //            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Watch Version", nil);
            cell.imageView.image = [UIImage imageNamed:@"二维码"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

            
            
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Account Bound", nil);
            cell.imageView.image = [UIImage imageNamed:@"账号"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case 4:
            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
            cell.imageView.image = [UIImage imageNamed:@"setting_Setting"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        
        

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
    switch (indexPath.row)
    {
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
        }
            break;
        case 1:
        {
            [[BLEServerManager sharedManager] sendSearchWatchCommand];
            
        }
            break;
//        case 2:
//        {
//            
//        }
//            break;
        
        default:
        {
            NSString *className = self.subviewControllerArray[indexPath.row - 2];
            UIViewController *aController = [[NSClassFromString(className) alloc] initWithNibName:nil bundle:nil];
             
            ((NaviCommonViewController*)aController).backName = self.titleArray[indexPath.row - 2];
            [self.navigationController pushViewController:aController animated:YES];
        }
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

- (void)selectRightButton :(id)sender
{
    ToggleView *view = (ToggleView *)sender;
    if (view.tag == SWITCH_TIMEADJUST_TAG)
    {
        __weak typeof(ToggleView*) welkView = view;
        BlockUIAlertView *alertView = [[BlockUIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Confirm Time Proofread", nil) cancelButtonTitle:NSLocalizedString(@"OK", nil)  otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"No", nil), nil] buttonBlock:^(NSInteger indexButton){
            NSLog(@"%d",indexButton);
            if (indexButton == 1)
            {
                welkView.selectedButton = ToggleButtonSelectedLeft;
            }
        }];
        [alertView show];
    }
    else if(view.tag == SWITCH_DISCOVERYWATCH_TAG)
    {
    }
    else if (view.tag == SWITCH_CONNECTTESTING_TAG)
    {
    }
    else
    {}
    NSLog(@"RightButton Selected");
}

//-(void)switchClick: (id)sender
//{
//    UISwitch *switchBtn = (UISwitch *)sender;
//    if (switchBtn.tag == SWITCH_TIMEADJUST_TAG) {
//        ;
//    }
//    else if (switchBtn.tag == SWITCH_DISCOVERYWATCH_TAG)
//    {
//        ;
//    }
//    else if (switchBtn.tag == SWITCH_PUSHSETTING_TAG)
//    {
//        ;
//    }
//    else if (switchBtn.tag == SWITCH_CONNECTTESTING_TAG)
//    {
//        ;
//    }
//}
@end
