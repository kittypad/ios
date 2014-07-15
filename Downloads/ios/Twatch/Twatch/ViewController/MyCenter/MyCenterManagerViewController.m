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
#import "DataManager.h"
#import <SBJson.h>

#import "UIImageView+AFNetworking.h"
#import "MyAttentionListViewController.h"
#import "MyfastTalkViewController.h"
#import "WatchStyleViewController.h"
#import "NetDatamanager.h"

@interface MyCenterManagerViewController ()
{
    MyMessageEditViewController *myMessageEditController;
    UIImageView* photo;
    UILabel* username;
    UILabel* declaration;
    NSMutableArray* friendlist;
    NSURLConnection* userConnection;
    NSURLConnection* friendListConnection;
    
    NSMutableDictionary *addNewMessagesdic;
}

@end

@implementation MyCenterManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginToMyCenter:) name:@"logintomycenter" object:nil];
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
    
    myMessageEditController = [[MyMessageEditViewController alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gobackToLogin:) name:@"gobacktologin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInformation:) name:@"updateInformation" object:nil];
    
    addNewMessagesdic = nil;
    addNewMessagesdic = [[NSMutableDictionary alloc] init];
    //获取消息
    [self getMessage:self.userNametext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMessageUpdate:) name:@"deleteMessageUpdate" object:nil];
}

-(void)getMessage:(NSString*)userName
{

    [[NetDatamanager sharedManager] getMessage:userName success:^(id response){
        //        NSMutableDictionary* allmessagedic = response;
        NSMutableDictionary* messagesDic = [[NSMutableDictionary alloc] initWithDictionary:response];
        if ([messagesDic objectForKey:@"count"] != nil && [messagesDic objectForKey:@"count"] !=0) {
            NSMutableArray* messageArray = [messagesDic objectForKey:@"messages"];
            
            for (int i=0; i<[messageArray count]; i++)
            {
                NSMutableDictionary* messageDic = [messageArray objectAtIndex:i];
                
                NSString* msgType = [messageDic objectForKey:@"msgType"];
                if ([msgType isEqualToString:@"user"]) {
                    NSMutableArray* frommessageArray = [addNewMessagesdic objectForKey:[messageDic objectForKey:@"fromUser"]];
                    if ([frommessageArray count]>0 ) {
                        [frommessageArray addObject:messageDic];
                    }
                    else
                    {   frommessageArray = [[NSMutableArray alloc] init];
                        [frommessageArray addObject:messageDic];
                        [addNewMessagesdic setObject:frommessageArray forKey:[messageDic objectForKey:@"fromUser"]];
                    }
                    [addNewMessagesdic setValue:frommessageArray forKey:[messageDic objectForKey:@"fromUser"]];
                }
                else if([msgType isEqualToString:@"sys_focus"])
                {
                }
                else if([msgType isEqualToString:@"group"])
                {
                }
                else if([msgType isEqualToString:@"sys_feedback"])
                {
                }
                else if([msgType isEqualToString:@"sys_connect"])
                {
                }
            }
            
            if ([messageArray count]>0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessagelist" object:addNewMessagesdic];
            }
            
        }
        
        [self getMessage:userName];
        
    }];
}

-(void)deleteMessageUpdate:(NSNotification*)notification
{
    NSString* deleteUserName = notification.object;
    [addNewMessagesdic removeObjectForKey:[addNewMessagesdic objectForKey:deleteUserName]];
}

-(void)loginToMyCenter:(NSNotification*) notification
{
    self.userNametext = notification.object;
    
    [[NetDatamanager sharedManager] getUserProfile:self.userNametext success:^(id response, NSString* str){
        
        NSMutableDictionary *testUserPrDict = [[NSMutableDictionary alloc] initWithDictionary:response];
        if ([str isEqualToString:@"0"])
        {
            [testUserPrDict setObject:self.userNametext forKey:@"userName"];
            
            username.text = self.userNametext;
            declaration.text = [NSString stringWithFormat:@"%@:%@",@"宣言", [testUserPrDict objectForKey:@"Signature"]];
            
            NSURL *portraitUrl = [NSURL URLWithString:@"http://photo.l99.com/bigger/31/1363231021567_5zu910.jpg"];
            UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
            
            [photo setImage:protraitImg];
            
            self.myMessageDic = testUserPrDict;
            //下载头像
            NSString* avatar = [self.myMessageDic objectForKey:@"Avatar"];
            if (avatar != nil && ![avatar isEqualToString:@""]) {
                [self downloadPhoto:[NSString stringWithFormat:@"http://www.yugong-tech.com/down_avatar.php?avatar=%@",
                                     avatar]];
            }

        }
        else if([str isEqualToString:@"1003"])
        {
            
        }
        
    }failure:^(NSError* error){
        
    }];
    
    [[NetDatamanager sharedManager] getMyFocusList:self.userNametext focustype:@"all" success:^(id response, NSString* str){
    
        NSMutableDictionary *testDict = response;
        if ([str isEqualToString:@"0"]) {
            NSMutableArray* friendcallList = [[NSMutableArray alloc] init];
            friendlist = [testDict objectForKey:@"focusList"];
        }
        else
        {
            
        }
    } failure:^(NSError* error){
    }];
}

-(void)gobackToLogin:(NSNotification*)notification
{
    [self.backBtn setEnabled:YES];
    [self goBack];
}

-(void)updateInformation:(NSNotification*)notification
{
    NSMutableDictionary* informationDic = notification.object;
    username.text = self.userNametext;
    declaration.text = [NSString stringWithFormat:@"%@:%@",@"宣言", [informationDic objectForKey:@"Signature"]];
    
    NSURL *portraitUrl = [NSURL URLWithString:@"http://photo.l99.com/bigger/31/1363231021567_5zu910.jpg"];
    UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
    [photo setImage:protraitImg];
    
    self.myMessageDic = informationDic;

    
    [photo setImage:[UIImage imageWithData:[self.myMessageDic objectForKey:@"avatarData"]]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 3;
    }
    else if(section == 2)
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 70;
    }
    else
    {
        return 40;
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
            photo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
            [photo.layer setCornerRadius:(photo.frame.size.height/2)];
            [photo.layer setMasksToBounds:NO];
            [photo setContentMode:UIViewContentModeScaleAspectFill];
            [photo setClipsToBounds:YES];
            photo.layer.shadowColor = [UIColor blackColor].CGColor;
            photo.layer.shadowOffset = CGSizeMake(4, 4);
            photo.layer.shadowOpacity = 0.5;
            photo.layer.shadowRadius = 2.0;
            photo.layer.cornerRadius= 28;
            photo.layer.borderColor = [[UIColor blackColor] CGColor];
            photo.layer.borderWidth = 2.0f;
            photo.userInteractionEnabled = YES;
            photo.backgroundColor = [UIColor blackColor];
            [cell addSubview:photo];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            username = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 150, 30)];
            username.backgroundColor = [UIColor clearColor];
            username.font = [UIFont systemFontOfSize:14];
            [cell addSubview:username];
            
            declaration = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 150, 40)];
            declaration.backgroundColor = [UIColor clearColor];
            declaration.font = [UIFont systemFontOfSize:12];
            [cell addSubview:declaration];
            break;
            
        }
        case 1:
        {
            if (row == 0) {
                UIButton* soundCount = [[UIButton alloc] initWithFrame:CGRectMake(280, 2, 26, 26)];
                [soundCount setBackgroundImage:[UIImage imageNamed:@"orangecircle"] forState:UIControlStateNormal];
                [soundCount setTitle:@"0" forState:UIControlStateNormal];
                [soundCount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                [cell addSubview:soundCount];
                cell.textLabel.text = @"录音记录";
            }
            else if(row == 1)
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"运动信息";
            }
            else if(row == 2)
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"好友列表";
            }
            
            break;
        }
        case 2:
        {
            if (row == 0) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"图片推送";
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int isection = indexPath.section;
    switch (isection) {
        case 0:
        {
            myMessageEditController = [[MyMessageEditViewController alloc] init];
            myMessageEditController.backName = @"个人资料";
            [self.navigationController pushViewController:myMessageEditController animated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendUserInformation" object:self.myMessageDic];
            break;
        }
        case 1:
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
            else if(indexPath.row == 2)
            {
                MyAttentionListViewController *attentionlistController = [[MyAttentionListViewController alloc] init];
                attentionlistController.backName = @"好友列表";
                attentionlistController.friendarray = friendlist;
                attentionlistController.myDic = self.myMessageDic;
                [self.navigationController pushViewController:attentionlistController animated:YES];
                
            }
            break;
        }
        case 2:
        {
            if(indexPath.row == 0)
            {
                WatchStyleViewController *watchStyleViewController = [[WatchStyleViewController alloc] init];
                watchStyleViewController.backName = @"图片推送";
                [self.navigationController pushViewController:watchStyleViewController animated:YES];
            }

            break;
        }
        default:
            break;
    }
}

-(void)downloadPhoto:(NSString*)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setHTTPMethod:@"GET"];

    //[request setValue:[self.myMessageDic objectForKey:@"Avatar"] forKey:@"avatar"];
    
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response error:&error];
    
    [self.myMessageDic setObject:result forKey:@"avatarData"];
    
    UIImage *resultImage = [UIImage imageWithData:(NSData *)result];
    [photo setImage:resultImage];
    
    //NSString* imagepath = NSHomeDirectory();
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //取得第一个Documents文件夹的路径
    NSString *imagepath = [path objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testPath = [imagepath stringByAppendingPathComponent:[self.myMessageDic objectForKey:@"Avatar"]];
    BOOL res=[fileManager createFileAtPath:testPath contents:nil attributes:nil];
    if (res)
    {
        [result writeToFile:[self.myMessageDic objectForKey:@"Avatar"] atomically:YES];
        NSLog(@"文件创建成功: %@" ,testPath);
    }
    else
        NSLog(@"文件创建失败");
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
