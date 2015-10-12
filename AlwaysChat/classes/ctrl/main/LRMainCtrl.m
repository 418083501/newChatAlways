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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hehe"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"hehe"];
    }
    
    EMConversation *conversation = _dataArray[indexPath.row];
    
    EMMessage *message = [conversation latestMessage];
    
    LRBaseUser *user = [[LRBaseUser alloc] init];
    user.ID = conversation.chatter.longLongValue;
    user = [LOGIN_USER.personArray objectAtIndex:[LOGIN_USER.personArray indexOfObject:user]];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:user.facePath] placeholderImage:FACE_LOAD];
    
    cell.textLabel.text = conversation.chatter;
    
    if (message.messageBodies.count != 0) {
        id<IEMMessageBody> body = message.messageBodies[0];
        cell.detailTextLabel.text = [LOGIN_USER textWithMessageBody:body];
    }else
    {
        cell.detailTextLabel.text = nil;
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
    
    _dataArray = [EASE.chatManager conversations].mutableCopy;
    [_tableView reloadData];
    NSMutableArray *array = [NSMutableArray array];
    
    for (EMConversation *conversation in _dataArray) {
        [array addObject:conversation.chatter];
    }
    
    [LC_USER_MANAGER getBaseUsersWithIds:array callBack:^(BOOL rs, NSObject *__weak obj) {
        if (rs) {
            [_tableView reloadData];
        }
    }];
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
        self.title = @"消息(未连接)";
    }
    
    if (state == login_state_ready) {
        self.title = @"消息(登录中)";
    }
    
    if (state == login_state_suc) {
        self.title = @"消息";
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
