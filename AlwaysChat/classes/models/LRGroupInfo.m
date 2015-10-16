//
//  LRGroupInfo.m
//  AlwaysChat
//
//  Created by lurong on 15/10/16.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRGroupInfo.h"

@implementation LRGroupInfo

-(void)parseDataWithDict:(NSDictionary *)dict
{
    self.ID = dict[@"id"];
    self.name = dict[@"name"];
    self.facePath = dict[@"facePath"];
    self.destrib = dict[@"destrib"];
}

-(BOOL)isEqual:(id)object
{
    LRGroupInfo *info = (LRGroupInfo *)object;
    return [info.ID isEqualToString:self.ID];
}

@end
