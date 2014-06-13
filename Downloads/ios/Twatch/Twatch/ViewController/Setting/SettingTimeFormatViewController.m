//
//  SettingTimeFormatViewController.m
//  Twatch
//
//  Created by yugong on 14-6-9.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SettingTimeFormatViewController.h"

@interface SettingTimeFormatViewController ()

@property (nonatomic)NSString* currentDateFormat;
@property (nonatomic, strong)NSArray* timeFormatList;

@end

@implementation SettingTimeFormatViewController

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
    
    //写死的休眠时间，需要给改为获取或者。。。
    self.timeFormatList = [NSArray arrayWithObjects:@"dd-MM-yyyy", @"MM-dd-yyyy" , @"yyyy-MM-dd",nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 30;
    //tableView.scrollEnabled = YES;
    //tableView.tableHeaderView = [self tableHeaderView];
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    tableView.separatorColor = [UIColor clearColor];
    
    [self.view addSubview:tableView];
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, 320, 30)];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelsetbtn"] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor redColor]];
    [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
}

-(void)cancelClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setcancel" object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeFormatList count]+1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"设置日期格式";
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
    
    if (indexPath.row == 0) {
        
    }
    else
    {
        cell.textLabel.text = [self.timeFormatList objectAtIndex:indexPath.row-1];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {
        NSString* selectTimeFormat = [self.timeFormatList objectAtIndex:indexPath.row-1];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"settimeformat" object:selectTimeFormat];
    }
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
