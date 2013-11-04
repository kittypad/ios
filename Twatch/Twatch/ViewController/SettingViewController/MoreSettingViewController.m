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
#import <ShareSDK/ShareSDK.h>
#import "AGViewDelegate.h"

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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IS_IOS7 ? 64 : 44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
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
    return 4;
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
    cell.detailTextLabel.textColor = RGB(81, 150, 221, 1);
    
    UIButton *attentButton = [FactoryMethods buttonWWithNormalImage:@"加关注.png" hiliteImage:@"加关注.png" target:self selector:@selector(attention:)];
    [attentButton setTitle:NSLocalizedString(@"Concern", nil) forState:UIControlStateNormal];
    [attentButton setTitleColor:RGB(81, 150, 221, 1) forState:UIControlStateNormal];
    attentButton.frame = CGRectChangeOrigin(attentButton.frame, 10, 30);
    attentButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    
    CGSize size = [NSLocalizedString(@"Concern", nil) sizeWithFont:[UIFont systemFontOfSize:12.0]];
    attentButton.frame = CGRectMake(CGRectGetWidth(cell.frame) - CGRectGetWidth(attentButton.frame) - size.width - 10, (CGRectGetHeight(cell.frame) - CGRectGetHeight(attentButton.frame))/2, CGRectGetWidth(attentButton.frame) + size.width, CGRectGetHeight(attentButton.frame));

    
    switch (indexPath.row) {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"About", nil);
            break;
        case 1:
        {
            cell.textLabel.text = NSLocalizedString(@"Accounts", nil);
             NSString *theAppVersion=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Latest", nil),theAppVersion];
        }
        break;
        case 2:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"FeedBack", nil);
            break;
        case 3:
        {
            cell.textLabel.text = NSLocalizedString(@"TomoonWeibo", nil);
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
        about.backName = NSLocalizedString(@"About", nil);
        [self.navigationController pushViewController:about animated:YES];
    }
    else if(indexPath.row == 2)
    {
        FeedBackViewController *feedback = [[FeedBackViewController alloc] init];
        feedback.backName = NSLocalizedString(@"FeedBack", nil);
        [self.navigationController pushViewController:feedback animated:YES];
    }else if (indexPath.row == 3){
        id delegate = [[AGViewDelegate alloc] init];
        id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                             allowCallback:YES
                                                             authViewStyle:SSAuthViewStyleFullScreenPopup
                                                              viewDelegate:nil
                                                   authManagerViewDelegate:delegate];
        
        //在授权页面中添加关注官方微博
        [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                        SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                        nil]];
        
        [ShareSDK followUserWithType:ShareTypeSinaWeibo
                               field:@"ShareSDK"
                           fieldType:SSUserFieldTypeName
                         authOptions:authOptions
                        viewDelegate:delegate
                              result:^(SSResponseState state, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                                  NSString *msg = nil;
                                  if (state == SSResponseStateSuccess)
                                  {
                                      msg = @"关注成功";
                                  }
                                  else if (state == SSResponseStateFail)
                                  {
                                      switch ([error errorCode])
                                      {
                                          case 20506:
                                              msg = @"已关注";
                                              break;
                                              
                                          default:
                                              msg = [NSString stringWithFormat:@"关注失败:%@", error.errorDescription];
                                              break;
                                      }
                                  }
                                  
                                  if (msg)
                                  {
                                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                          message:msg
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"知道了"
                                                                                otherButtonTitles:nil];
                                      [alertView show];
                                  }
                              }];

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
