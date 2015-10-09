//
//  LCLoginCtrl.m
//  lcs
//
//  Created by lurong on 15/4/21.
//  Copyright (c) 2015年 jinxin. All rights reserved.
//

#import "LCLoginCtrl.h"
#import "UIWindow+Extension.h"
#import "LCTabBarViewController.h"

#import "AppDelegate.h"

#define FIND_PWD_CODE_TIME @"FIND_PWD_CODE_TIME"

@interface LCLoginCtrl ()<UITextFieldDelegate>
{
    UITextField *_username;
    UITextField *_password;
    UIView *_textBgView;
    UIButton *_veryCodeBtn;
}
@end

@implementation LCLoginCtrl

-(void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(makeTime) object:nil];
}

-(void)makeTime
{
    
    NSTimeInterval timeLast = [[[NSUserDefaults standardUserDefaults] objectForKey:FIND_PWD_CODE_TIME] longLongValue];
    if (timeLast <= 0) {
        
        _veryCodeBtn.enabled = YES;
        [_veryCodeBtn setTitle:@"" forState:UIControlStateNormal];
        [_veryCodeBtn setBackgroundImage:[UIImage imageNamed:@"veryCode"] forState:UIControlStateNormal];
        _veryCodeBtn.backgroundColor = [UIColor clearColor];
        return;
    }
    
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if (now >= timeLast) {
        
        _veryCodeBtn.enabled = YES;
        [_veryCodeBtn setTitle:@"" forState:UIControlStateNormal];
        [_veryCodeBtn setBackgroundImage:[UIImage imageNamed:@"veryCode"] forState:UIControlStateNormal];
        _veryCodeBtn.backgroundColor = [UIColor clearColor];
        return;
    }
    
    _veryCodeBtn.enabled = NO;
    [_veryCodeBtn setTitle:[NSString stringWithFormat:@"%d秒",(int)(timeLast- now)] forState:UIControlStateNormal];
    [_veryCodeBtn setBackgroundImage:[UIImage imageNamed:@"icon_veryCode_no"] forState:UIControlStateNormal];
    _veryCodeBtn.backgroundColor = [LCCommon getColor:@"f99218"];
    [self performSelector:@selector(makeTime) withObject:nil afterDelay:1];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL result = [textField resignFirstResponder];
    
    if (textField == _username) {
        [_password becomeFirstResponder];
    }
    
    if (textField == _password) {
        [self doDone];
    }
    
    return result;
}

-(void)buildLayout
{
    self.title = @"登录";
    
    CGFloat top = 626/2;
    CGFloat leftSpace = 20;
    CGFloat height = 118/2;
//    CGFloat vSpace = 20;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [UIImage imageNamed:@"background"];
    [self.view addSubview:bgImageView];
    bgImageView = nil;
    
    UIImage *image = [UIImage imageNamed:@"logo"];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width - image.size.width)/2, 294/2, image.size.width, image.size.height)];
    logo.image = image;
    [self.view addSubview:logo];
    logo = nil;
    
    _textBgView = [[UIView alloc] initWithFrame:CGRectMake(leftSpace, top, self.view.width - (leftSpace * 2), height * 2)];
//    _textBgView.layer.masksToBounds = YES;
//    _textBgView.layer.cornerRadius = 5;
//    _textBgView.layer.borderWidth = .5;
//    _textBgView.layer.borderColor = [LCCommon getColor:@"999999"].CGColor;
    [self.view addSubview:_textBgView];
    
    _username = [self TextFieldWithRect:CGRectMake(0, 0, self.view.width - (leftSpace * 2), height) leftImage:[UIImage imageNamed:@"iphone"] placeHold:@"请输入手机号"];
    _username.keyboardType = UIKeyboardTypePhonePad;
    {
#warning 这里
        _username.text = @"13121475808";
    }
    
    
    
    _password = [self TextFieldWithRect:CGRectMake(_username.x, CGRectGetMaxY(_username.frame), _username.width, _username.height) leftImage:[UIImage imageNamed:@"imissage"] placeHold:@"短信验证码"];
    _password.keyboardType = UIKeyboardTypeNumberPad;
    
    CGFloat codeWidth = 198/2;
    CGFloat codeHeight = 66/2;
    CGFloat codeSpace = (_password.height - codeHeight)/2;
    
    _veryCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_password.frame) - codeSpace - codeWidth, codeSpace + _password.y, codeWidth, codeHeight)];
    [_veryCodeBtn setBackgroundImage:[UIImage imageNamed:@"veryCode"] forState:UIControlStateNormal];
    [_veryCodeBtn setBackgroundImage:[UIImage imageNamed:@"veryCode_c"] forState:UIControlStateSelected];
    _veryCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _veryCodeBtn.layer.masksToBounds = YES;
    _veryCodeBtn.layer.cornerRadius = _password.layer.cornerRadius;
//    [_veryCodeBtn setTitle:@"获取" forState:UIControlStateNormal];
    [_veryCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_textBgView addSubview:_veryCodeBtn];
    [_veryCodeBtn addTarget:self action:@selector(doGetCode:) forControlEvents:UIControlEventTouchUpInside];
    [self addTap];
    
//    [self showDoneWithTitle:@"完成"];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40, _textBgView.height + _textBgView.y + 52/2, self.view.width - 80, 45)];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    btn.backgroundColor = [LCCommon getColor:@"999999"];
    [btn addTarget:self action:@selector(doDone) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 6;
    [self.view addSubview:btn];
    btn = nil;
    
    [self addTap];
    
}

-(void)doTouch:(UIGestureRecognizer *)sender
{
    [_username resignFirstResponder];
    [_password resignFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(makeTime) object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    UITextField *text ;
    for (UITextField *field in self.view.subviews) {
        if (field.isFirstResponder) {
            text = field;
        }
    }
    
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    //    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    //    CGRect keyboardRect = [aValue CGRectValue];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect frame = self.view.frame;
        if (text == _password) {
            frame.origin.y -= 50;
        }
        self.view.frame = frame;
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self makeTime];
}


-(void)doGetCode:(UIButton *)sender
{
    
//    SHOW(@"");
    
    NSString *username = _username.text;
    
    if ([LCCommon checkIsEmptyString:username]) {
//        DISSMISS_ERR(@"请输入手机号");
        return;
    }
    
    if (![[NSString stringWithFormat:@"%ld",username.integerValue] isEqualToString:username]) {
//        DISSMISS_ERR(@"请输入11位数字格式手机号");
        return;
    }
    
    if (username.length != 11) {
//        DISSMISS_ERR(@"请输入11位数字格式手机号");
        return;
    }
    
//    [LC_USER_MANAGER getVeryCodeWithPhone:username callBack:^(BOOL rs, NSString *__weak msg) {
//        if (rs) {
////            DISSMISS;
//            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSince1970 + 60] forKey:FIND_PWD_CODE_TIME];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            [self makeTime];
//        }else
//        {
////            DISSMISS_ERR(msg);
//        }
//
//    }];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildLayout];
    // Do any additional setup after loading the view.
}

-(UITextField *)TextFieldWithRect:(CGRect)rect leftImage:(UIImage *)image placeHold:(NSString *)placeHold
{
    UITextField *text = [[UITextField alloc] initWithFrame:rect];
    text.placeholder = placeHold;
    text.backgroundColor = [UIColor clearColor];
    text.delegate = self;
    [text setValue:[LCCommon getColor:@"999999"] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.height, rect.size.height)];
    view.backgroundColor = [UIColor clearColor];
    CGFloat width = image.size.width;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.width - width)/2, (view.height - width)/2, width, width)];
    imageView.image = image;
    [view addSubview:imageView];
    text.leftView = view;
    text.leftViewMode = UITextFieldViewModeAlways;
    view = nil;
    imageView = nil;
    [_textBgView addSubview:text];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - .5 + rect.origin.y, rect.size.width, .5)];
    line.backgroundColor = [LCCommon getColor:@"999999"];
    [_textBgView addSubview:line];
    line = nil;
    
    
    return text;
}

-(void)doDone
{
    NSString *username = _username.text;
//    NSString *password = _passworkText.text;
    NSString *code = _password.text;
    
//    SHOW(@"");
    
    if ([LCCommon checkIsEmptyString:username]) {
//        DISSMISS_ERR(@"请输入手机号");
        return;
    }
    
    if (![[NSString stringWithFormat:@"%ld",username.integerValue] isEqualToString:username]) {
//        DISSMISS_ERR(@"请输入11位数字格式手机号");
        return;
    }
    
    if (username.length != 11) {
//        DISSMISS_ERR(@"请输入11位数字格式手机号");
        return;
    }
    
    if ([LCCommon checkIsEmptyString:code]) {
//        DISSMISS_ERR(@"请输入验证码");
        return;
    }
    
    [LC_USER_MANAGER loginWithUsername:username vCode:code callBack:^(BOOL rs, NSString *__weak msg) {
        if (rs) {
            LCTabBarViewController *tab = [[LCTabBarViewController alloc]init];
            
            
            LCAppDelegate.window.rootViewController = tab;
            
            [LOGIN_USER doEaseLogin];
            
        }else
        {
            
        }
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
