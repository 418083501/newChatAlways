//
//  LCHttpTool.h
//  lcs
//
//  Created by 张鹏 on 15/3/13.
//  Copyright (c) 2015年 张鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCHttpTool : NSObject

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure;

@end
