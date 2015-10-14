//
//  LRLocationCtrl.h
//  AlwaysChat
//
//  Created by lurong on 15/10/13.
//  Copyright © 2015年 lurong. All rights reserved.
//

#import "LCBaseCtrl.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class LRLocationCtrl;

@protocol LocationCtrlDelegate <NSObject>

-(void)onLocationDoneWithLongitude:(CLLocationDegrees)longitude latitude:(CLLocationDegrees)latitude ctrl:(LRLocationCtrl *)ctrl address:(NSString *)address;

-(void)doCancel:(LRLocationCtrl *)ctrl;

@end

@interface LRLocationCtrl : LCBaseCtrl

@property (nonatomic,assign)CLLocationCoordinate2D location;

@property (nonatomic,assign)id<LocationCtrlDelegate> delegate;

@end
