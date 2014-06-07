//
//  SettingMoreViewController.m
//  Twatch
//
//  Created by yugong on 14-5-29.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SettingMoreViewController.h"
#import "FeedBackViewController.h"
#import "ShareViewController.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "FeedBackViewController.h"
#import "SettingLanguageViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "BLEServerManager.h"

@interface SettingMoreViewController ()

@property (nonatomic ,strong)NSArray* setMoreList;

@property (nonatomic,strong)NSArray *moreControllerArray;

@property (nonatomic ,strong)NSArray* setMore;

@property (nonatomic, strong)SettingLanguageViewController* languageController;
@end

@implementation SettingMoreViewController
{
    UILabel* languageLabel;
}

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
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset
                                                                           , CGRectGetWidth(self.view.frame), self.height-50) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 50;
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    //tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    self.setMoreList = [NSArray arrayWithObjects:@"语言设置",
                        @"信息推送",
                        @"二维码",
                        NSLocalizedString(@"Update", nil),
                        NSLocalizedString(@"FeedBack", nil),
                        NSLocalizedString(@"About", nil),
                        nil];
    
    self.moreControllerArray = [NSArray arrayWithObjects:@"QRCodeManagerViewController",
                                   @"AGAuthViewController",
                                   @"QRCodeManagerViewController",
                                   nil];
    
    self.languageController = [[SettingLanguageViewController alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLanguage:) name:@"setlanguage" object:nil];
    
}

-(void)setLanguage:(NSNotification *)lannotification
{
    NSString* language = lannotification.object;
    [[BLEServerManager sharedManager] sendWatchLanguage:language finish:^(void){
        languageLabel.text = language;
        [ViewUtils showToast:@"设置语言成功"];
    }];
    [self dismissSemiModalView];
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
    else if(section == 3)
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
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    switch (section) {
        case 0:
        {
            languageLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 10, 71, 31)];
            languageLabel.text = @"中文简体";
            languageLabel.textColor = [UIColor blueColor];
            languageLabel.font = [UIFont systemFontOfSize:10.0];
            [cell addSubview:languageLabel];
            cell.textLabel.text = [self.setMoreList objectAtIndex:indexPath.row];
            break;

        }
        case 1:
            cell.textLabel.text = [self.setMoreList objectAtIndex:indexPath.row+1];
            break;
        case 2:
            if (indexPath.row ==0 ) {
                cell.textLabel.text = [self.setMoreList objectAtIndex:indexPath.row+3];
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
            else
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = NSLocalizedString(@"FeedBack", nil);
            }
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"About", nil);
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* className = [self.moreControllerArray objectAtIndex:indexPath.row+1];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


    if (indexPath.section==1) {
        UIViewController *aController = [[NSClassFromString(className) alloc] initWithNibName:nil bundle:nil];
        ((NaviCommonViewController*)aController).backName = self.setMoreList[indexPath.row+1];
        [self.navigationController pushViewController:aController animated:YES];
    }
    else if(indexPath.section == 2)
    {
        if (indexPath .row == 0) {
            
        }
        else if(indexPath.row == 1)
        {
            FeedBackViewController *feedback = [[FeedBackViewController alloc] init];
            feedback.backName = NSLocalizedString(@"FeedBack", nil);
            [self.navigationController pushViewController:feedback animated:YES];
        }
    }
    else if(indexPath.section == 3)
    {
        AboutViewController *about = [[AboutViewController alloc] init];
        about.backName = NSLocalizedString(@"About", nil);
        [self.navigationController pushViewController:about animated:YES];
    }
    else if(indexPath.section == 0)
    {
        [self presentSemiViewController:self.languageController];
    }
}

-(void)update
{
    NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", APPID];
    NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
    [[UIApplication sharedApplication] openURL:iTunesURL];
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
