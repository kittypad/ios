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

- (void)_stateButtonPressed:(id)sender;

- (void)_downloadApp:(NSNotification *)notification;

- (void)_downloadingProcessNotification:(NSNotification *)notification;

- (void)_downloadingFinishNotification:(NSNotification *)notification;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_downloadingProcessNotification:) name:kDownloadingProcessNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_downloadingFinishNotification:) name:kDownloadFinishedNotification object:nil];
    
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

#pragma mark - Notification

- (void)_downloadingProcessNotification:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    DownloadObject *obj = dic[@"obj"];
    NSUInteger row = [_downloadingArray indexOfObject:obj];
    if (row != NSNotFound) {
        CGFloat readFileBytes = [dic[@"readFileBytes"] floatValue];
        CGFloat totalFileBytes = [dic[@"totalFileBytes"] floatValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        DownloadObjectCell *cell = (DownloadObjectCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.progressBar.progress = readFileBytes/totalFileBytes;
        [cell setReadBytes:readFileBytes totalBytes:totalFileBytes];
    }
}

- (void)_downloadingFinishNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)_stateButtonPressed:(id)sender
{
    int row = [sender tag];
    DownloadObject *obj = [_downloadedArray objectAtIndex:row];
    switch ([obj.state integerValue]) {
        case kNotInstall: {
            obj.state = [NSNumber numberWithInteger:kInstalled];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadFinishedNotification object:nil userInfo:@{@"obj": obj}];
            break;
        }
        default:
            break;
    }
}

- (void)_downloadApp:(NSNotification *)notification
{
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
        headerView.backgroundColor = [UIColor colorWithHex:@"f4f9ff"];
        
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
        DownloadObject *obj = [_downloadingArray objectAtIndex:[indexPath row]];
        
        static NSString *DefaultCellIdentifier = @"DownloadingCell";
        DownloadObjectCell *downloadCell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
        if (!downloadCell) {
            downloadCell = [[DownloadObjectCell alloc] initDownlodingWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DefaultCellIdentifier];
        }
        
        [downloadCell configCell:obj];
        
        NSString *fileName = [[NSURL URLWithString:obj.apkUrl] lastPathComponent];
        NSString *path = [NSString pathWithComponents:[NSArray arrayWithObjects:[AFDownloadRequestOperation cacheFolder], fileName, nil]];
        [downloadCell setReadBytes:[obj fileSizeAtPath:path] totalBytes:[obj.size floatValue]];
        
        cell = downloadCell;
    }
    else if (1 == [indexPath section]) {
        
        static NSString *DownCellIdentifier = @"DownloadedCell";
        DownloadObjectCell *downloadCell = [tableView dequeueReusableCellWithIdentifier:DownCellIdentifier];
        if (!downloadCell) {
            downloadCell = [[DownloadObjectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DownCellIdentifier];
            [downloadCell.stateButton addTarget:self action:@selector(_stateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        DownloadObject *obj = [_downloadedArray objectAtIndex:[indexPath row]];
        
        [downloadCell configCell:obj];
        
        downloadCell.stateButton.tag = [indexPath row];
        
        cell = downloadCell;
    }
    
    return cell;
}

@end
