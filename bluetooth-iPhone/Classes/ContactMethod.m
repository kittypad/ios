//
//  PublicMethod.m
//  yuyin
//
//  Created by jizeng wang on 13-3-4.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ContactMethod.h"
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@implementation ContactMethod

//根据号码查询通讯录联系人姓名
+ (NSString*) getContactName:(NSString *)contactNumber
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *peopleArray = (NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for (id people in peopleArray)
    {
        ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(people, kABPersonPhoneProperty);
        int nCount = ABMultiValueGetCount(phones);
        for(int i = 0 ;i < nCount;i++)
        {
            NSString *phoneNum = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            NSString *tmp = nil;
            if (phoneNum) 
            {
                contactNumber = [contactNumber stringByReplacingOccurrencesOfRegex:@"[+\()-]" withString:@""];
                tmp = [phoneNum stringByReplacingOccurrencesOfRegex:@"[+\()-]" withString:@""];
                NSString *tmp2 = [NSString stringWithFormat:@"86%@",tmp];
                if ([contactNumber isEqualToString:tmp] ||[contactNumber isEqualToString:tmp2]) 
                {
                    NSString *phoneName = (NSString *)ABRecordCopyCompositeName(people);
                    return phoneName;
                }
            }
        }
    }
    return nil;
}

//根据联系人姓名查找通讯录中的号码
+ (NSString*) getContactNumber:(NSString *)contactName
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    NSArray *peopleArray = (NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for (id people in peopleArray)
    {
        NSString *phoneName = (NSString *)ABRecordCopyCompositeName(people);
        phoneName = [phoneName stringByReplacingOccurrencesOfRegex:@" " withString:@""];
        if ([phoneName isEqualToString:contactName])
        {
            ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(people, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(phones))
            {
                NSString *phoneNum = (NSString *)ABMultiValueCopyValueAtIndex(phones, 0);
                return phoneNum;
            }
        }

    }
    return nil;
}
@end
