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
            
            [LOGIN_USER logout];
            
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
    if (![LCCommon checkIsEmptyString:LOGIN_USER.token]) {
        paramas[@"token"] = LOGIN_USER.token;
    }
    
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

-(void)getBaseUsersWithIds:(NSArray *)ids callBack:(NetObjLCallBackBlock)callBack
{
    //GetBasicUser
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_NAME,@"GetBasicUser"];
    
    NSMutableDictionary *paramas = [NSMutableDictionary dictionary];
    paramas[@"uid"] = @(LOGIN_USER.ID);
    if (![LCCommon checkIsEmptyString:LOGIN_USER.token]) {
        paramas[@"token"] = LOGIN_USER.token;
    }
    NSString *idStr = @"";
    for (int i = 0; i<ids.count; i++) {
        idStr = [idStr stringByAppendingFormat:@"%@",ids[i]];
        if (i != ids.count - 1) {
            idStr = [idStr stringByAppendingString:@","];
        }
    }
    paramas[@"ids"] = idStr;
    
    [LCHttpTool post:url params:paramas success:^(id responseObj) {
        NSDictionary *dict = responseObj;
        
        if ([self parseIsDoneWithId:dict]) {
            
            NSMutableArray *result = [NSMutableArray array];
            
            NSArray *data = dict[@"data"];
            for (int i = 0; i<data.count; i++) {
                NSDictionary *dict = data[i];
                LRBaseUser *user = [[LRBaseUser alloc] init];
                [user parseDataWithDict:dict];
                [result addObject:user];
                user = nil;
            }
            
            if (!LOGIN_USER.personArray) {
                LOGIN_USER.personArray = [NSMutableArray array];
                [LOGIN_USER.personArray removeObjectsInArray:result];
                [LOGIN_USER.personArray addObjectsFromArray:result];
            }
            
            callBack(YES,result);
        }else
        {
            callBack(NO,dict[@"result"]);
        }
    } failure:^(NSError *error) {
        callBack(NO,@"链接失败");
    }];
    
}

-(void)logout
{
    //Logout
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_NAME,@"Logout"];
    
    NSMutableDictionary *paramas = [NSMutableDictionary dictionary];
    paramas[@"uid"] = @(LOGIN_USER.ID);
    if (![LCCommon checkIsEmptyString:LOGIN_USER.token]) {
        paramas[@"token"] = LOGIN_USER.token;
    }
    
    [LCHttpTool get:url params:paramas success:^(id responseObj) {
        if ([self parseIsDoneWithId:responseObj]) {
//            NSDictionary *dict = responseObj;
            
        }
    } failure:^(NSError *error) {
        
    }];
    
}


@end
