//
//  DatePickerForMapTableViewController.m
//  IIBProject
//
//  Created by Zhihao Cui on 05/02/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import "DatePickerForMapTableViewController.h"
#import "GpsOnMapViewController.h"

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kTitleKey       @"title"   // key for obtaining the data source item's title
#define kDateKey        @"date"    // key for obtaining the data source item's date value

// keep track of which rows have date cells
#define kDateStartRow   1
#define kDateEndRow     2

static NSString *kSwitchCellID = @"switchCell"; // the cells with switch of all data or not
static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
//static NSString *kOtherCell = @"otherCell";     // the remaining cells at the end

@interface DatePickerForMapTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;

@property (strong, nonatomic) IBOutlet UIDatePicker *pickerView;

@property (strong, nonatomic) UISwitch *switchView;


@end

@implementation DatePickerForMapTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishSelectDate)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // setup our data source
    NSMutableDictionary *itemOne = [@{ kTitleKey : @"Use all data available" } mutableCopy];
    
    NSMutableDictionary *itemTwo = [@{ kTitleKey : @"Start Date",
                                       kDateKey : [NSDate dateWithTimeIntervalSinceNow:-7*24*3600] } mutableCopy];
    NSMutableDictionary *itemThree = [@{ kTitleKey : @"End Date",
                                         kDateKey : [NSDate date] } mutableCopy];
    self.dataArray = @[itemOne, itemTwo, itemThree];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    // obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
    self.pickerCellRowHeight = CGRectGetHeight(pickerViewCellToCheck.frame);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"useAllData"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useAllData"];
    }
    
}

- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            //
            NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
            [targetedDatePicker setDate:[itemData valueForKey:kDateKey] animated:NO];
        }
    }
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.
 
 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if ((indexPath.row == kDateStartRow) ||
        (indexPath.row == kDateEndRow || ([self hasInlineDatePicker] && (indexPath.row == kDateEndRow + 1))))
    {
        hasDate = YES;
    }
    
    return hasDate;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = self.dataArray.count;
        return ++numRows;
    }
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    NSString *cellID = kSwitchCellID;
    
    if ([self indexPathHasPicker:indexPath])
    {
        // the indexPath is the one containing the inline date picker
        cellID = kDatePickerID;     // the current/opened date picker cell
    }
    else if ([self indexPathHasDate:indexPath])
    {
        // the indexPath is one that contains the date information
        cellID = kDateCellID;       // the start/end date cells
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (indexPath.row == 0)
    {
        // we decide here that first cell in the table is not selectable (it's just an indicator)
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        if (self.switchView.on) {
            cell.userInteractionEnabled = NO;
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
        }
        else
        {
            cell.userInteractionEnabled = YES;
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
        }
    }
    
    if ([self indexPathHasDate:indexPath])
    {
        // the indexPath is one that contains the date information
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    // if we have a date picker open whose cell is above the cell we want to update,
    // then we have one more cell than the model allows
    //
    NSInteger modelRow = indexPath.row;
    if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row <= indexPath.row)
    {
        modelRow--;
    }
    
    NSDictionary *itemData = self.dataArray[modelRow];
    
    // proceed to configure our cell
    if ([cellID isEqualToString:kDateCellID])
    {
        // we have either start or end date cells, populate their date field
        //
        cell.textLabel.text = [itemData valueForKey:kTitleKey];
        cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kDateKey]];
    }
    else if ([cellID isEqualToString:kSwitchCellID])
    {
        // this cell is a non-date cell, just assign it's text label
        //
        cell.textLabel.text = [itemData valueForKey:kTitleKey];
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = self.switchView;
        [self.switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"useAllData"]];
        [self.switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kDateCellID)
    {
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Actions

/*! User chose to change the date by changing the values inside the UIDatePicker.
 
 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender
{
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;
    
    // update our data model
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:targetedDatePicker.date forKey:kDateKey];
    
    // update the cell's date string
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
}






- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    
    [[NSUserDefaults standardUserDefaults] setBool:switchControl.on forKey:@"useAllData"];

    
    if (self.datePickerIndexPath != nil) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
        [self.tableView endUpdates];
    }
    
    NSIndexPath* row1ToReload = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath* row2ToReload = [NSIndexPath indexPathForRow:2 inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:row1ToReload, row2ToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)finishSelectDate
{
    CGRect pickerFrame = self.pickerView.frame;
    pickerFrame.origin.y = CGRectGetHeight(self.view.frame);
    
    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = pickerFrame; }
                     completion:^(BOOL finished) {
                         [self.pickerView removeFromSuperview];
                     }];
    [self performSegueWithIdentifier:@"showMapByDate" sender:nil];
}

- (void)getOnlineData {
    
    NSString* fullAddress = [NSString stringWithFormat:@"https://www.zhihaodatatrack.com/Direct/Get/getCurrentDeviceData.php?UUID=%@",[[[UIDevice currentDevice] identifierForVendor]UUIDString]];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    if (self.switchView.on) {
        fullAddress = [fullAddress stringByAppendingString:[NSString stringWithFormat:@"&endDate=%@",[dateFormatter stringFromDate:[self getLatestLocalDataTime]]]];
    }
    else {
        NSDate * startDate = [self.dataArray[1] objectForKey:kDateKey];
        NSDate * endDate = [self.dataArray[2] objectForKey:kDateKey];
        
        fullAddress = [fullAddress stringByAppendingString:[NSString stringWithFormat:@"&beginDate=%@&endDate=%@",[dateFormatter stringFromDate:startDate],[dateFormatter stringFromDate:endDate]]];
    }
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    NSMutableURLRequest *newRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:fullAddress]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    // Upload in background
//    NSOperationQueue *progressQueue = [[NSOperationQueue alloc] init];
//    [progressQueue addOperationWithBlock:^{
    
//        [newRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSURLResponse *response;
    NSError * getError;
        NSData *GETReply = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&getError];
    if (getError) {
        NSLog(@"%@",getError);
    }
        NSString *theReply = [[NSString alloc] initWithBytes:[GETReply bytes] length:[GETReply length] encoding: NSASCIIStringEncoding];
        NSLog(@"Reply: %@", theReply);

        if ([theReply isEqualToString:@"null"]) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Ooops" message:@"You've got all data on the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    
        NSError* jsonError;
        NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:GETReply options:NSJSONReadingMutableLeaves error:&jsonError];
//        NSLog(@"%@",[jsonArray[0] description]);
//    NSLog(@"timeStamp: %@",);
    
    int insertCount = [self insertJsonToCoreData:jsonArray];
//    }];
    
    [activityView stopAnimating];

    

    if (!insertCount) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Ooops" message:@"Fetch data failed, come back later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Success" message:[NSString stringWithFormat:@"Fetched %i new data.",insertCount] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    return;
}

- (NSDate *)getLatestLocalDataTime {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DataStorage"];
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
    [request setSortDescriptors:@[sdSortDate]];
    [request setFetchLimit:1];
    NSError *error;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if ([results count]==0) {
        NSLog(@"%@",error);
    }
    else {
        return ((DataStorage *)results[0]).timeStamp;
    }
    return [NSDate date];
}

- (int) insertJsonToCoreData:(NSArray*)jsonArray {
    int newInsertCount = 0;
    NSManagedObjectContext * context = _managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName:@"DataStorage" inManagedObjectContext:context];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"Y-M-d H:mm:s"];
    for (NSDictionary * dict in jsonArray) {
        DataStorage *dataUsageInfo = nil;
        NSDate * timeStamp = [dateFormatter dateFromString:[dict valueForKey:@"timeStamp"]];
        
        request.predicate = [NSPredicate predicateWithFormat:@"timeStamp = %@", timeStamp];
        NSError * executeFetchError = nil;
        dataUsageInfo = [[context executeFetchRequest:request error:&executeFetchError] lastObject];
        
        if (executeFetchError) {
            NSLog(@"[%@, %@] error looking up date: %@ with error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [dict valueForKey:@"timeStamp"], [executeFetchError localizedDescription]);
        }
        else if (!dataUsageInfo) {
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
            
            newInsertCount++;
        }
        else {
            NSLog(@"Found one existing record with date: %@, ignored.",[dict valueForKey:@"timeStamp"]);
        }
    }

    [self saveContext];
    
    return newInsertCount;
}

#pragma mark Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Yes"]) {
        [self getOnlineData];
    }
    else if ([title isEqualToString:@"No"]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"Successfully fetched data online, view them from local data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    if ([[segue identifier] isEqualToString:@"showMapByDate"]) {
        GpsOnMapViewController *vc = [segue destinationViewController];
        [vc setManagedObjectContext:_managedObjectContext];
        [vc setSelectedDeviceID:_selectedDeviceID];
        if (!self.switchView.on) {
            NSDate * startDate = [self.dataArray[1] objectForKey:kDateKey];
            NSDate * endDate = [self.dataArray[2] objectForKey:kDateKey];
            
            vc.datePredicate = [NSPredicate predicateWithFormat:@"(timeStamp >= %@) && (timeStamp <= %@)", startDate, endDate];
        }
        else{
            vc.datePredicate = nil;
        }
    }
}


@end
