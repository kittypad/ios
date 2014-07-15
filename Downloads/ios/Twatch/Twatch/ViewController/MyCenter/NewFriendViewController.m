//
//  NewFriendViewController.m
//  Twatch
//
//  Created by yugong on 14-7-2.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "NewFriendViewController.h"

@interface NewFriendViewController ()
{
    UITableView* newFriendTableView;
}

@end

@implementation NewFriendViewController

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
    
    newFriendTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset
                                                                   , CGRectGetWidth(self.view.frame), self.height)];
    newFriendTableView.delegate = self;
    newFriendTableView.dataSource = self;
    newFriendTableView.rowHeight = 50;
    //tableView.scrollEnabled = YES;
    newFriendTableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    newFriendTableView.separatorColor = [UIColor clearColor];
    
    [self.view addSubview:newFriendTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.addFriendList count];
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
    static NSString *CellIdentifier = @"ModalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    NSDictionary* frienddic = [self.addFriendList objectAtIndex:indexPath.row];
    
    
    //选中后的字体颜色设置
    //cell.textLabel.highlightedTextColor = [UIColor redColor];
    cell.textLabel.text = [frienddic objectForKey:@"focusUserName"];
    
    UIButton* friendstatusbtn = [[UIButton alloc] initWithFrame:CGRectMake(250, 10, 60, 25)];
    NSString* focustype = [frienddic objectForKey:@"focusType"];
    NSString* strfriendstatus;
    if ([focustype intValue] == 0) {
        strfriendstatus = @"没有关系";
        [friendstatusbtn setBackgroundImage:[UIImage imageNamed:@"attention_add_no"] forState:UIControlStateNormal];
    }
    else if ([focustype intValue] == 1)
    {
        strfriendstatus = @"验证中";
        [friendstatusbtn setBackgroundImage:[UIImage imageNamed:@"attention_verification"] forState:UIControlStateNormal];
    }
    else if ([focustype intValue] == 2)
    {
        strfriendstatus = @"待处理";
        [friendstatusbtn setBackgroundImage:[UIImage imageNamed:@"attention_accept"] forState:UIControlStateNormal];
        
    }
    else if ([focustype intValue] == 3)
    {
        strfriendstatus = @"已添加";
        [friendstatusbtn setBackgroundImage:[UIImage imageNamed:@"attention_added"] forState:UIControlStateNormal];
    }
    
    [cell addSubview:friendstatusbtn];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    MyFriendDetailViewController* friendDetailView = [[MyFriendDetailViewController alloc] init];
    //    friendDetailView.backName = @"详细资料";
    //
    //    NSDictionary* frienddic = [self.friendarray objectAtIndex:indexPath.row];
    //    friendDetailView.frienddic = frienddic;
    //
    //    [self.navigationController pushViewController:friendDetailView animated:YES];
    
//        NSMutableDictionary* frienddic = [self.friendarray objectAtIndex:indexPath.row];
//        NSString* focustype = [frienddic objectForKey:@"focusType"];
//        if ([focustype intValue] == 3) {
//            MyfastTalkViewController* fastTalkView = [[MyfastTalkViewController alloc] init];
//            fastTalkView.backName = [frienddic objectForKey:@"focusUserName"];
//            [fastTalkView setUserNameDic:self.myDic];
//            [fastTalkView setFriendNameDic:frienddic];
//            self.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:fastTalkView animated:YES];
//        }
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
