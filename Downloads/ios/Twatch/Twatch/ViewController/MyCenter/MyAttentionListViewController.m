//
//  MyAttentionListViewController.m
//  Twatch
//
//  Created by yugong on 14-6-16.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "MyAttentionListViewController.h"
#import "MyFriendDetailViewController.h"
#import "MyfastTalkViewController.h"
#import "NetDataManager.h"
#import "NewFriendViewController.h"

@interface MyAttentionListViewController ()
{
    UITextField* searchText;
    UITableView* friendlistView;
    NSMutableDictionary* updatemessagedic;
}

@end

@implementation MyAttentionListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageList:) name:@"updateMessagelist" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    searchText = [[UITextField alloc] initWithFrame:CGRectMake(10, IS_IOS7?64:44, 300, 40)];
    searchText.borderStyle = UITextBorderStyleRoundedRect;
    searchText.returnKeyType = UIReturnKeySend;
    [searchText setPlaceholder:@"请输入手机号"];
    searchText.keyboardType = UIKeyboardTypeNumberPad;
    searchText.delegate = self;
    [self.view addSubview:searchText];
    
    UIButton* searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(250, IS_IOS7?64:44, 60, 40)];
    [searchBtn setBackgroundColor:[UIColor grayColor]];
    [searchBtn setTitle:@"添加" forState:UIControlStateNormal];
    //[searchBtn setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(addFriendClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    friendlistView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset+50
                                                                           , CGRectGetWidth(self.view.frame), self.height-50)];
    friendlistView.delegate = self;
    friendlistView.dataSource = self;
    friendlistView.rowHeight = 30;
    //friendlistView.scrollEnabled = YES;
    friendlistView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    //friendlistView.separatorColor = [UIColor clearColor];
    friendlistView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    friendlistView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:friendlistView];
    
//    //处理虚拟键盘
//    UITapGestureRecognizer *tap =
//    [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(dismissKeyboard)];
//    [self.view addGestureRecognizer:tap];
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    [friendlistView addGestureRecognizer:longPressGr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMessageUpdate:) name:@"deleteMessageUpdate" object:nil];

}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gesture locationInView:friendlistView];
        NSIndexPath * indexPath = [friendlistView indexPathForRowAtPoint:point];
        if(indexPath == nil) return ;
 
        //add your code here
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [searchText resignFirstResponder];
}

-(NSArray*) getFriendCallNumList
{
    NSMutableArray* friendcallList = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.friendarray count]; i++) {
        NSMutableDictionary* frienddic = [self.friendarray objectAtIndex:i];
        [friendcallList addObject:[frienddic objectForKey:@"focusUserName"]];
    }
    
    return friendcallList;
}

-(NSArray*) getNewFriendList
{
    NSMutableArray* newFriendList = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.friendarray count]; i++) {
        NSMutableDictionary* frienddic = [self.friendarray objectAtIndex:i];
       NSString* focustype = [frienddic objectForKey:@"focusType"];
        if ([focustype isEqualToString:@"2"]) {
            [newFriendList addObject:frienddic];
        }
    }
    
    return newFriendList;
}

//限制输入字符数量
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (temp.length > 11) {
        textField.text = [temp substringToIndex:11];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSArray* acrrylist = [self getFriendCallNumList];
    //输入11位数字后检查是否用户名有效
    
    [[NetDatamanager sharedManager] checkUserNameValid:[self.myDic objectForKey:@"userName"] Userlist:acrrylist success:^(id response, NSString* str){
        //        NSMutableDictionary* allmessagedic = response;
        
        if ([str isEqualToString:@"0"]) {
            [[NetDatamanager sharedManager] focusSomeone:[self.myDic objectForKey:@"userName"] focusUserName:textField.text verifyMsg:[NSNull null] success:^(id response, NSString* str){
            }failure:^(NSError* error){
                
            }];
        }
        else
        {
        }
    }failure:^(NSError* error){
        
    }];
    
    return YES;
}

-(void)dismissKeyboard {
    NSArray *subviews = [self.view subviews];
    for (id objInput in subviews) {
        if ([objInput isKindOfClass:[UITextField class]]) {
            UITextField *theTextField = objInput;
            if ([objInput isFirstResponder]) {
                [theTextField resignFirstResponder];
            }
        }
    }
}

-(void)updateMessageList:(NSNotification*)notification
{
    updatemessagedic = notification.object;
    
    [friendlistView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatespeechRecords" object:updatemessagedic];
}

-(void)deleteMessageUpdate:(NSNotification*)notification
{
    NSString* deleteUserName = notification.object;
    [updatemessagedic removeObjectForKey:[updatemessagedic objectForKey:deleteUserName]];
    [friendlistView reloadData];
}

-(void)addFriendClicked
{
    if ([searchText.text length]<11) {
        return;
    }
    
    NSArray* acrrylist = self.friendarray;
    //输入11位数字后检查是否用户名有效
    
    [[NetDatamanager sharedManager] checkUserNameValid:[self.myDic objectForKey:@"userName"] Userlist:acrrylist success:^(id response, NSString* str){
        //        NSMutableDictionary* allmessagedic = response;
        
        if ([str isEqualToString:@"0"]) {
            [[NetDatamanager sharedManager] focusSomeone:[self.myDic objectForKey:@"userName"] focusUserName:searchText.text verifyMsg:[NSNull null] success:^(id response, NSString* str){
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                hud.labelText = @"添加好友成功";
                hud.mode = MBProgressHUDModeText;
                [self.view addSubview:hud];
                [hud show:YES];
                [hud hide:YES afterDelay:2];
            }failure:^(NSError* error){
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                hud.labelText = @"添加好友失败";
                hud.mode = MBProgressHUDModeText;
                [self.view addSubview:hud];
                [hud show:YES];
                [hud hide:YES afterDelay:2];
            }];
        }
        else
        {
        }
    }failure:^(NSError* error){
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else
    {
        return  [self.friendarray count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 40;
    }
    else
    {
        return 50;
    }
 
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"新朋友";
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        NSDictionary* frienddic = [self.friendarray objectAtIndex:indexPath.row];
        
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
        
        
        NSMutableArray* updateMessageArray = [updatemessagedic objectForKey:[frienddic objectForKey:@"focusUserName"]];
        if ([updateMessageArray count]>0) {
            UIButton* soundCount = [[UIButton alloc] initWithFrame:CGRectMake(147, 12, 26, 26)];
            [soundCount setBackgroundImage:[UIImage imageNamed:@"orangecircle"] forState:UIControlStateNormal];
            [soundCount setTitle:[NSString stringWithFormat:@"%d", [updateMessageArray count]] forState:UIControlStateNormal];
            [soundCount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [cell addSubview:soundCount];
        }
    }
    
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
    
    if (indexPath.section == 0) {
        NewFriendViewController* newFriendListView = [[NewFriendViewController alloc] init];
        newFriendListView.backName = @"新朋友";
        newFriendListView.addFriendList = [self getNewFriendList];
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:newFriendListView animated:YES];
    }
    else
    {
        NSMutableDictionary* frienddic = [self.friendarray objectAtIndex:indexPath.row];
        NSString* focustype = [frienddic objectForKey:@"focusType"];
        if ([focustype intValue] == 3) {
            MyfastTalkViewController* fastTalkView = [[MyfastTalkViewController alloc] init];
            fastTalkView.backName = [frienddic objectForKey:@"focusUserName"];
            [fastTalkView setUserNameDic:self.myDic];
            [fastTalkView setFriendNameDic:frienddic];
            [fastTalkView setAddupdateMessageArray:[updatemessagedic objectForKey:fastTalkView.backName]];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:fastTalkView animated:YES];
        }
    }
}

//获取联系人消息
-(NSURLConnection*)getMessage:(NSString*)url user:(NSString*) user
{
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request1 setHTTPMethod:@"POST"];
    
    NSString *uuid1 =[[NSUUID UUID] UUIDString];
    [request1 setValue:@"WT" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request1 setValue:@"getMessage" forHTTPHeaderField:@"ACTION"];
    [request1 setValue:@"1.0" forHTTPHeaderField:@"APIVersion"];
    [request1 setValue:uuid1 forHTTPHeaderField:@"UUID"];
    [request1 setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [request1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:user,@"userName", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    [request1 setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request1 delegate:self];
    
    return connection;
}

//取消关注
-(NSURLConnection*)cancelAttention:(NSString*)url userName:(NSString*) userName focusUserName:(NSString*)focusUserName
{
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request1 setHTTPMethod:@"POST"];
    
    NSString *uuid1 =[[NSUUID UUID] UUIDString];
    [request1 setValue:@"WT" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request1 setValue:@"deleteFocus" forHTTPHeaderField:@"ACTION"];
    [request1 setValue:@"1.0" forHTTPHeaderField:@"APIVersion"];
    [request1 setValue:uuid1 forHTTPHeaderField:@"UUID"];
    [request1 setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [request1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:userName,@"userName",focusUserName,@"focusUserName", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    [request1 setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request1 delegate:self];
    
    return connection;
}

//发起关注
-(NSURLConnection*)FocusSomeone:(NSString*)url userName:(NSString*) userName focusUserName:(NSString*)focusUserName
{
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request1 setHTTPMethod:@"POST"];
    
    NSString *uuid1 =[[NSUUID UUID] UUIDString];
    [request1 setValue:@"WT" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request1 setValue:@"focusSomeone" forHTTPHeaderField:@"ACTION"];
    [request1 setValue:@"1.0" forHTTPHeaderField:@"APIVersion"];
    [request1 setValue:uuid1 forHTTPHeaderField:@"UUID"];
    [request1 setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [request1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:userName,@"userName",focusUserName, @"focusUserName", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    [request1 setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request1 delegate:self];
    
    return connection;
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
