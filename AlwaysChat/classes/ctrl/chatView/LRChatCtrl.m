//
//  LRChatCtrl.m
//  AlwaysChat
//
//  Created by lurong on 15/9/29.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRChatCtrl.h"

#define SHADOW_TAG @"SHADOW_TAG".hash

@interface LRChatCtrl ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,IEMChatProgressDelegate>
{
    BOOL _isFirst;
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UITextField *_textField;
    UIGestureRecognizer *_gesture;
}
@property (nonatomic,strong)UIView *bottomView;

@end

@implementation LRChatCtrl

-(void)setProgress:(float)progress forMessage:(EMMessage *)message forMessageBody:(id<IEMMessageBody>)messageBody
{
    
}

-(UIView *)bottomView
{
    if (!_bottomView) {
        CGFloat height = 45;
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - height, self.view.width, height)];
        
        CGFloat textHeight = 35;
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(45, (height - textHeight)/2, _bottomView.width - 45 - 45, textHeight)];
        _textField.layer.masksToBounds = YES;
        _textField.layer.cornerRadius = 3;
        _textField.layer.borderColor = [UIColor grayColor].CGColor;
        _textField.layer.borderWidth = 1;
        [_bottomView addSubview:_textField];
        _textField.delegate = self;
        
    }
    return _bottomView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MAIN_REFRESH object:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hehe"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"hehe"];
    }
    
    cell.detailTextLabel.text = @"";
    
    EMMessage *message = _dataArray[indexPath.row];
    if (message.messageBodies.count != 0) {
        id<IEMMessageBody> body = message.messageBodies[0];
        if (body.messageBodyType == eMessageBodyType_Text) {
            cell.detailTextLabel.text = [LOGIN_USER textWithMessageBody:body];
        }
    }
    cell.textLabel.text = message.from;
    
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        if (_tableView.contentOffset.y <= 0) {
            
            if (_dataArray.count % 20 == 0 && _dataArray.count != 0) {
                NSArray *array = [self.conversation loadNumbersOfMessages:20 withMessageId:[_dataArray[0] messageId]];
                if (array.count == 0) {
                    return;
                }
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)];
                [_dataArray insertObjects:array atIndexes:set];
                [_tableView reloadData];
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:array.count inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }
        }
    }
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    if (message) {
        [_dataArray addObject:message];
    }
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

-(void)buildLayout
{
    self.title = @"会话";
    [self.view addSubview:self.bottomView];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - self.bottomView.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
//    _dataArray = [self.conversation loadNumbersOfMessages:30 before:.0].mutableCopy;
    _dataArray = [self.conversation loadNumbersOfMessages:20 withMessageId:nil].mutableCopy;
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    _gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShadowTouched:)];
}

-(void)makeMessageFromLocal
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isFirst) {
        
        [self buildLayout];
        
        _isFirst = NO;
    }
    
    LOGIN_USER.controller = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (LOGIN_USER.controller == self) {
        LOGIN_USER.controller = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    
    
    
//    [[self.view viewWithTag:SHADOW_TAG] removeFromSuperview];
    [_tableView removeGestureRecognizer:_gesture];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.y = self.view.height - self.bottomView.height;
        _tableView.height = self.bottomView.y;
    } completion:^(BOOL finished) {
        [self didReceiveMessage:nil];
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
        CGRect keyboardRect = [aValue CGRectValue];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [_tableView addGestureRecognizer:_gesture];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomView.y = self.view.height - self.bottomView.height - keyboardRect.size.height;
        _tableView.height = self.bottomView.y;
        
    } completion:^(BOOL finished) {
        [self didReceiveMessage:nil];
    }];
}

-(void)onShadowTouched:(UIGestureRecognizer *)sender
{
    [_textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    
    
    NSLog(@"发送");
    
    if ([LCCommon checkIsEmptyString:textField.text]) {
        return [_textField resignFirstResponder];
    }
    
    EMChatText *txtChat = [[EMChatText alloc] initWithText:_textField.text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.chatID bodies:@[body]];
    message.messageType = (EMMessageType)self.conversation.conversationType; // 设置为单聊消息
    //message.messageType = eConversationTypeGroupChat;// 设置为群聊消息
    //message.messageType = eConversationTypeChatRoom;// 设置为聊天室消息
    
    EMError *error;
    
    [EASE.chatManager asyncSendMessage:message progress:self prepare:^(EMMessage *message, EMError *error) {
        
    } onQueue:dispatch_get_main_queue() completion:^(EMMessage *message1, EMError *error) {
//        [EASE.chatManager insertMessageToDB:message1];
    } onQueue:dispatch_get_main_queue()];
//    [EASE.chatManager insertMessageToDB:message];
//    self.conversation 
    
    if (error) {
        NSLog(@"error=%@",error);
    }
    
    [_dataArray addObject:message];
    
    
    textField.text = @"";
    
    return [_textField resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirst = YES;
    // Do any additional setup after loading the view.
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
