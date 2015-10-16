//
//  LRMainCtrl.m
//  AlwaysChat
//
//  Created by lurong on 15/9/28.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRMainCtrl.h"
#import "LRBaseUser.h"
#import "LRChatCtrl.h"
#import "LRGroupInfo.h"

@interface LRMainCtrl ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    BOOL _isFirst;
    NSMutableArray *_dataArray;
}

@end

@implementation LRMainCtrl

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MAIN_REFRESH object:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    
    LRChatCtrl *ctrl = [[LRChatCtrl alloc] init];

    EMConversation *conversation = _dataArray[indexPath.row];
    ctrl.chatID = conversation.chatter;
    ctrl.conversation = conversation;
    
    [self.navigationController pushViewController:ctrl animated:YES];
    ctrl = nil;
    conversation = nil;
}

#define TEXTLABEL_TAG @"TEXTLABEL_TAG".hash

#define DETAIL_TAG @"DETAIL_TAG".hash

#define FACE_TAG @"FACE_TAG".hash

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hehe"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"hehe"];
        cell.imageView.layer.masksToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 200, 20)];
        label.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:label];
        label.tag = TEXTLABEL_TAG;
        
        UILabel *detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.x, label.height + label.y + 3, (self.view.width - label.x *2), 13)];
        detailTextLabel.font = [UIFont systemFontOfSize:12];
        detailTextLabel.tag = DETAIL_TAG;
        [cell.contentView addSubview:detailTextLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.height/2;
        imageView.tag = FACE_TAG;
        [cell.contentView addSubview:imageView];
        imageView.layer.borderColor = [UIColor blackColor].CGColor;
        imageView.layer.borderWidth = .5;
        imageView = nil;
        
    }
    
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:FACE_TAG];
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:TEXTLABEL_TAG];
    UILabel *detailTextLabel = (UILabel *)[cell.contentView viewWithTag:DETAIL_TAG];
    
    EMConversation *conversation = _dataArray[indexPath.row];
    
    EMMessage *message = [conversation latestMessage];
    
//    LRBaseUser *user = [[LRBaseUser alloc] init];
//    user.ID = conversation.chatter.longLongValue;
//    user = [LOGIN_USER.personArray objectAtIndex:[LOGIN_USER.personArray indexOfObject:user]];
    if (conversation.conversationType == eConversationTypeChat) {
        LRBaseUser *user = [LOGIN_USER userWithID:conversation.chatter];
        
        [imageView setImageWithURL:[NSURL URLWithString:user.facePath] placeholderImage:FACE_LOAD];
        
        textLabel.text = user.name;
    }else
    {
        LRGroupInfo *group = [LOGIN_USER groupWithID:conversation.chatter];
        
        [imageView setImageWithURL:[NSURL URLWithString:group.facePath] placeholderImage:FACE_LOAD];
        
        textLabel.text = group.name;
    }
    
    if (message.messageBodies.count != 0) {
        id<IEMMessageBody> body = message.messageBodies[0];
        detailTextLabel.text = [LOGIN_USER textWithMessageBody:body];
    }else
    {
        detailTextLabel.text = nil;
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .5;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *conversation = _dataArray[indexPath.row];
        [EASE.chatManager removeConversationByChatter:conversation.chatter deleteMessages:YES append2Chat:YES];
        [self onMessageCallBack:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isFirst) {
        [self buildLayout];
        _isFirst = NO;
    }
    
    [_tableView reloadData];
    
}

-(void)buildLayout
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
//    _dataArray = LOGIN_USER.messageList;
//    _dataArray = [EASE.chatManager conversations].mutableCopy;
    
//    [EASE.chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageCallBack:) name:MAIN_REFRESH object:nil];
    
}

-(void)onMessageCallBack:(NSNotification *)notification
{
//    _dataArray = LOGIN_USER.messageList;    [EASE.chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES].mutableCopy;
    
    _dataArray = [EASE.chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES].mutableCopy;
    [_tableView reloadData];
    
    if (_dataArray.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *groupArray = [NSMutableArray array];
        
        for (EMConversation *conversation in _dataArray) {
            if (conversation.conversationType == eConversationTypeChat) {
                [array addObject:conversation.chatter];
            }else
            {
                [groupArray addObject:conversation.chatter];
            }
        }
        
        for (LRBaseUser *user in LOGIN_USER.personArray) {
            NSString *ID = [NSString stringWithFormat:@"%lld",user.ID];
            if ([array containsObject:ID]) {
                [array removeObject:ID];
            }
        }
        
        for (LRGroupInfo *group in LOGIN_USER.groupList) {
            NSString *ID = group.ID;
            if ([groupArray containsObject:ID]) {
                [groupArray removeObject:ID];
            }
        }
        
        if (array.count > 0) {
            [LC_USER_MANAGER getBaseUsersWithIds:array callBack:^(BOOL rs, NSObject *__weak obj) {
                if (rs) {
                    [_tableView reloadData];
                }
            }];
        }
        
        if (groupArray.count > 0) {
#warning 获取群组信息
            [LC_USER_MANAGER getBaseGroupWithIds:groupArray callBack:^(BOOL rs, NSObject *__weak obj) {
                if (rs) {
                    [_tableView reloadData];
                }
            }];
        }
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirst = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginStateChanged:) name:LOGIN_STATE_CHANGED object:nil];
    [self onMessageCallBack:nil];
    // Do any additional setup after loading the view.
}

-(void)onLoginStateChanged:(NSNotification *)notification
{
    login_state state = [notification.userInfo[@"state"] intValue];
    if (state == login_state_fail) {
        self.navigationController.title = @"消息(未连接)";
    }
    
    if (state == login_state_ready) {
        self.navigationController.title = @"消息(登录中)";
    }
    
    if (state == login_state_suc) {
        self.navigationController.title = @"消息";
        [self onMessageCallBack:notification];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
