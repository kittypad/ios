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
#import "AppDelegate.h"


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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset , CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 45;
    tableView.scrollEnabled = NO;
    tableView.backgroundColor = [UIColor colorWithHex:@"F3F8FE"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
    cell.textLabel.textColor = [UIColor colorWithHex:@"292929"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    cell.detailTextLabel.textColor = RGB(81, 150, 221, 1);
    
//    UIButton *attentButton = [FactoryMethods buttonWWithNormalImage:@"加关注.png" hiliteImage:@"加关注.png" target:self selector:@selector(attention:)];
////    [attentButton setTitle:NSLocalizedString(@"Concern", nil) forState:UIControlStateNormal];
//    [attentButton setTitleColor:RGB(81, 150, 221, 1) forState:UIControlStateNormal];
//    attentButton.frame = CGRectChangeOrigin(attentButton.frame, 10, 30);
//    attentButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    
//    CGSize size = [NSLocalizedString(@"Concern", nil) sizeWithFont:[UIFont systemFontOfSize:12.0]];
//    attentButton.frame = CGRectMake(CGRectGetWidth(cell.frame) - CGRectGetWidth(attentButton.frame)  - 10, (CGRectGetHeight(cell.frame) - CGRectGetHeight(attentButton.frame))/2, CGRectGetWidth(attentButton.frame), CGRectGetHeight(attentButton.frame));

    
    switch (indexPath.row) {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"About", nil);
            break;
        case 1:
        {
            cell.textLabel.text = NSLocalizedString(@"Update", nil);
                AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            if (delegate.haveNewVersion)
            {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 65, 0, 60, cell.contentView.frame.size.height)];
                [btn setTitle:@"New" forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
                [btn setBackgroundColor:[UIColor clearColor]];
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn];
            }
            else
            {
                NSString *theAppVersion=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Latest", nil),theAppVersion];
            }
        }
        break;
        case 2:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"FeedBack", nil);
            break;
//        case 3:
//        {
//            cell.textLabel.text = NSLocalizedString(@"TomoonWeibo", nil);
//            [cell addSubview:attentButton];
//        }
            break;
        default:
            break;
    }
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.rowHeight - .5, CGRectGetWidth(tableView.frame) - 15, .5)];
    line.backgroundColor = [UIColor colorWithHex:@"e2e1e4"];
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
//        id delegate = [[AGViewDelegate alloc] init];
//        id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
//                                                             allowCallback:YES
//                                                             authViewStyle:SSAuthViewStyleFullScreenPopup
//                                                              viewDelegate:nil
//                                                   authManagerViewDelegate:delegate];
//        
//        //在授权页面中添加关注官方微博
//        [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
//                                        [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
//                                        SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
//                                        nil]];
//        
//        [ShareSDK followUserWithType:ShareTypeSinaWeibo
//                               field:@"ShareSDK"
//                           fieldType:SSUserFieldTypeName
//                         authOptions:authOptions
//                        viewDelegate:delegate
//                              result:^(SSResponseState state, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
//                                  NSString *msg = nil;
//                                  if (state == SSResponseStateSuccess)
//                                  {
//                                      msg = NSLocalizedString(@"Success", nil);
//                                  }
//                                  else if (state == SSResponseStateFail)
//                                  {
//                                      switch ([error errorCode])
//                                      {
//                                          case 20506:
//                                              msg = NSLocalizedString(@"HasConcern", nil);
//                                              break;
//                                              
//                                          default:
//                                              msg = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"failed", nil), error.errorDescription];
//                                              break;
//                                      }
//                                  }
//                                  
//                                  if (msg)
//                                  {
//                                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hint", nil)                                                                                          message:msg                                                                                         delegate:nil                                                                                cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                                                                otherButtonTitles:nil];
//                                      [alertView show];
//                                  }
//                              }];

    }

}

-(void)update
{
    NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", APPID];
    NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
    [[UIApplication sharedApplication] openURL:iTunesURL];
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
