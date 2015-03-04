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

@interface GpsOnMapViewController ()

@property MKUserLocation *userCurrentLocation;

@property (nonatomic, retain) NSMutableArray * allAnnotations;

@end

@implementation GpsOnMapViewController

bool noDataFound = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    [self drawAnnotationFromLocalData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        double amountDataUsed = 0;
        CLLocationCoordinate2D lastCoord;
        
        if ([dataReturn count]>0) {
            
            noDataFound = 0;
            
            NSLog(@"Device ID: %@.Number of data given the chosen date: %lu", deviceID, (unsigned long)[dataReturn count]);
            
            for (DataStorage * dt in dataReturn) {
                MapAnnotation *mapAnnotation = [[MapAnnotation alloc]initWithLocation:CLLocationCoordinate2DMake([dt.gpsLatitude doubleValue], [dt.gpsLongitude doubleValue])];
                mapAnnotation.dataStorage = dt;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"Y-M-d H:mm:s"];
                mapAnnotation.title = [NSString stringWithFormat:@"Time: %@", [formatter stringFromDate:dt.timeStamp]];
                if (lastDate == nil) {
                    mapAnnotation.subTitle = [NSString stringWithFormat:@"Device ID: %@. This is the first point in database.",deviceID];
                }
                else{
                    NSString *amountData, *distanceTravelled, *timeTravelled;
                    
                    int timeInterval = (int)[dt.timeStamp timeIntervalSinceDate:lastDate];
                    timeTravelled = [NSString stringWithFormat:@"%i min %i s",(timeInterval/60),(timeInterval%60)];
                    
                    distanceTravelled = [NSString stringWithFormat:@"%.f m",[[[CLLocation alloc]initWithLatitude:lastCoord.latitude longitude:lastCoord.longitude] distanceFromLocation:[[CLLocation alloc]initWithLatitude:[dt.gpsLatitude doubleValue] longitude:[dt.gpsLongitude doubleValue]]]];
                    
                    double amountDataNow  = [dt.wifiReceived doubleValue] + [dt.wifiSent doubleValue] + [dt.wwanSent doubleValue] + [dt.wwanReceived doubleValue];
                    
                    amountDataUsed = amountDataNow < amountDataUsed ? amountDataNow : amountDataNow - amountDataUsed;
                    
                    amountData = [NSString stringWithFormat:@"%i Kb", (int)amountDataUsed/1000];
                    
                    mapAnnotation.subTitle = [NSString stringWithFormat:@"Device ID: %@. Used %@ in the past %@ during %@.",deviceID,amountData, distanceTravelled, timeTravelled];
                }
                
                amountDataUsed = [dt.wwanReceived doubleValue] + [dt.wwanSent doubleValue] + [dt.wifiReceived doubleValue]+ [dt.wifiSent doubleValue];
                lastCoord = CLLocationCoordinate2DMake([dt.gpsLatitude doubleValue], [dt.gpsLongitude doubleValue]);
                lastDate = dt.timeStamp;
                
                [_allAnnotations addObject:mapAnnotation];
                
    //            [_mapView addAnnotation:mapAnnotation];
                latitudeMax = [dt.gpsLatitude doubleValue]>latitudeMax ? [dt.gpsLatitude doubleValue] : latitudeMax;
                latitudeMin = [dt.gpsLatitude doubleValue]<latitudeMin ? [dt.gpsLatitude doubleValue] : latitudeMin;
                longitudeMax = [dt.gpsLongitude doubleValue]>longitudeMax ? [dt.gpsLongitude doubleValue] : longitudeMax;
                longitudeMin = [dt.gpsLongitude doubleValue]<longitudeMin ? [dt.gpsLongitude doubleValue] : longitudeMin;
            }

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
    
    //    // Add a annotation at the span centre
    //    MapAnnotation *mapAnnotation = [[MapAnnotation alloc]initWithLocation:location];
    //    [_mapView addAnnotation:mapAnnotation];
    
    [_mapView addAnnotations:_allAnnotations];
    
    [_mapView setRegion:region animated:YES];
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
    
    NSSortDescriptor *sortDate = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
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

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    self.userCurrentLocation = aUserLocation;
    
    if (noDataFound) {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.05;
        span.longitudeDelta = 0.05;
        CLLocationCoordinate2D location;
        location.latitude = _userCurrentLocation.coordinate.latitude;
        location.longitude = _userCurrentLocation.coordinate.longitude;
        region.span = span;
        region.center = location;
        [_mapView setRegion:region animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    {
        // If the annotation is the user location, just return nil.
        if ([annotation isKindOfClass:[MKUserLocation class]])
            return nil;
        
        // Handle any custom annotations.
        if ([annotation isKindOfClass:[MapAnnotation class]])
        {
            
            
            // Try to dequeue an existing pin view first.
            MapAnnotationView*    pinView = (MapAnnotationView*)[mapView
                                                                 dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
            
            if (!pinView)
            {
                // If an existing pin view was not available, create one.
                pinView = [[MapAnnotationView alloc] initWithAnnotation:annotation
                                                        reuseIdentifier:@"CustomPinAnnotationView"];
                pinView.pinColor = MKPinAnnotationColorRed;
                pinView.animatesDrop = NO;
                pinView.canShowCallout = YES;
                
                // If appropriate, customize the callout by adding accessory views (code not shown).
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
                pinView.rightCalloutAccessoryView = rightButton;
                //                [rightButton addObserver:self
                //                          forKeyPath:@"selected"
                //                             options:NSKeyValueObservingOptionNew
                //                             context:@"ANSELECTED"];
            }
            else
                pinView.annotation = annotation;
            
            return pinView;
        }
        
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view isKindOfClass:[MapAnnotationView class]]) {
        MapAnnotation *annotation = ((MapAnnotation *)view.annotation);
        [self performSegueWithIdentifier:@"showDetailAtPosition" sender:annotation];
    }
    
    //    NSLog(@"Right button clicked");
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//
//    NSString *action = (__bridge NSString*)context;
//
//    if([action isEqualToString:@"ANSELECTED"]){
//
//        BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
//        if (annotationAppeared) {
//            // clicked on an Annotation
//        }
//        else {
//            // Annotation disselected
//        }
//    }
//}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"showDetailAtPosition"]) {
        UsageDetailInMapViewController *vc = [segue destinationViewController];
        vc.dataToDisplay = ((MapAnnotation *)sender).dataStorage;
    }
    
}


@end
