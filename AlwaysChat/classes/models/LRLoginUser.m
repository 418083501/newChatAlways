//
//  LRLoginUser.m
//  AlwaysChat
//
//  Created by 鹿容 on 15/9/28.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRLoginUser.h"

@implementation LRLoginUser

+(instancetype)instance
{
    static LRLoginUser *user;
    if (!user) {
        user = [[LRLoginUser alloc] init];
    }
    return user;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self makeSelfWithLocal];
        self.state = login_state_ready;
        if ([self isLogin]) {
            [self doEaseLogin];
        }
        
    }
    return self;
}

-(void)doEaseLogin
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil userInfo:@{@"state":@(login_state_ready)}];
    self.state = login_state_ready;
    
    NSString *username = [NSString stringWithFormat:@"%lld",self.ID];
    [EASE.chatManager asyncLoginWithUsername:username password:username completion:^(NSDictionary *loginInfo, EMError *error) {
        
        if (loginInfo && !error)
        {
            NSLog(@"登录成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil userInfo:@{@"state":@(login_state_suc)}];
            self.state = login_state_suc;
        }else
        {
                
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_STATE_CHANGED object:nil userInfo:@{@"state":@(login_state_fail)}];
            
            self.state = login_state_fail;
        }
        
    } onQueue:nil];
}

+(NSString *)loginUserLocalPath
{
    return @"";
}

-(void)makeSelfWithLocal
{
    self.ID = 10000;
    self.name = @"lulu";
    self.facePath = @"http://img5.duitang.com/uploads/item/201503/26/20150326161657_aL8FW.jpeg";
    self.destrib = @"鹿哥霸气";
    self.sex = @"男";
}

-(BOOL)isLogin
{
    return self.ID != 0;
}

-(void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    for (EMMessage *message in offlineMessages) {
        [self onMessageAddWithMessage:message];
    }
}

-(void)didReceiveMessage:(EMMessage *)message
{
    [self onMessageAddWithMessage:message];
}

-(void)onMessageAddWithMessage:(EMMessage *)message
{
    if (!self.messageList) {
        self.messageList = [NSMutableArray array];
        [self.messageList addObject:message];
    }
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    for (EMMessage *em in self.messageList) {
        if ([em.from isEqualToString:message.from] && [em.to isEqualToString:message.to]) {
            [self.messageList removeObject:em];
            break;
        }
        
        if ([em.to isEqualToString:message.from] && [em.from isEqualToString:message.to]) {
            [self.messageList removeObject:em];
            break;
        }
        
    }
    
    [self.messageList addObject:message];
    
    [lock unlock];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_REFRESH object:nil userInfo:@{}];
    
}

-(NSString *)textWithMessageBody:(id<IEMMessageBody>)body
{
    NSString *result = @"";
    
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *message = body;
        result = message.text;
    }
    
    return result;
}

@end
