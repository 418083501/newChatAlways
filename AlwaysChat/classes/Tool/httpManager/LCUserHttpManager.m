//
//  LCUserHttpManager.m
//  lcs
//
//  Created by lurong on 15/3/16.
//  Copyright (c) 2015年 张鹏. All rights reserved.
//

#import "LCUserHttpManager.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "AFNetworking.h"
#import "LRLoginUser.h"

@implementation LCUserHttpManager

+(instancetype)instance
{
    static LCUserHttpManager *manager;
    if (!manager) {
        manager = [[LCUserHttpManager alloc] init];
    }
    return manager;
}

-(BOOL)parseIsDoneWithId:(id)responseObj
{
    
    if (![responseObj isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    NSDictionary *dict = (NSDictionary *)responseObj;
    if ([dict.allKeys containsObject:@"result"]) {
        if ([dict[@"result"] isEqualToString:@"token failure"]) {
            
//            DISSMISS_ERR(@"您的账号再其他地方登录");
            
//            [LC_LOGINUSER logout];
            
            return NO;
        }
    }
    
    if ([dict.allKeys containsObject:@"code"]) {
        if ([dict[@"code"] intValue] == 1) {
            return YES;
        }
    }
    
    return NO;
}

-(void)loginWithUsername:(NSString *)username vCode:(NSString *)vcode callBack:(NetBOOLCallBackBlock)callBck
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_NAME,@"Login"];
    
    NSMutableDictionary *paramas = [NSMutableDictionary dictionary];
    paramas[@"username"] = username;
    paramas[@"vcode"] = vcode;
    
    
    [LCHttpTool get:url params:paramas success:^(id responseObj) {
        
        NSDictionary *dict = responseObj;
        
        if ([self parseIsDoneWithId:dict]) {
            
            [LOGIN_USER parseDataWithDict:dict[@"user"]];
            
            callBck(YES,@"");
        }else
        {
            callBck(NO,dict[@"result"]);
        }
        
    } failure:^(NSError *error) {
        callBck(NO,@"链接失败");
    }];
}


-(void)getUserInfoWithCallBack:(NetBOOLCallBackBlock)callBack
{
    //GetUserInfo
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_NAME,@"GetUserInfo"];
    
    NSMutableDictionary *paramas = [NSMutableDictionary dictionary];
    paramas[@"ID"] = @(LOGIN_USER.ID);
    paramas[@"token"] = LOGIN_USER.token;
    
    
    [LCHttpTool get:url params:paramas success:^(id responseObj) {
        
        NSDictionary *dict = responseObj;
        
        if ([self parseIsDoneWithId:dict]) {
            
            [LOGIN_USER parseDataWithDict:dict[@"user"]];
            
            callBack(YES,@"");
        }else
        {
            callBack(NO,dict[@"result"]);
        }
        
    } failure:^(NSError *error) {
        callBack(NO,@"链接失败");
    }];
    
}


@end
