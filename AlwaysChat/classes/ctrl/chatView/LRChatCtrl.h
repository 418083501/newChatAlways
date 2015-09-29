//
//  LRChatCtrl.h
//  AlwaysChat
//
//  Created by lurong on 15/9/29.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LCBaseCtrl.h"

@interface LRChatCtrl : LCBaseCtrl

@property (nonatomic,copy)NSString *chatID;

@property (nonatomic,strong)EMConversation *conversation;

-(void)didReceiveMessage:(EMMessage *)message;

@end
