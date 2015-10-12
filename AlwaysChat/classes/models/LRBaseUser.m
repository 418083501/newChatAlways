//
//  LRBaseUser.m
//  AlwaysChat
//
//  Created by 鹿容 on 15/9/28.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRBaseUser.h"

@implementation LRBaseUser

-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LRBaseUser class]]) {
        return NO;
    }
    
    return ((LRBaseUser *)object).ID == self.ID;
    
}

-(void)parseDataWithDict:(NSDictionary *)dict
{
    self.ID = [dict[@"ID"] longLongValue];
    self.name = dict[@"name"];
    self.location = dict[@"location"];
    self.sex = dict[@"sex"];
    self.facePath = dict[@"facePath"];
}

@end
