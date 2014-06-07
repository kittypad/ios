

//
//  ShoppingTableViewController.m
//  Twatch
//
//  Created by yugong on 14-5-23.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "ShoppingTableViewController.h"
#import "DataManager.h"
#import "ShoppingViewCell.h"
#import "ShoppingViewController.h"

@interface ShoppingTableViewController ()

@property (nonatomic, strong)UITableView* shopTableView;
@property (nonatomic, strong)NSMutableArray* shoppingArray;

@end

@implementation ShoppingTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //glc 2014-5-22 添加tabbar
        UITabBarItem *item = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"Mall", @"商城") image:[UIImage imageNamed:@"tabshopping"] tag:1];
        self.tabBarItem = item;
        self.backName = NSLocalizedString(@"Tomoon Mall", @"土曼商城");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.shoppingArray = [[NSMutableArray alloc] init];
    
    _shopTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, IS_IOS7?64:44, 320, 366)];
    _shopTableView.delegate = self;
    _shopTableView.dataSource = self;
    _shopTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.shopTableView registerClass:[ShoppingViewCell class] forCellReuseIdentifier:@"CustomCell"];
    [self.view addSubview:_shopTableView];
    
    NSString* strURL = @"http://r.tomoon.cn/item/";
    _shoppingArray = [[DataManager sharedManager] getShoppingList:strURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_shoppingArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_shoppingArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 185;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    // Configure the cell...
    NSMutableDictionary* dicShop = [_shoppingArray objectAtIndex:indexPath.row];
    NSURL *imageUrl = [NSURL URLWithString:[dicShop objectForKey:@"img"]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    UIImageView* shopImage = [[UIImageView alloc] initWithImage:image];
    [shopImage setFrame:CGRectMake(5,5 , 310, 180)];
    [cell.contentView addSubview:shopImage];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

//选中某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* dicShop = [_shoppingArray objectAtIndex:indexPath.row];
    ShoppingViewController* shopDetail = [[ShoppingViewController alloc] init];

    
<<<<<<< HEAD
    [self.navigationController pushViewController:shopDetail animated:YES];
     //[self presentViewController:shopDetail animated:YES completion:nil];
=======
    //[self.navigationController pushViewController:shopDetail animated:YES];
     [self presentViewController:shopDetail animated:YES completion:nil];
>>>>>>> 2a3c53f1caca6d3a32ec8e4e28b41b03dd897cf8
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shopdetail" object:dicShop];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
