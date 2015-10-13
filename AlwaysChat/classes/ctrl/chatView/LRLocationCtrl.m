//
//  LRLocationCtrl.m
//  AlwaysChat
//
//  Created by lurong on 15/10/13.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRLocationCtrl.h"
#import <CoreLocation/CoreLocation.h>

@interface KCAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

#pragma mark 自定义一个图片属性在创建大头针视图时使用
@property (nonatomic,strong) UIImage *image;

@end

@implementation KCAnnotation



@end

@interface LRLocationCtrl ()<MKMapViewDelegate,CLLocationManagerDelegate>
{
    MKMapView *_mapView;
    MKPointAnnotation *_annotation;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _currentLocationCoordinate;
    BOOL _isFirst;
    BOOL _hasLocation;
    CLLocationManager *_locationManage;
}

@end

@implementation LRLocationCtrl

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hasLocation = NO;
    }
    return self;
}

-(void)buildLayout
{
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
    
    [self buildManager];
    
    if (_hasLocation) {
        [self addAnnotationWithLocation:_currentLocationCoordinate];
    }else
    {
        [self showDoneWithTitle:@"发送"];
    }
    
}

-(void)doDone
{
    
}

#pragma mark 添加大头针
-(void)addAnnotationWithLocation:(CLLocationCoordinate2D)location1
{
    [_mapView removeAnnotations:_mapView.annotations];
    //    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(39.95, 116.35);
    KCAnnotation *annotation1=[[KCAnnotation alloc]init];
    annotation1.title=@"locaion";
    annotation1.subtitle=@"local";
    annotation1.coordinate = location1;
    [_mapView addAnnotation:annotation1];
    [_mapView showAnnotations:_mapView.annotations animated:YES];
    _mapView.showsUserLocation = NO;
}

-(void)buildManager
{
    if([CLLocationManager locationServicesEnabled]){
        _locationManage = [[CLLocationManager alloc] init];
        _locationManage.delegate = self;
        _locationManage.distanceFilter = 200;
        _locationManage.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//kCLLocationAccuracyBest;
        if ([UIDevice currentDevice].systemVersion.intValue >= 8) {
            //使用期间
            [_locationManage requestWhenInUseAuthorization];
            //始终
            //or [self.locationManage requestAlwaysAuthorization]
        }
    }
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    _currentLocationCoordinate = location;
    _location = location;
    
    _hasLocation = YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isFirst) {
        [self buildLayout];
        _isFirst = NO;
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
