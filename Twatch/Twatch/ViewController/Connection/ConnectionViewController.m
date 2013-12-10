//
//  ConnectionViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "ConnectionViewController.h"
#import "ConnectionCell.h"
#import "ConnectionViewController+CentralManager.h"
#import "MBProgressHUD.h"

@interface ConnectionViewController ()



@end

static  NSString *cellId = @"connectin cell identifier";

@implementation ConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.unConnectedDevices = [[NSMutableArray alloc] init];
        
        // Start up the CBCentralManager
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        // And somewhere to store the incoming data
        _data = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect frame = CGRectChangeY(self.view.frame, self.yOffset);
    frame = CGRectChangeHeight(frame, self.height);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.yOffset, CGRectGetWidth(self.view.frame), IS_IPHONE_5 ? self.height-70-10 : self.height-170) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    [tableView registerClass:[ConnectionCell class] forCellReuseIdentifier:cellId];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scanButton.backgroundColor = RGB(116, 198, 250, 1);
    scanButton.frame = CGRectMake(9, CGRectGetMaxY(tableView.frame)+20, CGRectGetWidth(self.view.frame) - 18, 40);
    [scanButton setTitle:@"扫  描" forState:UIControlStateNormal];
    [scanButton setTitle:@"正  在  扫  描" forState:UIControlStateSelected];
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(startScan:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    
}

- (void)startScan:(UIButton *)btn
{
    NSLog(@"start scan");
    if (!btn.selected) {
        btn.backgroundColor = [UIColor grayColor];
        [self scan];
    }else{
        btn.backgroundColor = RGB(116, 198, 250, 1);
        [self stop];
    }
    
    btn.selected = !btn.selected;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"已绑定";
    }else{
        return @"可用设备";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return (NSInteger)(self.discoveredPeripheral != nil);
    }else{
        return self.unConnectedDevices.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *title = nil;
    if (indexPath.section == 0) {
        title = [NSString stringWithFormat:@"设备 %@: RSSI %@", self.discoveredPeripheral.name, self.discoveredPeripheral.RSSI];

        [(ConnectionCell *)cell setCellSelected:YES title:title];
    }
    else{
        id item = self.unConnectedDevices[indexPath.row];
        title = [NSString stringWithFormat:@"设备 %@: RSSI %@", [(CBPeripheral *)item  name], [(CBPeripheral *)item  RSSI]];
        
        [(ConnectionCell *)cell setCellSelected:NO title:title];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else{
        id item = self.unConnectedDevices[indexPath.row];
        [self.centralManager connectPeripheral:item options:nil];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [tableView reloadData];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    _centralManager.delegate = nil;
    NSLog(@"DEALLOC");
}
@end
