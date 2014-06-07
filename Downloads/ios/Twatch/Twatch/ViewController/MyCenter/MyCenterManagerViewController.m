//
//  MyCenterManagerViewController.m
//  Twatch
//
//  Created by yugong on 14-6-4.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "MyCenterManagerViewController.h"

#import "MyMessageEditViewController.h"
#import "SoundRecordViewController.h"
#import "SportMessageViewController.h"

@interface MyCenterManagerViewController ()

@end

@implementation MyCenterManagerViewController

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
    
    [self.backBtn setEnabled:NO];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset
                                                                           , CGRectGetWidth(self.view.frame), self.height-50) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    //tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 2;
    }
    else if(section == 2)
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 50;
    }
    else
    {
        return 30;
    }
    
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
    
    int section = indexPath.section;
    int row = indexPath.row;
    switch (section) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"个人信息";
            break; 
            
        }
        case 1:
        {
            if (row == 0) {
                cell.textLabel.text = @"录音记录";
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"运动信息";
            }
            break;
        }
//        case 2:
//        {
//            if (row == 0) {
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                cell.textLabel.text = @"快捷对讲";
//            }
//            else
//            {
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                cell.textLabel.text = @"关注列表";
//            }
//            break;
//        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section==0) {
        MyMessageEditViewController *myMessageEditController = [[MyMessageEditViewController alloc] init];
        myMessageEditController.backName = @"个人资料";
        [self.navigationController pushViewController:myMessageEditController animated:YES];
    }
    else if(indexPath.section == 1)
    {
        if (indexPath .row == 0) {
            SoundRecordViewController *soundRecordController = [[SoundRecordViewController alloc] init];
            soundRecordController.backName = @"录音记录";
            [self.navigationController pushViewController:soundRecordController animated:YES];
        }
        else if(indexPath.row == 1)
        {
            SportMessageViewController *sportMessageController = [[SportMessageViewController alloc] init];
            sportMessageController.backName = @"运动信息";
            [self.navigationController pushViewController:sportMessageController animated:YES];
        }
    }
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
