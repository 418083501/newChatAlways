//
//  LRChatCtrl.m
//  AlwaysChat
//
//  Created by lurong on 15/9/29.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRChatCtrl.h"

#import "UIView+propety.h"

#import "LRLocationCtrl.h"

#define SHADOW_TAG @"SHADOW_TAG".hash

#define TOOLS_HEIGHT (200)

#import <MobileCoreServices/UTCoreTypes.h>

#import <AVFoundation/AVFoundation.h>

#import <MediaPlayer/MediaPlayer.h>


@interface MyImageView : UIImageView

@property (nonatomic,strong)NSDictionary *userInfo;

@end

@implementation MyImageView

@end


@interface LRChatCtrl ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,IEMChatProgressDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,LocationCtrlDelegate,UIActionSheetDelegate>
{
    BOOL _isFirst;
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UITextField *_textField;
    UIGestureRecognizer *_gesture;
}
@property (nonatomic,strong)UIView *bottomView;

@property (nonatomic,strong)UIView *toolsView;

@end

@implementation LRChatCtrl

-(UIView *)toolsView
{
    if (!_toolsView) {
        _toolsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, TOOLS_HEIGHT)];
        
        CGFloat width = _toolsView.width / 3;
        
        CGFloat height = _toolsView.height / 2;
        
        NSArray *toolArray = @[@"照片",@"相册",@"位置",@"视频",@"文件"];
        
        for (int i = 0; i<toolArray.count; i++) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i%3 * width, i/3 * height, width, height)];
            view.layer.borderWidth = 1;
            view.layer.borderColor = [UIColor blackColor].CGColor;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, view.height - 20, view.width, 20)];
            label.text = toolArray[i];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            view.tag = i + 1000;
            view.userInteractionEnabled = YES;
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doToolsClick:)]];
            [_toolsView addSubview:view];
            view = nil;
        }
        
    }
    return _toolsView;
}

-(void)doToolsClick:(UIGestureRecognizer *)sender
{
    
    UIView *view = sender.view;
    
    switch (view.tag - 1000) {
        case 0:
        {
            [self doPhoto:UIImagePickerControllerSourceTypeCamera mode:UIImagePickerControllerCameraCaptureModePhoto];
        }
            break;
        case 1:
        {
            [self doPhoto:UIImagePickerControllerSourceTypePhotoLibrary mode:UIImagePickerControllerCameraCaptureModePhoto];
        }
            break;
        case 2:
        {
            LRLocationCtrl *ctrl = [[LRLocationCtrl alloc] init];
            ctrl.delegate = self;
            [self.navigationController pushViewController:ctrl animated:YES];
            ctrl = nil;
        }
            break;
        case 3:
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"拍摄", nil];
            sheet.tag = 123321;
            [sheet showInView:self.view];
            sheet = nil;
        }
            break;
            
        default:
            break;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 123321) {
        UIImagePickerControllerSourceType mode;
        if (buttonIndex == 0) {
            mode = UIImagePickerControllerSourceTypePhotoLibrary;
        }else if(buttonIndex == 1)
        {
            mode = UIImagePickerControllerSourceTypeCamera;
        }
        
        [self doPhoto:mode mode:UIImagePickerControllerCameraCaptureModeVideo];
        
    }
}

-(void)doCancel:(LRLocationCtrl *)ctrl
{
    [ctrl.navigationController popViewControllerAnimated:YES];
}

-(void)onLocationDoneWithLongitude:(CLLocationDegrees)longitude latitude:(CLLocationDegrees)latitude ctrl:(LRLocationCtrl *)ctrl address:(NSString *)address
{
    [self doCancel:ctrl];
    EMChatLocation *locChat = [[EMChatLocation alloc] initWithLatitude:latitude longitude:longitude address:address];
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithChatObject:locChat];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.chatID bodies:@[body]];
    message.messageType = (EMMessageType)self.conversation.conversationType; // 设置为单聊消息
    
    [self sendMessage:message];
}

-(void)doPhoto:(UIImagePickerControllerSourceType)sourceType mode:(UIImagePickerControllerCameraCaptureMode)mode
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
//    picker.mediaTypes = [picker ]
    
    if (mode == UIImagePickerControllerCameraCaptureModePhoto) {
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
        
    }else
    {
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie, nil];
    }
    //设置拍照后的图片可被编辑
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
    [self dismissTools];
}

-(void)sendMessage:(EMMessage *)message
{
    message.messageType = (EMMessageType)self.conversation.conversationType;
    
    EMError *error;
    
    [EASE.chatManager asyncSendMessage:message progress:self prepare:^(EMMessage *message, EMError *error) {
        
    } onQueue:nil completion:^(EMMessage *message1, EMError *error) {
        
    } onQueue:nil];
    
    if (error) {
        NSLog(@"error=%@",error);
    }
    
    [_dataArray addObject:message];
    
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self imagePickerControllerDidCancel:picker];
    
    if (picker.mediaTypes.count == 0) {
        return;
    }
    
    if ([picker.mediaTypes[0] isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (image) {
            
            EMChatImage *imgChat = [[EMChatImage alloc] initWithUIImage:image displayName:@"displayName"];
            EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithChatObject:imgChat];
            
            // 生成message
            EMMessage *message = [[EMMessage alloc] initWithReceiver:self.chatID bodies:@[body]];
            
            [self sendMessage:message];
            
        }else
        {
            
        }
    }else if ([picker.mediaTypes[0] isEqualToString:(NSString*)kUTTypeMovie])
    {
        NSURL *localPath = info[@"UIImagePickerControllerMediaURL"];
        NSURL *url = [self convert2Mp4:localPath callBack:^(BOOL rs, NSString *__weak msg) {
            if (rs) {
                NSLog(@"视频处理成功");
            }else
            {
                NSLog(@"视频处理失败");
            }
        }];
        
        EMChatVideo *videoChat = [[EMChatVideo alloc] initWithFile:url.relativePath displayName:@"displayName"];
        EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithChatObject:videoChat];
        
        EMMessage *message = [[EMMessage alloc] initWithReceiver:self.chatID bodies:@[body]];
        
        [self sendMessage:message];
        
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)setProgress:(float)progress forMessage:(EMMessage *)message forMessageBody:(id<IEMMessageBody>)messageBody
{
    
}

-(void)didFetchMessageThumbnail:(EMMessage *)aMessage
{
    NSInteger index = [_dataArray indexOfObject:aMessage];
    if (index != NSNotFound) {
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:path];
        if (cell) {
            [_tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }
}

- (NSURL *)convert2Mp4:(NSURL *)movUrl callBack:(NetBOOLCallBackBlock)callBack{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
//        mp4Url = [movUrl copy];
//        mp4Url = [mp4Url URLByDeletingPathExtension];
//        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        
        mp4Url = [NSURL fileURLWithPath:[LCCommon genareteVideoPath]];
        
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                    callBack(NO,@"");
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                    callBack(NO,@"");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                    callBack(YES,[mp4Url relativePath]);
                } break;
                default: {
                    NSLog(@"others.");
                    callBack(NO,@"");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
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
        
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(_textField.x + _textField.width, 0, 45, 45)];
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(changeTools) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
        btn = nil;
        
    }
    return _bottomView;
}

-(void)changeTools
{
    if (self.toolsView.y == self.view.height - self.toolsView.height) {
        [self dismissTools];
    }else
    {
        [self showTools];
    }
}

-(void)showTools
{
    if (_textField.isFirstResponder) {
        [_textField resignFirstResponder];
    }
    [_tableView addGestureRecognizer:_gesture];
    [UIView animateWithDuration:.3 animations:^{
        
        self.bottomView.y = self.view.height - self.bottomView.height - self.toolsView.height;
        _tableView.height = self.bottomView.y;
        self.toolsView.y = self.view.height - self.toolsView.height;
        
    } completion:^(BOOL finished) {
        [self didReceiveMessage:nil];
    }];
}

-(void)dismissTools
{
    [_tableView removeGestureRecognizer:_gesture];
    [UIView animateWithDuration:.3 animations:^{
        self.bottomView.y = self.view.height - self.bottomView.height;
        _tableView.height = self.bottomView.y;
        self.toolsView.y = self.view.height;
    } completion:^(BOOL finished) {
        [self didReceiveMessage:nil];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MAIN_REFRESH object:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
}

#define IMAGE_TAG @"IMAGE_TAG".hash

#define TEXTLABEL_TAG @"TEXTLABEL_TAG".hash

#define DETAIL_TAG @"DETAIL_TAG".hash

#define FACE_TAG @"FACE_TAG".hash

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hehe"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"hehe"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
    
    detailTextLabel.text = @" ";
    
    [[cell.contentView viewWithTag:IMAGE_TAG] removeFromSuperview];
    
    EMMessage *message = _dataArray[indexPath.row];
    if (message.messageBodies.count != 0) {
        id<IEMMessageBody> body = message.messageBodies[0];
        if (body.messageBodyType == eMessageBodyType_Text) {
            detailTextLabel.text = [LOGIN_USER textWithMessageBody:body];
        }
        
        if (body.messageBodyType == eMessageBodyType_Video) {
            UIImageView *imageView = [[MyImageView alloc] initWithFrame:CGRectMake(textLabel.x, textLabel.y + textLabel.height + 5, 100, 100)];
            imageView.layer.masksToBounds = YES;
            imageView.tag = IMAGE_TAG;
            EMVideoMessageBody *chatImage = (EMVideoMessageBody *)body;
            
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doImageViewClick:)]];
            imageView.userInfo = @{MESSAGE_USERINFO:message};
            
            if ([LCCommon checkIsEmptyString:chatImage.localPath] && (chatImage.attachmentDownloadStatus == EMAttachmentDownloadFailure || chatImage.attachmentDownloadStatus == EMAttachmentNotStarted)){
                [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil];
            }
            
            if (![LCCommon checkIsEmptyString:chatImage.thumbnailLocalPath]) {
                
                imageView.image = [UIImage imageWithContentsOfFile:chatImage.thumbnailLocalPath];
                
            }else
            {
                
            }
            
            [cell.contentView addSubview:imageView];
            imageView = nil;
        }else if (body.messageBodyType == eMessageBodyType_Image) {
            UIImageView *imageView = [[MyImageView alloc] initWithFrame:CGRectMake(textLabel.x, textLabel.y + textLabel.height + 5, 100, 100)];
            imageView.layer.masksToBounds = YES;
            imageView.tag = IMAGE_TAG;
            EMImageMessageBody *chatImage = (EMImageMessageBody *)body;
            
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doImageViewClick:)]];
            imageView.userInfo = @{MESSAGE_USERINFO:message};
            
            if (![LCCommon checkIsEmptyString:chatImage.thumbnailLocalPath]) {
                
                imageView.image = [UIImage imageWithContentsOfFile:chatImage.thumbnailLocalPath];
                
            }else
            {
                
            }
            
            [cell.contentView addSubview:imageView];
            imageView = nil;
        }
        
        if (body.messageBodyType == eMessageBodyType_Location) {
            //chat_location_preview
            UIImageView *imageView = [[MyImageView alloc] initWithFrame:CGRectMake(textLabel.x, textLabel.y + textLabel.height + 5, 100, 100)];
            imageView.layer.masksToBounds = YES;
            imageView.userInfo = @{MESSAGE_USERINFO:message};
            imageView.tag = IMAGE_TAG;
            imageView.image = [UIImage imageNamed:@"chat_location_preview"];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doImageViewClick:)]];
            
            [cell.contentView addSubview:imageView];
            imageView = nil;
        }
        
        
    }
    
    LRBaseUser *user = [LOGIN_USER userWithID:message.from];
    if (message.from.longLongValue == LOGIN_USER.ID) {
        user = LOGIN_USER;
    }
    
    textLabel.text = user.name;
    [imageView setImageWithURL:[NSURL URLWithString:user.facePath] placeholderImage:FACE_LOAD];
    
    return cell;
}

-(void)doImageViewClick:(UIGestureRecognizer *)sender
{
    UIImageView *imageView = (UIImageView *)sender.view;
    EMMessage *message = imageView.userInfo[MESSAGE_USERINFO];
    
    if (message.messageBodies.count != 0) {
        id<IEMMessageBody> body = message.messageBodies[0];
        
        switch (body.messageBodyType) {
            case eMessageBodyType_Location:
            {
                EMLocationMessageBody *locationBody = (EMLocationMessageBody *)body;
                LRLocationCtrl *ctrl = [[LRLocationCtrl alloc] init];
                ctrl.location = CLLocationCoordinate2DMake(locationBody.latitude, locationBody.longitude);
                [self.navigationController pushViewController:ctrl animated:YES];
                ctrl = nil;
                
            }
                break;
            case eMessageBodyType_Image:
            {
                EMImageMessageBody *chatImage = (EMImageMessageBody *)body;
                UIImageView *showView = [[UIImageView alloc] initWithFrame:self.view.bounds];
                [self.view addSubview:showView];
                showView.userInteractionEnabled = YES;
                [showView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDismiss:)]];
                [showView setImageWithURL:[NSURL URLWithString:chatImage.remotePath] placeholderImage:imageView.image];
            }
                break;
            case eMessageBodyType_Video:
            {
                EMVideoMessageBody *videoBody = (EMVideoMessageBody *)body;
                NSString *videoPath = videoBody.localPath;
                if ([LCCommon checkIsEmptyString:videoPath]) {
                    
                    NSLog(@"视频尚未下载完成");
                    
                    return;
                }
                NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
                MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
                [moviePlayerController.moviePlayer prepareToPlay];
                moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
                [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
            }
                break;
                
            default:
                break;
        }
        
    }
    
}

-(void)doDismiss:(UIGestureRecognizer *)sender
{
    [sender.view removeFromSuperview];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EMMessage *message = _dataArray[indexPath.row];
    
    if (message.messageBodies.count != 0) {
        id<IEMMessageBody> body = message.messageBodies[0];
        if (body.messageBodyType == eMessageBodyType_Image || body.messageBodyType == eMessageBodyType_Location ||
            body.messageBodyType == eMessageBodyType_Video) {
            return 140;
        }
    }
    
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
    if (_dataArray.count > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
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
    if (_dataArray.count > 0) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    _gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShadowTouched:)];
    [self.view addSubview:self.toolsView];
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
    
    [self dismissTools];
    
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
    
    
    [self dismissTools];
    
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
    
    [self sendMessage:message];
    
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
