//
//  UsageDetailInMapViewController.m
//  IIBProject
//
//  Created by Zhihao Cui on 28/01/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import "UsageDetailInMapViewController.h"

@interface UsageDetailInMapViewController ()

@end

@implementation UsageDetailInMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Time + Data * 4 + gps * 2 + signal strength + access technology
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"dataDetailInMapIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2  reuseIdentifier:MyIdentifier];
    }
    
    NSDateFormatter *formatter;
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Time";
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"Y-M-d H:mm:s"];
            cell.detailTextLabel.text =[formatter stringFromDate:_dataToDisplay.timeStamp];
            break;
        case 3:
            cell.textLabel.text = @"WiFi Sent";
            long wifiSent = _dataToDisplay.wifiSent.intValue < 0 ? _dataToDisplay.wifiSent.intValue + (int)pow(2, 32) : _dataToDisplay.wifiSent.intValue;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%li bytes",wifiSent];
            break;
        case 4:
            cell.textLabel.text = @"WiFi Received";
            long wifiReceived = _dataToDisplay.wifiReceived.intValue < 0 ? _dataToDisplay.wifiReceived.intValue + (int)pow(2, 32) : _dataToDisplay.wifiReceived.intValue;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%li bytes",wifiReceived];
            break;
        case 5:
            cell.textLabel.text = @"WWAN Sent";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ bytes",_dataToDisplay.wwanSent];
            break;
        case 6:
            cell.textLabel.text = @"WWAN Received";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ bytes",_dataToDisplay.wwanReceived];
            break;
        case 1:
            cell.textLabel.text = @"Longitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.8f", [_dataToDisplay.gpsLongitude doubleValue]];
            break;
        case 2:
            cell.textLabel.text = @"Latitude";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.8f", [_dataToDisplay.gpsLatitude doubleValue]];
            break;
        case 7:
            cell.textLabel.text = @"Signal Strength";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"-%i dB", [_dataToDisplay.signalStrength intValue]];
            break;
        case 8:
            cell.textLabel.text = @"Radio Technology";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _dataToDisplay.radioAccess];
            break;
        default:
            break;
    }
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
