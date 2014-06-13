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

@interface MyCenterManagerViewController ()
{
    MyMessageEditViewController *myMessageEditController;
    UIImageView* photo;
    UILabel* username;
    UILabel* declaration;
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
}

-(void)loginToMyCenter:(NSNotification*) notification
{
    self.userNametext = notification.object;
    [self getUserProfile:HTTPBASE_URL username:self.userNametext];
}

-(void)gobackToLogin:(NSNotification*)notification
{
    [self.backBtn setEnabled:YES];
    [self goBack];
}

-(void)updateInformation:(NSNotification*)notification
{
    NSDictionary* informationDic = notification.object;
    username.text = self.userNametext;
    declaration.text = [NSString stringWithFormat:@"%@:%@",@"宣言", [informationDic objectForKey:@"Signature"]];
    
    NSURL *portraitUrl = [NSURL URLWithString:@"http://photo.l99.com/bigger/31/1363231021567_5zu910.jpg"];
    UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
    [photo setImage:protraitImg];
    [photo setImageWithURL:[informationDic objectForKey:@"Avatar"] placeholderImage:protraitImg];
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
        return 70;
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
        myMessageEditController = [[MyMessageEditViewController alloc] init];
        myMessageEditController.backName = @"个人资料";
        [self.navigationController pushViewController:myMessageEditController animated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendUserInformation" object:self.myMessageDic];
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

//获取用户信息
-(NSURLConnection *)getUserProfile:(NSString*)url username:(NSString*) username
{
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request1 setHTTPMethod:@"POST"];
    
    NSString *uuid1 =[[NSUUID UUID] UUIDString];
    [request1 setValue:@"MP" forHTTPHeaderField:@"DEVICE_TYPE"];
    [request1 setValue:@"getUserProfile" forHTTPHeaderField:@"ACTION"];
    [request1 setValue:@"1.0" forHTTPHeaderField:@"APIVersion"];
    [request1 setValue:uuid1 forHTTPHeaderField:@"UUID"];
    [request1 setValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [request1 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:self.userNametext,@"userName", nil];
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    
    NSString *jsonString=nil;
    jsonString=[writer stringWithObject:parameters];
    [request1 setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request1 delegate:self];
    
    return connection;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    NSDictionary* allHeaderFields = [res allHeaderFields];
    NSString* resultcode = [allHeaderFields objectForKey:@"Result-Code"];
    
    if (![resultcode isEqualToString:@"0"]) {
        MBProgressHUD *hud= [[MBProgressHUD alloc] initWithView:self.view];
        hud.labelText = [[DataManager sharedManager] alertMessage:resultcode];
        hud.mode = MBProgressHUDModeText;
        [self.view addSubview:hud];
        [hud show:YES];
        [hud hide:YES afterDelay:2];
    }
}

//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSDictionary *testDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    [testDict setValue:self.userNametext forKey:@"userName"];
    
    username.text = self.userNametext;
    declaration.text = [NSString stringWithFormat:@"%@:%@",@"宣言", [testDict objectForKey:@"Signature"]];
    
    NSURL *portraitUrl = [NSURL URLWithString:@"http://photo.l99.com/bigger/31/1363231021567_5zu910.jpg"];
    UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
    [photo setImage:protraitImg];
    [photo setImageWithURL:[testDict objectForKey:@"Avatar"] placeholderImage:protraitImg];
    
    self.myMessageDic = testDict;
    
    NSLog(@"data:%@",testDict);
}
//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}
//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    MBProgressHUD *hud= [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = [error localizedDescription];
    hud.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:2];
    NSLog(@"%@",[error localizedDescription]);
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
