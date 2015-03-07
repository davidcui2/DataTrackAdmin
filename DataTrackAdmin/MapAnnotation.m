//
//  MapAnnotation.m
//  IIBProject
//
//  Created by Zhihao Cui on 27/01/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import "MapAnnotation.h"

@interface MapAnnotation ()

@end

@implementation MapAnnotation

@synthesize coordinate = _coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        _coordinate = coord;
    }
    return self;
}

- (NSString *)title{
    return _title;
}

- (NSString *)subtitle{
    return _subTitle;
}

-(void)setOverallStatsWithAverageWifiSent:(NSNumber *)aWifiSent wifiReceived:(NSNumber *)aWifiReceived wwanSent:(NSNumber *)aWwanSent wwanReceived:(NSNumber *)aWwanReceived {
    _averageDataUsage = [NSArray arrayWithObjects:aWifiReceived, aWifiSent, aWwanReceived, aWwanSent, nil];
}

@end
