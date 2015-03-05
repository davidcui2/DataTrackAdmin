//
//  SettingsViewController.h
//  DataTrackAdmin
//
//  Created by Zhihao Cui on 04/03/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SettingsViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)deleteDeviceListPressed:(id)sender;
- (IBAction)deleteAllDataPressed:(id)sender;

@end
