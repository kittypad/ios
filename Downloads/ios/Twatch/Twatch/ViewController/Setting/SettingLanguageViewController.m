//
//  SettingLanguageViewController.m
//  Twatch
//
//  Created by yugong on 14-6-6.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "SettingLanguageViewController.h"

@interface SettingLanguageViewController ()

@property (nonatomic ,strong)NSArray* languageList;
@property (nonatomic)NSString* language;

@end

@implementation SettingLanguageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.frame = CGRectMake(0, 0, 320, 150);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //写死的休眠时间，需要给改为获取或者。。。
    self.languageList = [NSArray arrayWithObjects:@"中文简体", @"中文繁体" , @"英文",nil];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 30;
    //tableView.scrollEnabled = YES;
    //tableView.tableHeaderView = [self tableHeaderView];
    tableView.backgroundColor = [UIColor colorWithHex:@"F2F7FD"];
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 110, 140, 30)];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancelsetbtn"] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor redColor]];
    [cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    UIButton* setLanguageBtn = [[UIButton alloc] initWithFrame:CGRectMake(170, 110, 140, 30)];
    [setLanguageBtn setBackgroundImage:[UIImage imageNamed:@"setbtn"] forState:UIControlStateNormal];
    [setLanguageBtn setBackgroundColor:[UIColor redColor]];
    [setLanguageBtn setTitle:@"设置" forState:UIControlStateNormal];
    [setLanguageBtn addTarget:self action:@selector(setLanguageClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    [self.view addSubview:setLanguageBtn];
}

-(void)cancelClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setcancel" object:nil];
}

-(void)setLanguageClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setlanguage" object:self.language];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.languageList count];
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
    
    cell.textLabel.text = [self.languageList objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.language = [self.languageList objectAtIndex:indexPath.row];
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
