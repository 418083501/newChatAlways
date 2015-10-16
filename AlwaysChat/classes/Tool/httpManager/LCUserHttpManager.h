//
//  LCUserHttpManager.h
//  lcs
//
//  Created by lurong on 15/3/16.
//  Copyright (c) 2015年 张鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCHttpTool.h"

typedef void (^NetBOOLCallBackBlock)(BOOL rs,__weak NSString * msg);
typedef void (^NetObjLCallBackBlock)(BOOL rs,__weak NSObject * obj);
typedef void (^NetObjsLCallBackBlock)(BOOL rs,__weak NSObject * obj1,__weak NSObject * obj2);
typedef void (^NetIntCallBackBlock)(NSInteger code,__weak NSString * msg);
typedef void (^NetProgressCallBackBlock)(double pro);


#define LC_USER_MANAGER [LCUserHttpManager instance]
#import "httpHeader.h"

@interface LCUserHttpManager : NSObject

+(instancetype)instance;

-(void)loginWithUsername:(NSString *)username vCode:(NSString *)vcode callBack:(NetBOOLCallBackBlock)callBck;

-(void)getUserInfoWithCallBack:(NetBOOLCallBackBlock)callBack;

-(void)getBaseUsersWithIds:(NSArray *)ids callBack:(NetObjLCallBackBlock)callBack;

-(void)getBaseGroupWithIds:(NSArray *)ids callBack:(NetObjLCallBackBlock)callBack;

-(void)logout;

@end
