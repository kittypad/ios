//
//  ShareCell.h
//  Twatch
//
//  Created by yixiaoluo on 13-11-17.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "PSTCollectionViewCell.h"

@interface ShareCell : PSTCollectionViewCell{
    UIImageView *_shareIcon;
    NSInteger   _index;
}

- (void)configCellWithInfo:(NSString *)imgName atIndex:(int)index;

@end
