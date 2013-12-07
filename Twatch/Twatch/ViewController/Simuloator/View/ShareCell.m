//
//  ShareCell.m
//  Twatch
//
//  Created by yixiaoluo on 13-11-17.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ShareCell.h"
#import "ViewUtils.h"

@implementation ShareCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        self.layer.cornerRadius = 3;
        
        // Initialization code
        _shareIcon = [[UIImageView alloc] init];
        [self addSubview:_shareIcon];
    }
    return self;
}

- (void)configCellWithInfo:(NSString *)imgName atIndex:(int)index
{
    _index = index;
    
    UIImage *img = [UIImage imageNamed:imgName];
    _shareIcon.image = img;
    _shareIcon.bounds = CGRectMake(0, 0, img.size.width, img.size.height);
    _shareIcon.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2) ;
    
    [self setSelected:NO];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [self setSelected:highlighted];
}

- (void)setSelected:(BOOL)selected
{
    switch (_index) {
        case 0:
            self.backgroundColor =  [UIColor colorWithHex:(selected ? @"00c0ff" : @"00a9e1")];
            break;
        case 1:
            self.backgroundColor =  [UIColor colorWithHex:(selected ? @"00c566" : @"00a254")];

            break;
        case 2:
            self.backgroundColor =  [UIColor colorWithHex:(selected ? @"1672bf" : @"05589e")];

            break;
        case 3:
            self.backgroundColor =  [UIColor colorWithHex:(selected ? @"ec2a45" : @"d21832")];

            break;
        case 4:
            self.backgroundColor =  [UIColor colorWithHex:(selected ? @"249d8c" : @"14897a")];

            break;
   
        default:
            break;
    }
    
}
@end
