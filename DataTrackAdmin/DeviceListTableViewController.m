//
//  DeviceListTableViewController.m
//  DataTrackAdmin
//
//  Created by Zhihao Cui on 03/03/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import "DeviceListTableViewController.h"
#import "DatePickerForMapTableViewController.h"

#import "Device.h"
#import "DataStorage.h"

@interface DeviceListTableViewController ()

@property NSMutableArray * cellSelected;

@property UIBarButtonItem * nextButton;
@property UIBarButtonItem * fetchDoneButton;

@end

@implementation DeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellSelected = [NSMutableArray array];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.

}

- (void)viewWillAppear:(BOOL)animated {
    if (self.choiceInMasterView) {
        // Initialize the refresh control.
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor purpleColor];
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(reloadDeviceList)
                      forControlEvents:UIControlEventValueChanged];
        
        self.fetchDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishSelectFetchDevices)];
        
        self.navigationItem.rightBarButtonItem = self.fetchDoneButton;
        
    }
    else {
        self.refreshControl = nil;
        
        self.nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(finishSelectDevices)];
        self.navigationItem.rightBarButtonItem = self.nextButton;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    if ([self.cellSelected containsObject:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //the below code will allow multiple selection
    if ([self.cellSelected containsObject:indexPath])
    {
        [self.cellSelected removeObject:indexPath];
    }
    else
    {
        [self.cellSelected addObject:indexPath];
    }
    
    [tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Device *device = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"ID: %@",device.deviceID];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deviceID" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Utility

-(void) reloadDeviceList
{
    [self.refreshControl beginRefreshing];
    [self fetchDeviceList];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

-(void) fetchDeviceList
{
    NSString* fullAddress = [NSString stringWithFormat:@"https://www.zhihaodatatrack.com/Direct/Get/getDeviceList.php"];
    
    NSMutableURLRequest *newRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:fullAddress]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLResponse *response;
    NSError * getError;
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&getError];
    if (getError) {
        NSLog(@"%@",getError);
    }
    NSString *theReply = [[NSString alloc] initWithBytes:[GETReply bytes] length:[GETReply length] encoding: NSASCIIStringEncoding];
    NSLog(@"Reply: %@", theReply);
    
    if ([theReply isEqualToString:@"null"]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Ooops" message:@"No devices on server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSError* jsonError;
    NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:GETReply options:NSJSONReadingMutableLeaves error:&jsonError];
    
    [self insertJsonToCoreData:jsonArray];
}

- (void) insertJsonToCoreData:(NSArray*)jsonArray {
    NSManagedObjectContext * context = _managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:context];
    
    for (NSDictionary * dict in jsonArray) {
        Device *device = nil;

        device = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Device" inManagedObjectContext:context];
        device.deviceID = [NSNumber numberWithInt:[[dict objectForKey:@"deviceID"]intValue]];
        device.name = [dict objectForKey:@"deviceName"];
        device.owner = [dict objectForKey:@"deviceOwner"];
    }
    
    [self saveContext];
}

- (void) finishSelectDevices
{
    [self performSegueWithIdentifier:@"finishSelectDevices" sender:nil];
}

- (void) finishSelectFetchDevices
{
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    NSString* fullAddress;
    // For each selected
    for (NSIndexPath* index in _cellSelected) {
        int deviceID = (int)index.row +1;
        fullAddress = [NSString stringWithFormat:@"https://www.zhihaodatatrack.com/Direct/Get/getCurrentDeviceData.php?deviceID=%i",deviceID];
        
        NSMutableURLRequest *newRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:fullAddress]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        NSURLResponse *response;
        NSError * getError;
        NSData *GETReply = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&getError];
        if (getError) {
            NSLog(@"%@",getError);
        }
        NSString *theReply = [[NSString alloc] initWithBytes:[GETReply bytes] length:[GETReply length] encoding: NSASCIIStringEncoding];
        NSLog(@"Reply: %@", [theReply substringToIndex:100]);
        if ([theReply isEqualToString:@"null"]) {
        }
        else {
            NSError* jsonError;
            NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:GETReply options:NSJSONReadingMutableLeaves error:&jsonError];
            [self insertDataStorageJsonToCoreData:jsonArray forDeviceID:[NSNumber numberWithInt:deviceID]];
        }
    }
    
    [activityView stopAnimating];
    activityView = nil;
}

- (void) setChoiceInMasterView:(NSInteger)choiceInMasterView
{
    _choiceInMasterView = choiceInMasterView;
}

- (void) insertDataStorageJsonToCoreData:(NSArray*)jsonArray forDeviceID:(NSNumber*)deviceID {
    
    NSManagedObjectContext * context = _managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // Get the device
    request.entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"deviceID = %@", deviceID];
    NSError * executeFetchError = nil;
    Device * device = [[context executeFetchRequest:request error:&executeFetchError] firstObject];

    request.entity = [NSEntityDescription entityForName:@"DataStorage" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"generatedBy = %@", device];
    executeFetchError = nil;
    NSArray * data = [context executeFetchRequest:request error:&executeFetchError];
    // Delete all existing ones
    for (NSManagedObject * dt in data) {
        [context deleteObject:dt];
    }
    NSLog(@"Deleted all existing DataStorage with deviceID = %@", deviceID);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"Y-M-d H:mm:s"];
    for (NSDictionary * dict in jsonArray) {
        DataStorage *dataUsageInfo = nil;
        NSDate * timeStamp = [dateFormatter dateFromString:[dict valueForKey:@"timeStamp"]];
        
        // Insert a new one
        dataUsageInfo = [NSEntityDescription
                         insertNewObjectForEntityForName:@"DataStorage" inManagedObjectContext:context];
        dataUsageInfo.timeStamp = timeStamp;
        dataUsageInfo.wifiSent = [NSNumber numberWithInt:[[dict valueForKey:@"wifiSent"]intValue]];
        dataUsageInfo.wifiReceived =  [NSNumber numberWithInt:[[dict valueForKey:@"wifiReceived"]intValue]];
        dataUsageInfo.wwanSent = [NSNumber numberWithInt:[[dict valueForKey:@"wwanSent"]intValue]];
        dataUsageInfo.wwanReceived = [NSNumber numberWithInt:[[dict valueForKey:@"wwanReceived"]intValue]];
        dataUsageInfo.gpsLatitude = [NSNumber numberWithFloat:[[dict valueForKey:@"gpsLatitude"]floatValue]];
        dataUsageInfo.gpsLongitude = [NSNumber numberWithFloat:[[dict valueForKey:@"gpsLongitude"]floatValue]];
        dataUsageInfo.estimateSpeed = [NSNumber numberWithFloat:[[dict valueForKey:@"estimateSpeed"]floatValue]];
        dataUsageInfo.radioAccess = [dict valueForKey:@"radioAccess"];
        
        dataUsageInfo.generatedBy = device;
    }
    NSLog(@"Inserted new DataStorage from online DB with deviceID = %@", deviceID);
    
    [self saveContext];
}

#pragma mark Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier]isEqualToString:@"finishSelectDevices"]) {
        DatePickerForMapTableViewController* vc = (DatePickerForMapTableViewController*)[segue destinationViewController];
        [vc setManagedObjectContext:self.managedObjectContext];
        NSMutableArray* idArray = [NSMutableArray array];
        for (NSIndexPath* index in _cellSelected) {
            [idArray addObject:[NSNumber numberWithInteger:index.row+1]];
        }
        [vc setSelectedDeviceID:[NSArray arrayWithArray:idArray]];
    }
}


@end
