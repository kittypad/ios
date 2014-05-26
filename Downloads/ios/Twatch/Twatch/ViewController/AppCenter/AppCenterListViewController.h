//
//  ListViewController.h
//  Twatch
//
//  Created by 龚涛 on 12/2/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAppCenterType          0
#define kWallPaperCenterType    1

@interface AppCenterListViewController : UITableViewController

@property (nonatomic, assign) NSUInteger page;

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, assign) CGFloat hight;

@property (nonatomic, assign) NSUInteger type;

@property (nonatomic) UIProgressView *processView;
@property (nonatomic) UILabel *processLable;
@property (nonatomic) UILabel *processPecentLable;



- (void)startNetworkingFetch;

@end
