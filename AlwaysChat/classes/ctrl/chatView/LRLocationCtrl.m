//
//  LRLocationCtrl.m
//  AlwaysChat
//
//  Created by lurong on 15/10/13.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LRLocationCtrl.h"

#define  MMLastLongitude @"MMLastLongitude"
#define  MMLastLatitude  @"MMLastLatitude"


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
    CLLocationDegrees _longtude;
    CLLocationDegrees _latitude;
    NSString *_address;
}

@end

@implementation LRLocationCtrl

-(void)dealloc
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeFromSuperview];
    _mapView = nil;
}

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
        _mapView.showsUserLocation = YES;
    }
    
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManage respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManage requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //    CLLocation * newLocation = userLocation.location;
    [self addAnnotationWithLocation:mapView.userLocation.location.coordinate];
    
    _currentLocationCoordinate = mapView.userLocation.location.coordinate;
    
    NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
    
    [standard setObject:@(_currentLocationCoordinate.longitude) forKey:MMLastLongitude];
    [standard setObject:@(_currentLocationCoordinate.latitude) forKey:MMLastLatitude];
    
    _longtude = _currentLocationCoordinate.longitude;
    _latitude = _currentLocationCoordinate.latitude;
    
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
    {
        for (CLPlacemark * placeMark in placemarks)
        {
            NSDictionary *addressDic=placeMark.addressDictionary;
//            _provice=[addressDic objectForKey:@"State"];
//            _city=[addressDic objectForKey:@"City"];
//            _district=[addressDic objectForKey:@"SubLocality"];
//            _street=[addressDic objectForKey:@"Street"];
//            
            _address=addressDic[@"FormattedAddressLines"];
//            [self makeData];
        }
    };
    [[NSUserDefaults standardUserDefaults] synchronize];
    [clGeoCoder reverseGeocodeLocation:userLocation.location completionHandler:handle];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"error=%@",error);
}

-(void)doDone
{
    if (_longtude == 0 && _latitude == 0) {
        NSLog(@"暂未完成定位");
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onLocationDoneWithLongitude:latitude:ctrl:address:)]) {
        [self.delegate onLocationDoneWithLongitude:_longtude latitude:_latitude ctrl:self address:_address];
    }
    
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
