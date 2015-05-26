//
//  GpsOnMapViewController.m
//  IIBProject
//
//  Created by Zhihao Cui on 27/01/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import "GpsOnMapViewController.h"
#import "MapAnnotation.h"
#import "MapAnnotationView.h"
#import "UsageDetailInMapViewController.h"
#import "UsageStatsTableViewController.h"

#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHCenterOfMassMapClusterer.h"
#import "CCHNearCenterMapClusterer.h"
#import "CCHFadeInOutMapAnimator.h"
#import "ClusterAnnotationView.h"

@interface GpsOnMapViewController () <MKMapViewDelegate,CCHMapClusterControllerDelegate>

@property MKUserLocation *userCurrentLocation;

@property (nonatomic, retain) NSMutableArray * allAnnotations;

@property (nonatomic) CCHMapClusterController *mapClusterControllerRed;
@property (nonatomic) CCHMapClusterController *mapClusterControllerBlue;
@property (nonatomic) NSUInteger count;
@property (nonatomic) id<CCHMapClusterer> mapClusterer;
@property (nonatomic) id<CCHMapAnimator> mapAnimator;

@end

@implementation GpsOnMapViewController

bool noDataFound = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    [self drawAnnotationFromLocalData];
    
    // Set up map clustering
    self.mapClusterControllerRed = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterControllerRed.delegate = self;
    
    [self initMapClusterSettings];
    
    [self.mapClusterControllerRed addAnnotations:_allAnnotations withCompletionHandler:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initMapClusterSettings
{
    self.count = 0;

    self.mapClusterControllerRed.cellSize = 60;
    self.mapClusterControllerRed.marginFactor = 0.5;
    
    self.mapClusterer = [[CCHCenterOfMassMapClusterer alloc]init];
//    self.mapClusterer = [[CCHNearCenterMapClusterer alloc] init];
    
    self.mapClusterControllerRed.clusterer = self.mapClusterer;
    self.mapClusterControllerRed.maxZoomLevelForClustering = 16;
    self.mapClusterControllerRed.minUniqueLocationsForClustering = 3;
    
    self.mapAnimator = [[CCHFadeInOutMapAnimator alloc]init];
    self.mapClusterControllerRed.animator = self.mapAnimator;
    
    // Remove all current items from the map
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        [self.mapView removeOverlay:overlay];
    }
}

- (void)drawAnnotationFromLocalData
{
    double latitudeMax = -DBL_MAX, latitudeMin = DBL_MAX, longitudeMax = -DBL_MAX, longitudeMin = DBL_MAX;
    
    if (_allAnnotations == nil) {
        _allAnnotations = [NSMutableArray array];
    }
    else
    {
        [_allAnnotations removeAllObjects];
    }

    for (NSNumber* deviceID in _selectedDeviceID) {
        NSArray *dataReturn = [self getCoreDataWithDeviceID:deviceID];
        
        NSDate * lastDate = nil;
        long amountDataUsed = 0;
        long lastWifiSent=0, lastWifiReceived=0, lastWwanReceived=0, lastWwanSent=0;
        CLLocationCoordinate2D lastCoord;
        
        
        if ([dataReturn count]>0) {
            MapAnnotation *lastAnnotation;
            
            noDataFound = 0;
            
            NSLog(@"Device ID: %@.Number of data given the chosen date: %lu", deviceID, (unsigned long)[dataReturn count]);
            
            for (DataStorage * dt in dataReturn) {
                // In case of data overflow int 32
                long wifiSent = [dt.wifiSent intValue] > 0 ? [dt.wifiSent intValue] : [dt.wifiSent longValue] + (int)pow(2, 32);
                long wifiReceived = [dt.wifiReceived intValue] > 0 ? [dt.wifiReceived intValue] : (long)[dt.wifiReceived intValue] + (long)pow(2, 32);
                long wwanSent = [dt.wwanSent longValue];
                long wwanReceived = [dt.wwanReceived longValue];
                
                MapAnnotation *mapAnnotation = [[MapAnnotation alloc]initWithLocation:CLLocationCoordinate2DMake([dt.gpsLatitude doubleValue], [dt.gpsLongitude doubleValue])];
                mapAnnotation.dataStorage = dt;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"Y-M-d H:mm:s"];
                mapAnnotation.title = [deviceID stringValue]; //[NSString stringWithFormat:@"Time: %@", [formatter stringFromDate:dt.timeStamp]];
                if (lastDate == nil) {
                    mapAnnotation.subTitle = [NSString stringWithFormat:@"Device ID: %@. This is the last point in the section.",deviceID];
                    
                    [mapAnnotation setAverageDataUsage:nil];
                }
                else{
                    NSString *amountData, *distanceTravelled, *timeTravelled;
                    
                    // Time Difference
                    int timeInterval = (int)[lastDate timeIntervalSinceDate:dt.timeStamp];
                    if (timeInterval > 3600) {
                        int hr = timeInterval/3600;
                        int min = (timeInterval - hr * 3600)/60;
                        timeTravelled = [NSString stringWithFormat:@"%i hr %i min", hr, min];
                        
                    }
                    else {
                        timeTravelled = [NSString stringWithFormat:@"%i min %i s",(timeInterval/60),(timeInterval%60)];
                    }
                    
                    // Distance Difference
                    distanceTravelled = [NSString stringWithFormat:@"%.f m",[[[CLLocation alloc]initWithLatitude:lastCoord.latitude longitude:lastCoord.longitude] distanceFromLocation:[[CLLocation alloc]initWithLatitude:[dt.gpsLatitude doubleValue] longitude:[dt.gpsLongitude doubleValue]]]];
                    
                    // Data Usage (difference calculated saperatedly, for usageStatsTableView)
                        // Consider the reboot data refresh
                    NSNumber * awifiR = lastWifiReceived >= wifiReceived ? [NSNumber numberWithFloat:((double)(lastWifiReceived - wifiReceived))/timeInterval] : [NSNumber numberWithFloat:((double)lastWifiReceived)/timeInterval] ;
                    NSNumber * awifiS = lastWifiSent >= wifiSent ? [NSNumber numberWithFloat:((double)(lastWifiSent - wifiSent))/timeInterval] : [NSNumber numberWithFloat:((double)lastWifiSent)/timeInterval];
                    NSNumber * awwanR =lastWwanReceived >= wwanReceived ? [NSNumber numberWithFloat:((double)(lastWwanReceived - wwanReceived))/timeInterval] : [NSNumber numberWithFloat:((double)lastWwanReceived)/timeInterval];
                    NSNumber * awwanS = lastWwanSent >= wwanSent ? [NSNumber numberWithFloat:((double)(lastWwanSent - wwanSent))/timeInterval] : [NSNumber numberWithFloat:((double)lastWwanSent)/timeInterval];
                    if (awwanR.doubleValue > 1e7) {
                        NSLog(@"%@",dt);
                        NSLog(@"Error");
                    }
                    
                    [mapAnnotation setAverageDataUsage:[NSArray arrayWithObjects:awifiR,awifiS,awwanR,awwanS,nil]];
                    
                    // Data Usage (difference in all)
                    long amountDataNow  =  wifiReceived+ wifiSent + wwanSent + wwanReceived;
                    
                    amountDataUsed = amountDataNow > amountDataUsed ? amountDataUsed : amountDataUsed - amountDataNow;
                    
                    amountData = [NSString stringWithFormat:@"%i Kb", (int)amountDataUsed/1000];
                    
                    mapAnnotation.subTitle = [NSString stringWithFormat:@"Used %@ in the past %@ during %@.",amountData, distanceTravelled, timeTravelled];
                    
                }
                
                lastWifiSent = wifiSent;
                lastWifiReceived = wifiReceived;
                lastWwanSent = wwanSent;
                lastWwanReceived = wwanReceived;
                
                amountDataUsed = lastWifiSent + lastWifiReceived + lastWwanSent + lastWwanReceived;
                lastCoord = CLLocationCoordinate2DMake([dt.gpsLatitude doubleValue], [dt.gpsLongitude doubleValue]);
                lastDate = dt.timeStamp;
                
                [_allAnnotations addObject:mapAnnotation];
                
                latitudeMax = [dt.gpsLatitude doubleValue]>latitudeMax ? [dt.gpsLatitude doubleValue] : latitudeMax;
                latitudeMin = [dt.gpsLatitude doubleValue]<latitudeMin ? [dt.gpsLatitude doubleValue] : latitudeMin;
                longitudeMax = [dt.gpsLongitude doubleValue]>longitudeMax ? [dt.gpsLongitude doubleValue] : longitudeMax;
                longitudeMin = [dt.gpsLongitude doubleValue]<longitudeMin ? [dt.gpsLongitude doubleValue] : longitudeMin;
            }
            
            lastAnnotation = nil;
        }
        else
        {
            noDataFound = 1;
        }
    }
    
    if (noDataFound) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                          message:@"No available data from your date selection."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
        [message show];
        return;
    }
    
    MKCoordinateRegion region;
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeMax - latitudeMin, longitudeMax - longitudeMin);
    
    CLLocationCoordinate2D location;
    location.latitude = (latitudeMax + latitudeMin) / 2;
    location.longitude = (longitudeMax + longitudeMin) / 2;
    region.span = span;
    region.center = location;
//
//    //    // Add a annotation at the span centre
//    //    MapAnnotation *mapAnnotation = [[MapAnnotation alloc]initWithLocation:location];
//    //    [_mapView addAnnotation:mapAnnotation];
//    
//    [_mapView addAnnotations:_allAnnotations];
//    
    [_mapView setRegion:region animated:YES];
}

#pragma mark Cluster Controller

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = mapClusterAnnotation.annotations.count;
    if (numAnnotations > 1) {
//        NSString *unit = numAnnotations > 1 ? @"annotations" : @"annotation";
        NSString *unit = @"data points";
        return [NSString stringWithFormat:@"%tu %@", numAnnotations, unit];
    }
    else {
        return [NSString stringWithFormat:@"Device ID: %@", ((MapAnnotation*)mapClusterAnnotation.annotations.allObjects.firstObject).title];
    }
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = mapClusterAnnotation.annotations.count;
    if (numAnnotations > 1) {
        // Get the device ID from the same cluster
        NSArray * a = [mapClusterAnnotation.annotations.allObjects valueForKey:@"title"];
        NSMutableArray * unique = [NSMutableArray array];
        NSMutableSet * processed = [NSMutableSet set];
        for (NSString * string in a) {
            if ([processed containsObject:string] == NO) {
                [unique addObject:string];
                [processed addObject:string];
            }
        }
        mapClusterAnnotation.uniqueIdNumber = [unique count];
        return [NSString stringWithFormat:@"Device ID: %@",[unique componentsJoinedByString:@", "]];
    }
    else {
        mapClusterAnnotation.uniqueIdNumber = 1;
        return ((MapAnnotation*)mapClusterAnnotation.annotations.allObjects.firstObject).subTitle;
    }
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[self.mapView viewForAnnotation:mapClusterAnnotation];
    clusterAnnotationView.count = mapClusterAnnotation.annotations.count;
    clusterAnnotationView.uniqueLocation = mapClusterAnnotation.isUniqueLocation;
}

#pragma mark - Core Data Methods

- (NSArray *)getCoreDataWithDeviceID:(NSNumber*)deviceID
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *allData = [[NSFetchRequest alloc] init];
    [allData setEntity:[NSEntityDescription entityForName:@"DataStorage" inManagedObjectContext:context]];
    [allData setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    if (self.datePredicate != nil) {
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[self.datePredicate, [NSPredicate predicateWithFormat:@"generatedBy.deviceID = %@",deviceID]]];
        [allData setPredicate:predicate];
    }
    else {
        [allData setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"generatedBy.deviceID = %@",[deviceID stringValue]]]];
    }
    
    NSSortDescriptor *sortDate = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
    [allData setSortDescriptors:@[sortDate]];
    
    NSError * error = nil;
    NSArray * data = [context executeFetchRequest:allData error:&error];
    //error handling goes here
    if (error) {
        NSLog(@"%@",error);
    }
    return data;
}

#pragma mark - Map View Delegate
//
//- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
//    self.userCurrentLocation = aUserLocation;
//    
//    if (noDataFound) {
//        MKCoordinateRegion region;
//        MKCoordinateSpan span;
//        span.latitudeDelta = 0.05;
//        span.longitudeDelta = 0.05;
//        CLLocationCoordinate2D location;
//        location.latitude = _userCurrentLocation.coordinate.latitude;
//        location.longitude = _userCurrentLocation.coordinate.longitude;
//        region.span = span;
//        region.center = location;
//        [_mapView setRegion:region animated:YES];
//    }
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    {
        // If the annotation is the user location, just return nil.
        if ([annotation isKindOfClass:[MKUserLocation class]])
            return nil;
        
        if ([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
            CCHMapClusterAnnotation *CCHannotation = (CCHMapClusterAnnotation*)annotation;
            
            static NSString *identifier = @"clusterAnnotation";
            
            ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            if (clusterAnnotationView) {
                clusterAnnotationView.annotation = annotation;
            } else {
                clusterAnnotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
                clusterAnnotationView.canShowCallout = YES;
            }
            
//            if (CCHannotation.isCluster) {
//                clusterAnnotationView.rightCalloutAccessoryView = nil;
//            }
//            else {
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                clusterAnnotationView.rightCalloutAccessoryView = rightButton;
//            }
            
            CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotation;
            clusterAnnotationView.count = clusterAnnotation.annotations.count;
            clusterAnnotationView.blue = (clusterAnnotation.mapClusterController == self.mapClusterControllerBlue);
            clusterAnnotationView.uniqueLocation = clusterAnnotation.isUniqueLocation;
            return clusterAnnotationView;
        }
        else if ([annotation isKindOfClass:MapAnnotation.class]) {
            
        }

        
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view isKindOfClass:[ClusterAnnotationView class]]) {
        CCHMapClusterAnnotation *annotation = (CCHMapClusterAnnotation*)view.annotation;
//        if (annotation.annotations.count == 1) {
//            [self performSegueWithIdentifier:@"showDetailAtPosition" sender:annotation.annotations.allObjects.firstObject];
//        }
//        else {
            [self performSegueWithIdentifier:@"showUsageStats" sender:annotation];
//        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDetailAtPosition"]) {
        UsageDetailInMapViewController *vc = [segue destinationViewController];
        vc.dataToDisplay = ((MapAnnotation *)sender).dataStorage;
    }
    else if([[segue identifier] isEqualToString:@"showUsageStats"]) {
        UsageStatsTableViewController *vc = [segue destinationViewController];
        [vc setNumberOfPoints:[[(CCHMapClusterAnnotation*)sender annotations]count]];
        [vc setUniqueIdNumber:[(CCHMapClusterAnnotation*)sender uniqueIdNumber]];
        // Calculate average
        double aWifiSent = 0, aWifiReceived = 0, aWwanSent = 0, aWwanReceived = 0;
        BOOL containStartPoint = false;
        for (MapAnnotation* annotation in ((CCHMapClusterAnnotation*)sender).annotations.allObjects) {
            if (annotation.averageDataUsage == nil) {
                containStartPoint = 1;
            }
            else {
//                NSLog(@"WFR:@%@, WFS:%@, WWR:%@, WWS:%@",annotation.averageDataUsage[0],annotation.averageDataUsage[1],annotation.averageDataUsage[2],annotation.averageDataUsage[3]);
                aWifiReceived += [(NSNumber*)annotation.averageDataUsage[0] longValue];
                aWifiSent += [(NSNumber*)annotation.averageDataUsage[1] longValue];
                aWwanReceived += [(NSNumber*)annotation.averageDataUsage[2] longValue];
                aWwanSent += [(NSNumber*)annotation.averageDataUsage[3] longValue];
            }
        }
        
        if (containStartPoint) {
            aWifiReceived = aWifiReceived / ([((CCHMapClusterAnnotation*)sender).annotations.allObjects count]-1);
            aWifiSent = aWifiSent / ([((CCHMapClusterAnnotation*)sender).annotations.allObjects count]-1);
            aWwanReceived = aWwanReceived / ([((CCHMapClusterAnnotation*)sender).annotations.allObjects count]-1);
            aWwanSent = aWwanSent / ([((CCHMapClusterAnnotation*)sender).annotations.allObjects count]-1);
        }
        else {
            aWifiReceived = aWifiReceived / ([((CCHMapClusterAnnotation*)sender).annotations.allObjects count]);
            aWifiSent = aWifiSent / ([((CCHMapClusterAnnotation*)sender).annotations.allObjects count]);
            aWwanReceived = aWwanReceived / ([((CCHMapClusterAnnotation*)sender).annotations.allObjects count]);
            aWwanSent = aWwanSent / ([((CCHMapClusterAnnotation*)sender).annotations.allObjects count]);
        }
        
        NSLog(@"aWFR:@%.2f, aWFS:%.2f, aWWR:%.2f, aWWS:%.2f",aWifiReceived,aWifiSent,aWwanReceived,aWwanSent);
        [vc setAverageDataUsage:[NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat:aWifiReceived],[NSNumber numberWithFloat:aWifiSent],
                                 [NSNumber numberWithFloat:aWwanReceived],[NSNumber numberWithFloat:aWwanSent], nil]];
    }
    
}


- (IBAction)clusterSwitchValueChanged:(id)sender {
    if (_clusterSwitch.on) {
        [self.mapView removeAnnotations:_allAnnotations];
        [self.mapClusterControllerRed addAnnotations:_allAnnotations withCompletionHandler:^(void){NSLog(@"Added to cluster controller");}];
    }
    else{
        [self.mapClusterControllerRed removeAnnotations:_allAnnotations withCompletionHandler:^(void){NSLog(@"All annotations removed from cluster controller");}];
        [self.mapView addAnnotations:_allAnnotations];
    }

}
@end
