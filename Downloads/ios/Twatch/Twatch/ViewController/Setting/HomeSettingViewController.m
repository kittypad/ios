//
//  HomeSettingViewController.m
//  Twatch
//
//  Created by 龚涛 on 11/29/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "HomeSettingViewController.h"

@interface HomeSettingViewController ()

@property (nonatomic, strong) NSArray *titleSourceArray;
@property (nonatomic, strong) NSArray *subControllerSourceArray;

@end

@implementation HomeSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.backName = NSLocalizedString(@"more settings", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IS_IOS7 ? 64 : 44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 45;
    tableView.scrollEnabled = NO;
    tableView.backgroundColor = [UIColor colorWithHex:@"F3F8FE"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    
    self.titleSourceArray = [NSArray arrayWithObjects:NSLocalizedString(@"Time Proofread", nil), NSLocalizedString(@"Watch Search", nil), NSLocalizedString(@"Notification", nil), NSLocalizedString(@"Commucation Test", nil), NSLocalizedString(@"Settings", nil), NSLocalizedString(@"QR Code", nil), NSLocalizedString(@"Accounts", nil), nil];
    self.subControllerSourceArray = [NSArray arrayWithObjects:@"MoreSettingViewController",
                                     @"QRCodeManagerViewController",
                                     @"AGAuthViewController", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: {
            return 4;
        }
        case 1: {
            return 3;
        }
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textColor = [UIColor colorWithHex:@"292929"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
        cell.detailTextLabel.textColor = RGB(81, 150, 221, 1);
    }
    
    
    switch (indexPath.section) {
        case 0: {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = self.titleSourceArray[indexPath.row];
            switch (indexPath.row) {
                case 0: {
                    break;
                }
                case 1: {
                    break;
                }
                case 2: {
                    break;
                }
                case 3: {
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = self.titleSourceArray[indexPath.row+4];
            break;
        }
        default:
            break;
    }
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.rowHeight - 0.5, CGRectGetWidth(tableView.frame), 0.5)];
    line.backgroundColor = [UIColor colorWithHex:@"e2e1e4"];
    [cell addSubview:line];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)section
{
    return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        NaviCommonViewController *vc = [[NSClassFromString(self.subControllerSourceArray[indexPath.row]) alloc] init];
        vc.backName = self.titleSourceArray[indexPath.row+4];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0.0;
    else return 32.5f;
}

@end
