//
//  ImageLabelView.m
//  Twatch
//
//  Created by yugong on 14-6-3.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "ImageLabelView.h"

@implementation ImageLabelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame lblcolor:(UIColor *)lblcolor iamge:(UIImage *)iamge labeltext:(NSString *)labeltext
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *imageview = [[UIImageView alloc]init];
        [imageview setImage:iamge];
        imageview.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,self.frame.size.height-_labelheight);
        imageview.contentMode = UIViewContentModeScaleToFill;
        //        [_imageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"领取图标.png"]]];
        //文字描述打折信息
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.size.height-_labelheight, self.self.frame.size.width,_labelheight)];
        label.text = labeltext;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.backgroundColor = lblcolor;
        [self addSubview:imageview];
        [self addSubview:label];
    }

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
