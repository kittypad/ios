//
//  SettingSleepTimeViewController.m
//  Twatch
//
//  Created by yugong on 14-6-4.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SettingSleepTimeViewController.h"
#import "BLEServerManager.h"

#import "UIViewController+KNSemiModal.h"

@interface SettingSleepTimeViewController ()

@property (nonatomic ,strong)NSArray* sleepTimeList;

@property (nonatomic)NSString* sleepTime;

@end

@implementation SettingSleepTimeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.frame = CGRectMake(0, 0, 320, 200);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor whiteColor];
    
    //写死的休眠时间，需要给改为获取或者。。。
    self.sleepTimeList = [NSArray arrayWithObjects:@"15", @"30" , @"60", @"120", @"300",nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 30;
    //tableView.scrollEnabled = YES;
    //tableView.tableHeaderView = [self tableHeaderView];
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 160, 140, 30)];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelsetbtn"] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor redColor]];
    [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    UIButton* setBtn = [[UIButton alloc] initWithFrame:CGRectMake(170, 160, 140, 30)];
    [setBtn setBackgroundImage:[UIImage imageNamed:@"setbtn"] forState:UIControlStateNormal];
    [setBtn setBackgroundColor:[UIColor redColor]];
    [setBtn setTitle:@"设置" forState:UIControlStateNormal];
    [setBtn addTarget:self action:@selector(setClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    [self.view addSubview:setBtn];
}

-(void)cancelClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setcancel" object:nil];
}

-(void)setClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setsleeptime" object:self.sleepTime];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sleepTimeList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ModalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    //选中后的字体颜色设置
    cell.textLabel.highlightedTextColor = [UIColor redColor];
    
    NSString* time = [self.sleepTimeList objectAtIndex:indexPath.row];
    NSString* strsleep = nil;
    int itime = [time intValue];
    if (itime>59)
    {
        itime = itime/60;
        strsleep = [NSString stringWithFormat:@"%d分钟",itime];
    }
    else
    {
        strsleep = [NSString stringWithFormat:@"%d秒",itime];
    }
    
    cell.textLabel.text = strsleep;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* time = [self.sleepTimeList objectAtIndex:indexPath.row];
    int itime = [time intValue];
    itime *= 1000;
    self.sleepTime = [NSString stringWithFormat:@"%d", itime];
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
