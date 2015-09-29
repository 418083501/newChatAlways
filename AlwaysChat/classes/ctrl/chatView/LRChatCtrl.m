//
//  LRChatCtrl.m
//  AlwaysChat
//
//  Created by lurong on 15/9/29.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRChatCtrl.h"

@interface LRChatCtrl ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isFirst;
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}

@end

@implementation LRChatCtrl
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

-(void)didReceiveMessage:(EMMessage *)message
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    [_dataArray addObject:message];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

-(void)buildLayout
{
    self.title = @"会话";
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
//    _dataArray = [self.conversation loadNumbersOfMessages:30 before:.0].mutableCopy;
    _dataArray = [self.conversation loadNumbersOfMessages:30 withMessageId:nil].mutableCopy;
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
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (LOGIN_USER.controller == self) {
        LOGIN_USER.controller = nil;
    }
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
