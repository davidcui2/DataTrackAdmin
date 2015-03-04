//
//  DataStorage.h
//  DataTrackAdmin
//
//  Created by Zhihao Cui on 03/03/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface DataStorage : NSManagedObject

@property (nonatomic, retain) NSNumber * estimateSpeed;
@property (nonatomic, retain) NSNumber * gpsLatitude;
@property (nonatomic, retain) NSNumber * gpsLongitude;
@property (nonatomic, retain) NSString * radioAccess;
@property (nonatomic, retain) NSNumber * signalStrength;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * wifiReceived;
@property (nonatomic, retain) NSNumber * wifiSent;
@property (nonatomic, retain) NSNumber * wwanReceived;
@property (nonatomic, retain) NSNumber * wwanSent;
@property (nonatomic, retain) Device *generatedBy;

@end
