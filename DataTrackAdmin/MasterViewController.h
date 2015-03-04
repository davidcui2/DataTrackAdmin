//
//  MasterViewController.h
//  DataTrackAdmin
//
//  Created by Zhihao Cui on 03/03/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

