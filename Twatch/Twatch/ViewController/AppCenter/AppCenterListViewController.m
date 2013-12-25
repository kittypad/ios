//
//  ListViewController.m
//  Twatch
//
//  Created by 龚涛 on 12/2/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "AppCenterListViewController.h"
#import "DataManager.h"
#import "DownloadObjectCell.h"
#import "BLEManager.h"

#define kPageNum 10

#define kLoadingCellHeight      30.0

#define kLoadingIndicatorTag    100

@interface AppCenterListViewController ()
{
    BOOL _isPageEnd;
}

- (void)_stateButtonPressed:(id)sender;

- (void)_loadMorePressed:(UIButton *)button;

- (void)_loadNetworking;

- (void)_downloadingFinishNotification:(NSNotification *)notification;

@end

@implementation AppCenterListViewController

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
    
    _type = 0;

    _page = 1;
    
    _isPageEnd = NO;
    
    _array = [[NSMutableArray alloc] init];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
    self.view.backgroundColor = [UIColor colorWithHex:@"f2f7fd"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_downloadingFinishNotification:) name:kDownloadFinishedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startNetworkingFetch
{
    if (_array.count == 0) {
        [self _loadNetworking];
    }
}

#pragma mark - Notification

- (void)_downloadingFinishNotification:(NSNotification *)notification
{
    DownloadObject *obj = notification.userInfo[@"obj"];
    NSUInteger row = [_array indexOfObject:obj];
    if (row != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Private

- (void)_stateButtonPressed:(id)sender
{
    int row = [sender tag];
    DownloadObject *obj = [_array objectAtIndex:row];
    switch ([obj.state integerValue]) {
        case kNotDownload: {
            obj.state = [NSNumber numberWithInteger:kDownloading];
            [[DataManager sharedManager] removeDownloadObject:obj];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadAppNotification object:nil userInfo:@{@"name": @"download", @"obj": obj}];
            break;
        }
        case kNotInstall: {
            [[BLEManager sharedManager] sendAppInstallCommand:obj.apkUrl];
            break;
        }
        default:
            break;
    }
}

- (void)_loadMorePressed:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_array count] inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadingIndicatorTag];
        if (indicatorView) {
            button.hidden = YES;
            indicatorView.hidden = NO;
            [indicatorView startAnimating];
            _page++;
            [[DataManager sharedManager] getDownloadList:self.type
                                                    page:self.page
                                                 success:^(NSArray *array){
                                                     button.hidden = NO;
                                                     indicatorView.hidden = YES;
                                                     [indicatorView stopAnimating];
                                                     
                                                     [_array addObjectsFromArray:array];
                                                     if (!array || array==0 || [array count]%kPageNum!=0) {
                                                         _isPageEnd = YES;
                                                     }
                                                     [self.tableView reloadData];
                                                 }
                                                 failure:^(NSError *error){
                                                     button.hidden = NO;
                                                     indicatorView.hidden = YES;
                                                     [indicatorView stopAnimating];
                                                 }];
        }
    }
}

- (void)_loadNetworking
{
    [[DataManager sharedManager] getDownloadList:self.type
                                               page:self.page
                                            success:^(NSArray *array){
                                                [_array addObjectsFromArray:array];
                                                if (!array || array==0 || [array count]%kPageNum!=0) {
                                                    _isPageEnd = YES;
                                                }
                                                [self.tableView reloadData];
                                            }
                                            failure:^(NSError *error){
                                                
                                            }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == [_array count]) {
        return 30.0;
    }
    return 51.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [_array count];
    if (count == 0) {
        return 0;
    }
    else if (!_isPageEnd) {
        return count+1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([indexPath row] == [_array count]) {
        static NSString *DefaultCellIdentifier = @"DefaultCell";
        cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, kLoadingCellHeight)];
            [button setTitle:NSLocalizedString(@"Click For More", nil) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHex:@"333333"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(_loadMorePressed:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [cell.contentView addSubview:button];
            
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicatorView.center = CGPointMake(self.tableView.bounds.size.width/2, kLoadingCellHeight/2);
            indicatorView.tag = kLoadingIndicatorTag;
            indicatorView.hidden = YES;
            [cell.contentView addSubview:indicatorView];
        }
    }
    else {
        static NSString *DownCellIdentifier = @"ListCell";
        DownloadObjectCell *downloadCell = [tableView dequeueReusableCellWithIdentifier:DownCellIdentifier];
        if (!downloadCell) {
            downloadCell = [[DownloadObjectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:DownCellIdentifier];
            downloadCell.type = _type;
            [downloadCell.stateButton addTarget:self action:@selector(_stateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        DownloadObject *obj = [_array objectAtIndex:[indexPath row]];
        
        [downloadCell configCell:obj lineHidden:NO];
        
        downloadCell.stateButton.tag = [indexPath row];
        
        cell = downloadCell;
    }
    
    return cell;
}

@end
