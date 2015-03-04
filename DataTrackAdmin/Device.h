//
//  Device.h
//  DataTrackAdmin
//
//  Created by Zhihao Cui on 03/03/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DataStorage;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSNumber * deviceID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSSet *generate;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addGenerateObject:(DataStorage *)value;
- (void)removeGenerateObject:(DataStorage *)value;
- (void)addGenerate:(NSSet *)values;
- (void)removeGenerate:(NSSet *)values;

@end
