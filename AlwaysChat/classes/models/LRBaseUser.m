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

@end
