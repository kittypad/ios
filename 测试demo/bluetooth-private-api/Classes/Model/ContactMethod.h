//
//  PublicMethod.h
//  yuyin
//
//  Created by jizeng wang on 13-3-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegexKitLite.h"
@interface ContactMethod : NSObject

//根据号码查询通讯录联系人姓名
+ (NSString*) getContactName:(NSString *)contactNumber;

//根据联系人姓名查找通讯录中的号码
+ (NSString*) getContactNumber:(NSString *)contactName;
@end
