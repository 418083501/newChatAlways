//
//  LRLoginUser.m
//  AlwaysChat
//
//  Created by 鹿容 on 15/9/28.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRLoginUser.h"
#import "LRChatCtrl.h"

@implementation LRLoginUser


static LRLoginUser *_user;

+(instancetype)instance
{
    
    if (!_user) {
        _user = [[LRLoginUser alloc] init];
    }
    return _user;
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

-(void)saveToLocal
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL sucess = [NSKeyedArchiver archiveRootObject:self toFile:[LRLoginUser loginUserLocalPath]];
        NSLog(@"saveLoginUser=%d",sucess);
    });
    
}

-(void)logout
{
//    if ([LC_LOGINUSER isLogin]) {
//        [LC_USER_MANAGER logOut];
//    }
    [LCCommon deleteWithFilepath:[LRLoginUser loginUserLocalPath]];
    
    _user = nil;
    
}

+ (BOOL)getLogUserFromeLocalDb{
    NSLog(@"getLogUserFromeLocalDb");
    
    _user = [NSKeyedUnarchiver unarchiveObjectWithFile:[LRLoginUser loginUserLocalPath]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[LRLoginUser loginUserLocalPath]]) {
        NSLog(@"fileLoginUser文件不存在");
    }
    
    if (_user && [_user isLogin]) {
        
        NSLog(@"有新登录缓存");
        NSLog(@"uid=%lld",_user.ID);
        
        return YES;
    }
    return NO;
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
    NSString * videoPath = [LCCommon getDirectoryForDocuments:@"cache"];
    NSString * videoName = [NSString stringWithFormat:@"%@.plist",@"loginUser"];
    return [videoPath stringByAppendingPathComponent:videoName];
}

-(void)makeSelfWithLocal
{
    self.ID = 10000;
    self.name = @"lulu";
    self.facePath = @"http://img5.duitang.com/uploads/item/201503/26/20150326161657_aL8FW.jpeg";
    self.destrib = @"鹿哥霸气";
    self.sex = @"男";
    [self saveToLocal];
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
    if (self.controller && ([self.controller.chatID isEqualToString:message.from] || [self.controller.chatID isEqualToString:message.to])) {
        [self.controller didReceiveMessage:message];
    }
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
    [self saveToLocal];
}

-(NSString *)textWithMessageBody:(id<IEMMessageBody>)body
{
    NSString *result = @"";
    
    if (body.messageBodyType == eMessageBodyType_Text) {
        EMTextMessageBody *message = body;
        result = message.text;
    }else if (body.messageBodyType == eMessageBodyType_Image)
    {
        result = @"[图片]";
    }else if (body.messageBodyType == eMessageBodyType_Video)
    {
        result = @"[视频]";
    }else if (body.messageBodyType == eMessageBodyType_Location)
    {
        result = @"[地理位置]";
    }else if (body.messageBodyType == eMessageBodyType_Voice)
    {
        result = @"[音频]";
    }else if (body.messageBodyType == eMessageBodyType_File)
    {
        result = @"[文件]";
    }else if (body.messageBodyType == eMessageBodyType_Command)
    {
        result = @"[其他]";
    }
    
    return result;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self) {
//        AUTO_CODER(ID, @"ID");
        if (self.ID != 0) {
            self.ID = [[coder decodeObjectForKey:@"ID"] longLongValue];
        }else
        {
            return self;
        }
        AUTO_CODER(facePath, @"facePath");
        AUTO_CODER(name, @"name");
//        AUTO_CODER(token, @"token");
        self.messageList = [[coder decodeObjectForKey:@"messageList"] mutableCopy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
//    AUTO_ECODE(ID, @"ID");
    if (self.ID != 0) {
        [aCoder encodeObject:[NSString stringWithFormat:@"%lld",self.ID] forKey:@"ID"];
    }else
    {
        return;
    }
    AUTO_ECODE(facePath, @"facePath");
    AUTO_ECODE(name, @"name");
//    AUTO_ECODE(token, @"token");
//    AUTO_ECODE(userDept, @"userDept");
    [aCoder encodeObject:self.messageList forKey:@"messageList"];
}

@end
