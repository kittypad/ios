//
//  DownloadManagerViewController.m
//  Twatch
//
//  Created by 龚涛 on 12/5/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "DownloadManagerViewController.h"
#import "DataManager.h"
#import "DownloadObjectCell.h"

#define kHeaderHight    22.0

@interface DownloadManagerViewController ()
{
    NSMutableArray *_downloadingArray;
    NSMutableArray *_downloadedArray;
}

- (void)_downloadApp:(NSNotification *)notification;

@end

@implementation DownloadManagerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableDictionary *dic = [DataManager sharedManager].downloadDic;
    
    _downloadingArray = dic[AppDownloadingArray];
    _downloadedArray = dic[AppDownloadedArray];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
    self.tableView.backgroundColor = [UIColor colorWithHex:@"f4f9ff"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_downloadApp:) name:kDownloadAppNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)_downloadApp:(NSNotification *)notification
{
    NSLog(@"notice");
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo[@"name"] isEqualToString:@"download"]) {
        [[DataManager sharedManager] addDownloadObject:notification.userInfo[@"obj"]];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderIdentifier = @"HeaderView";
    UIView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
    if (!headerView) {
        headerView = [[UIView alloc] init];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 200.0, kHeaderHight)];
        label.textColor = [UIColor colorWithHex:@"8da8bf"];
        label.tag = 100;
        label.font = [UIFont systemFontOfSize:10.0];
        [headerView addSubview:label];
    }
    
    UILabel *label = (UILabel *)[headerView viewWithTag:100];
    
    if (0 == section) {
        label.text = NSLocalizedString(@"Downloading", nil);
    }
    else if (1 == section) {
        label.text = NSLocalizedString(@"Downloaded", nil);
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section && 0 != [_downloadingArray count]) {
        return kHeaderHight;
    }
    else if (1 == section && 0 != [_downloadedArray count]) {
        return kHeaderHight;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return [_downloadingArray count];
    }
    else if (1 == section) {
        return [_downloadedArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (0 == [indexPath section]) {
        static NSString *DefaultCellIdentifier = @"DownloadingCell";
        DownloadObjectCell *downloadCell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
        if (!downloadCell) {
            downloadCell = [[DownloadObjectCell alloc] initDownlodingWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DefaultCellIdentifier];
        }
        
        DownloadObject *obj = [_downloadingArray objectAtIndex:[indexPath row]];
        
        [downloadCell configCell:obj];
        
        cell = downloadCell;
    }
    else if (1 == [indexPath section]) {
        
        static NSString *DownCellIdentifier = @"DownloadedCell";
        DownloadObjectCell *downloadCell = [tableView dequeueReusableCellWithIdentifier:DownCellIdentifier];
        if (!downloadCell) {
            downloadCell = [[DownloadObjectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DownCellIdentifier];
        }
        
        DownloadObject *obj = [_downloadedArray objectAtIndex:[indexPath row]];
        
        [downloadCell configCell:obj];
        
        cell = downloadCell;
    }
    
    return cell;
}

@end
