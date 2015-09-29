//
//  LRLoginUser.h
//  AlwaysChat
//
//  Created by 鹿容 on 15/9/28.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRBaseUser.h"
#import "EMMessage.h"

#define LOGIN_STATE_CHANGED @"LOGIN_STATE_CHANGED"

#define LOGIN_USER [LRLoginUser instance]

#define MAIN_REFRESH @"MAIN_REFRESH"

typedef enum{

    login_state_ready,
    login_state_suc,
    login_state_fail
} login_state;

@interface LRLoginUser : LRBaseUser

@property (nonatomic,assign)login_state state;

@property (nonatomic,strong)NSMutableArray *messageList;

+(instancetype)instance;

-(BOOL)isLogin;

-(void)doEaseLogin;

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages;

-(void)didReceiveMessage:(EMMessage *)message;

-(NSString *)textWithMessageBody:(id<IEMMessageBody>)body;

@end
