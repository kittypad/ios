//
//  MyFriendDetailViewController.m
//  Twatch
//
//  Created by yugong on 14-7-2.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "MyFriendDetailViewController.h"

@interface MyFriendDetailViewController ()
{
    UIButton* friendBtn;
}

@end

@implementation MyFriendDetailViewController

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
    
    UIImageView* photoImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 64, 80, 80)];
    photoImage.backgroundColor = [UIColor redColor];
    [self.view addSubview:photoImage];
    
    UIImageView* sexImage = [[UIImageView alloc] initWithFrame:CGRectMake(100, 84, 40, 40)];
    sexImage.backgroundColor = [UIColor greenColor];
    [self.view addSubview:sexImage];
    
    UILabel* phoneNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 154, 80, 40)];
    phoneNumLabel.text = @"电话";
    [self.view addSubview:phoneNumLabel];
    
    UILabel* phoneNumtext = [[UILabel alloc] initWithFrame:CGRectMake(100, 154, 200, 40)];
    phoneNumtext.text = [self.frienddic objectForKey:@"focusUserName"];
    [self.view addSubview:phoneNumtext];
    
    UILabel* introductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 80, 40)];
    introductionLabel.text = @"简介";
    [self.view addSubview:introductionLabel];
    
    UILabel* introductionText = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, 200, 40)];
    introductionText.text = [self.frienddic objectForKey:@"verifyMsg"];
    [self.view addSubview:introductionText];
    
    friendBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 250, 300, 40)];
    friendBtn.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:friendBtn];
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
