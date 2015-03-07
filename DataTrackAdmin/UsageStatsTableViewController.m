//
//  UsageStatsTableViewController.m
//  DataTrackAdmin
//
//  Created by Zhihao Cui on 05/03/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import "UsageStatsTableViewController.h"

@interface UsageStatsTableViewController ()

@end

@implementation UsageStatsTableViewController

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Cell"];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Number of users";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.uniqueIdNumber];
            break;
        case 1:
            cell.textLabel.text = @"Number of data points";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.numberOfPoints];
            break;
        case 2:
            cell.textLabel.text = @"Average Wifi Received";
            int wifiR = [(NSNumber*)self.averageDataUsage[0] intValue];
            if (wifiR/60000000 > 0) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f Mb/min",((float)wifiR)/60000000];
            }
            else if (wifiR/60000 > 0) cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f Kb/min",((float)wifiR)/60000];
            else cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f Byte/min",((float)wifiR)/60];
            break;
        case 3:
            cell.textLabel.text = @"Average Wifi Sent";
            int wifiS = [(NSNumber*)self.averageDataUsage[1] intValue];
            if (wifiS/60000 > 0) {
                cell.detailTextLabel.text = cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f Kb/min",((float)wifiS)/60000];
            }
            else {
                cell.detailTextLabel.text = cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f Byte/min",((float)wifiS)/60];
            }
            
            break;
        case 4:
            cell.textLabel.text = @"Average Wwan Received";
            int wwanR = [(NSNumber*)self.averageDataUsage[2] intValue];
            if (wwanR/60000 > 0) {
                cell.detailTextLabel.text = cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f Kb/min",((float)wwanR)/60000];
            }
            else {
                cell.detailTextLabel.text = cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f Byte/min",((float)wwanR)/60];
            }
            
            break;
        case 5:
            cell.textLabel.text = @"Average Wwan Sent";
            int wwanS = [(NSNumber*)self.averageDataUsage[3] intValue];
            if (wwanS/60000 >0) {
                cell.detailTextLabel.text = cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f Kb/min",((float)wwanS)/60000];
            }
            else {
                cell.detailTextLabel.text = cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f Byte/min",((float)wwanS)/60];
            }
            break;
        default:
            break;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
