//
//  DatePickerForMapTableViewController.h
//  IIBProject
//
//  Created by Zhihao Cui on 05/02/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerForMapTableViewController : UITableViewController <UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property NSArray* selectedDeviceID;

@end
