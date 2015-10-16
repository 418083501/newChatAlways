//
//  LRGroupInfo.h
//  AlwaysChat
//
//  Created by lurong on 15/10/16.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LRGroupInfo : NSObject

@property (nonatomic,copy)NSString *ID;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *destrib;
@property (nonatomic,copy)NSString *facePath;

-(void)parseDataWithDict:(NSDictionary *)dict;

@end
