//
//  ListViewController.h
//  Twatch
//
//  Created by 龚涛 on 12/2/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController

@property (nonatomic, assign) NSUInteger page;

@property (nonatomic, strong) NSMutableArray *array;

- (void)startNetworkingFetch;

@end
