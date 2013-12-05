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
#import <SDWebImage/UIImageView+WebCache.h>

@interface AppCenterListViewController ()

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

    _page = 0;
    
    _array = [[NSMutableArray alloc] init];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAllowsSelection:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startNetworkingFetch
{
    if (_array.count == 0) {
        [self loadNetworking];
    }
}

- (void)loadNetworking
{
    [[DataManager sharedManager] getDownloadList:self.type
                                               page:self.page
                                            success:^(NSArray *array){
                                                [_array addObjectsFromArray:array];
                                                [self.tableView reloadData];
                                            }
                                            failure:^(NSError *error){
                                                
                                            }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";
    DownloadObjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[DownloadObjectCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    DownloadObject *obj = [_array objectAtIndex:[indexPath row]];
    [cell.iconView setImageWithURL:[NSURL URLWithString:obj.iconUrl]];
    
    cell.textLabel.text = obj.name;
    
    cell.detailTextLabel.text = obj.intro;
    
    if ([indexPath row] == _array.count-1) {
        cell.lineView.hidden = YES;
    }
    else {
        cell.lineView.hidden = NO;
    }
    
    return cell;
}

@end
