//
//  LRLoginUser.h
//  AlwaysChat
//
//  Created by 鹿容 on 15/9/28.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRBaseUser.h"
#import "EMMessage.h"



#import "LCUserHttpManager.h"

@class LRChatCtrl;

#define LOGIN_STATE_CHANGED @"LOGIN_STATE_CHANGED"

#define LOGIN_USER [LRLoginUser instance]

#define MAIN_REFRESH @"MAIN_REFRESH"

#define LCAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)


#define AUTO_CODER(type,key) {\
if (![LCCommon checkIsEmptyString:[coder decodeObjectForKey:key]]) {\
self.type = [NSString stringWithFormat:@"%@",[coder decodeObjectForKey:key]];\
}\
}


#define AUTO_ECODE(type,key) {\
if (![LCCommon checkIsEmptyString:self.type]) {\
[aCoder encodeObject:[NSString stringWithFormat:@"%@",self.type] forKey:key];\
}\
}

typedef enum{
    login_state_none,
    login_state_ready,
    login_state_suc,
    login_state_fail
} login_state;

@interface LRLoginUser : LRBaseUser

@property (nonatomic,assign)login_state state;

@property (nonatomic,strong)NSMutableArray *messageList;

@property (nonatomic,assign)LRChatCtrl *controller;

@property (nonatomic,copy)NSString *token;

@property (nonatomic,strong)NSMutableArray *personArray;

-(LRBaseUser *)userWithID:(NSString *)ID;

+(instancetype)instance;

-(BOOL)isLogin;

-(void)doEaseLogin;

-(void)saveToLocal;

-(void)logout;

+(NSString *)loginUserLocalPath;

+(BOOL)getLogUserFromeLocalDb;

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages;

-(void)didReceiveMessage:(EMMessage *)message;

-(NSString *)textWithMessageBody:(id<IEMMessageBody>)body;



@end
