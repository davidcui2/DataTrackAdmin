//
//  MapAnnotation.h
//  IIBProject
//
//  Created by Zhihao Cui on 27/01/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DataStorage.h"

@interface MapAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property DataStorage *dataStorage;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;


@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subTitle;

@end
