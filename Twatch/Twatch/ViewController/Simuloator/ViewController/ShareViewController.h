//
//  ShareViewController.h
//  Twatch
//
//  Created by yixiaoluo on 13-11-17.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "NaviCommonViewController.h"
#import <ShareSDK/ShareSDK.h>

@interface ShareViewController : NaviCommonViewController<PSTCollectionViewDataSource,PSTCollectionViewDelegate>

/**
 *	@brief	创建分享内容对象，根据以下每个字段适用平台说明来填充参数值
 *
 *	@param 	content 	分享内容（新浪、腾讯、网易、搜狐、豆瓣、人人、开心、有道云笔记、facebook、twitter、邮件、打印、短信、微信、QQ、拷贝）
 *	@param 	defaultContent 	默认分享内容（新浪、腾讯、网易、搜狐、豆瓣、人人、开心、有道云笔记、facebook、twitter、邮件、打印、短信、微信、QQ、拷贝）
 *	@param 	image 	分享图片（新浪、腾讯、网易、搜狐、豆瓣、人人、开心、facebook、twitter、邮件、打印、微信、QQ、拷贝）
 *	@param 	title 	标题（QQ空间、人人、微信、QQ）
 *	@param 	url 	链接（QQ空间、人人、instapaper、微信、QQ）
 *	@param 	description 	主体内容（人人）
 *	@param 	mediaType 	分享类型（QQ、微信）
 *
 *	@return	分享内容对象
 */
- (id)initWithContent:(NSString *)content
       defaultContent:(NSString *)defaultContent
                image:(id<ISSCAttachment>)image
                title:(NSString *)title
                  url:(NSString *)url
          description:(NSString *)description
            mediaType:(SSPublishContentMediaType)mediaType;

@end
