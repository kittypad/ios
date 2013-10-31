//
//  MoreSettingViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "MoreSettingViewController.h"
#import "AboutViewController.h"
#import "FeedBackViewController.h"
@interface MoreSettingViewController ()

@end

@implementation MoreSettingViewController

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
    // Do any additional setup after loading the view from its nib.
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 45;
    tableView.scrollEnabled = NO;
    tableView.backgroundColor = [UIColor getColor:@"F3F8FE"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell != nil) {
    }
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.textColor = [UIColor getColor:@"292929"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
    UIButton *attentButton = [FactoryMethods buttonWWithNormalImage:@"加关注.png" hiliteImage:@"加关注.png" target:self selector:@selector(attention:)];
    [attentButton setTitle:@"关注" forState:UIControlStateNormal];
    [attentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    attentButton.frame = CGRectChangeOrigin(attentButton.frame, 10, 30);
    attentButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    attentButton.titleLabel.textColor = [UIColor blueColor];
    
    CGSize size = [@"关注" sizeWithFont:[UIFont systemFontOfSize:12.0]];
    attentButton.frame = CGRectMake(CGRectGetWidth(cell.frame) - CGRectGetWidth(attentButton.frame) - size.width - 10, (CGRectGetHeight(cell.frame) - CGRectGetHeight(attentButton.frame))/2, CGRectGetWidth(attentButton.frame) + size.width, CGRectGetHeight(attentButton.frame));

    
    switch (indexPath.row) {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"关于我们";
            break;
        case 1:
            cell.textLabel.text = @"升级更新";
            cell.detailTextLabel.text = @"已最新v1.0";
            break;
        case 2:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"意见反馈";
            break;
        case 3:
        {
            cell.textLabel.text = @"土曼微博";
            [cell addSubview:attentButton];
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"土曼微信";
            [cell addSubview:attentButton];

        }
            break;
            
        default:
            break;
    }
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.rowHeight - .5, CGRectGetWidth(tableView.frame) - 15, .5)];
    line.backgroundColor = [UIColor getColor:@"e2e1e4"];
    [cell addSubview:line];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)section
{
    return 45;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        AboutViewController *about = [[AboutViewController alloc] init];
        about.backName = @"关于我们";
        [self.navigationController pushViewController:about animated:YES];
    }
    else if(indexPath.row == 2)
    {
        FeedBackViewController *feedback = [[FeedBackViewController alloc] init];
        feedback.backName = @"意见反馈";
        [self.navigationController pushViewController:feedback animated:YES];
    }

}
-(void)attention: (id)sender
{
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
