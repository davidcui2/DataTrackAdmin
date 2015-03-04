//
//  MapAnnotation.m
//  IIBProject
//
//  Created by Zhihao Cui on 27/01/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import "MapAnnotation.h"

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

@end
