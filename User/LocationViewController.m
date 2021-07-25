//
//  LocationViewController.m
//  User
//
//  Created by iCOMPUTERS on 19/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "LocationViewController.h"
#import "config.h"
#import "CSS_Class.h"
#import "Colors.h"
#import "NSString+StringValidation.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "HomeViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Utilities.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define apiURL @"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&sensor=true&key=%@"
//#define GOOGLEPLACE_API_KEY @"AIzaSyBe-77R1y2Z4QnW5EJqVt-E3MwdVFrJIw4"

@interface LocationViewController ()
{
    int nCheckVal;
    NSString *strSourceLat,*strSourceLong,*strSourceAddress, *locationString;
    AppDelegate *appDelegate;
    GMSCameraPosition *lastCameraPosition;
    CLLocationCoordinate2D newCoords;
    CLLocation *myLocation;
    GMSAutocompleteFetcher *fetcher;
    GMSAutocompleteFilter *filter;
    
}

@end

@implementation LocationViewController
@synthesize topView, locationTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setDesignStyles];
    _fromText.text = LocalizedString(@"Your location");
    gotLocation = false;
    [self onLocationUpdateStart];
    cityNameArray = [[NSMutableArray alloc]init];
    placeIdArray = [[NSMutableArray alloc]init];
    
    _fromText.delegate = self;
    _toText.delegate = self;
    
    UITapGestureRecognizer *tapGesture_condition=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ViewOuterTap)];
    tapGesture_condition.cancelsTouchesInView=NO;
    tapGesture_condition.delegate=self;
    [topView addGestureRecognizer:tapGesture_condition];
    
    [self.view bringSubviewToFront:_doneBtn];
    [_doneBtn setHidden:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self LocalizationUpdate];
}

-(void)LocalizationUpdate{
    _fromText.placeholder = LocalizedString(@"   From where?");
    _toText.placeholder = LocalizedString(@"   Where to go?");
    [_doneBtn setTitle:LocalizedString(@"DONE") forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ViewOuterTap
{
    [self.view endEditing:YES];
}


-(void)setDesignStyles
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:topView.frame];
    topView.layer.masksToBounds = NO;
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    topView.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    topView.layer.shadowOpacity = 0.5f;
    topView.layer.shadowPath = shadowPath.CGPath;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    _fromText.leftView = paddingView;
    _fromText.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    _toText.leftView = padding;
    _toText.leftViewMode = UITextFieldViewModeAlways;
    
    [CSS_Class APP_Blackbutton:_doneBtn];
    
}
-(void)onLocationUpdateStart
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestAlwaysAuthorization];
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    [_locationManager stopUpdatingLocation];
    
    myLocation = [locations lastObject];
    
    filter = [[GMSAutocompleteFilter alloc] init];
    
    CLLocationCoordinate2D center =  CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    //GMSVisibleRegion visibleRegion = self.mkap.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                       coordinate:southWest];
    
    //    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
    
    // Create the fetcher.
    fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds filter:filter];
    fetcher.delegate = self;
    
    strSourceLat=[NSString stringWithFormat:@"%.8f", myLocation.coordinate.latitude];
    strSourceLong=[NSString stringWithFormat:@"%.8f", myLocation.coordinate.longitude];
    
    CLGeocoder *geocoder=[[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:myLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks lastObject];
            self->strSourceAddress = [NSString stringWithFormat:@"%@,%@,%@",placemark.name,placemark.locality,placemark.subAdministrativeArea];
            self->nCheckVal=2;
            self->_fromText.text = @"Your location";
            [self->_toText becomeFirstResponder];
        }
        else
        {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
}


-(NSString *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude
{
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:pdblLatitude longitude:pdblLongitude];
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  if (placemark)
                  {
                      NSLog(@"placemark %@",placemark);
                      //String to hold address
                      NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                      NSLog(@"addressDictionary %@", placemark.addressDictionary);
                      
                      NSLog(@"placemark %@",placemark.region);
                      NSLog(@"placemark %@",placemark.country);  // Give Country Name
                      NSLog(@"placemark %@",placemark.locality); // Extract the city name
                      NSLog(@"location %@",placemark.name);
                      NSLog(@"location %@",placemark.ocean);
                      NSLog(@"location %@",placemark.postalCode);
                      NSLog(@"location %@",placemark.subLocality);
                      
                      NSLog(@"location %@",placemark.location);
                      //Print the location to console
                      self->locationString = locatedAt;
                      
                      if (self->nCheckVal ==1)
                      {
                          self->_fromText.text = [Utilities removeNullFromString:self->locationString];
                      }
                      else
                      {
                          self->_toText.text = [Utilities removeNullFromString:self->locationString];
                      }
                      
                      NSLog(@"Pickup Address...%@", self->_fromText.text);
                  }
                  else {
                      NSLog(@"Could not locate");
                      self->locationString = @"";
                  }
              }
     ];
    return locationString;
}

- (void)mapView:(GMSMapView* )mapView idleAtCameraPosition:(GMSCameraPosition* )position
{
    lastCameraPosition = nil;
    lastCameraPosition = position;
    newCoords = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude);
    
    [self getAddressFromLatLon:[[NSString stringWithFormat:@"%f", newCoords.latitude] doubleValue] withLongitude:[[NSString stringWithFormat:@"%f", newCoords.longitude] doubleValue]];
    
    return;
    
}


-(IBAction)backBtn:(id)sender
{
    [_fromText resignFirstResponder];
    [_toText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField==_fromText)
    {
        nCheckVal=1;
        
    }
    else if(textField==_toText)
    {
        nCheckVal=2;
        cityNameArray = [[NSMutableArray alloc]init];
        placeIdArray = [[NSMutableArray alloc]init];
        primaryTextArray = [[NSMutableArray alloc]init];
        
        [locationTableView reloadData];
    }
    
    [_mapView setHidden:YES];
    [locationTableView setHidden:NO];
    [_doneBtn setHidden:YES];
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == _fromText)
    {
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (updatedText.length == 0)
        {
            cityNameArray = [[NSMutableArray alloc]init];
            placeIdArray = [[NSMutableArray alloc]init];
            primaryTextArray = [[NSMutableArray alloc]init];
            
            [fetcher sourceTextHasChanged:@""];
        }
        else
        {
            NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            if (updatedText.length > 50)
            {
                return NO;
            }
            NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            // [self queryGetLocationName: newString];
            
            [fetcher sourceTextHasChanged:newString];
            
            
        }
    }
    else if (textField == _toText)
    {
        NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (updatedText.length == 0)
        {
            
            
            cityNameArray = [[NSMutableArray alloc]init];
            placeIdArray = [[NSMutableArray alloc]init];
            primaryTextArray = [[NSMutableArray alloc]init];
            
            //  [fetcher sourceTextHasChanged:@""];
            [self search:@""];
            
        }
        else
        {
            NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            if (updatedText.length > 50)
            {
                return NO;
            }
            
            NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            [self search:newString];
            
        }
    }
    
    return YES;
}

#pragma mark - Name Search


-(void) search:(NSString *)input {
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    NSString *lat = [NSString stringWithFormat:@"%f,%f",myLocation.coordinate.latitude,myLocation.coordinate.longitude];
    
    
    NSDictionary *params =@{@"input":input,@"location":lat,@"radius":@"500",@"language":@"en",@"key":GOOGLE_API_KEY};
    
    [afn getAddressFromGooglewAutoCompletewithParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
        
        self->cityNameArray = [[NSMutableArray alloc]init];
        self->placeIdArray = [[NSMutableArray alloc]init];
        self->primaryTextArray = [[NSMutableArray alloc]init];
        
        
        if(![response isKindOfClass:[NSNull class]]){
            
            NSDictionary *dictVal= [response valueForKey:@"predictions"];
            
            for (NSDictionary *object in dictVal) {
                
                NSString *str = [[object valueForKey:@"place_id"]stringValue];
                NSString *str2 = [[object valueForKey:@"description"]stringValue];
                
                NSDictionary *dictPayment=[object valueForKey:@"structured_formatting"];
                NSString *secondary_text = [[dictPayment valueForKey:@"secondary_text"]stringValue];
                
                if (secondary_text != nil) {
                    [self->primaryTextArray addObject:secondary_text];
                }
                
                if (str2 != nil) {
                     [self->cityNameArray addObject:str2];
                }
                
                if (str) {
                    [self->placeIdArray addObject:str];
                }
                
                
            }
            
        }
        
        [self->locationTableView reloadData];
        
        
    }];
    
}

- (void)didAutocompleteWithPredictions:(NSArray<GMSAutocompletePrediction *> *)predictions
{
    NSLog(@"PREDICTION...%@", predictions);
    
    cityNameArray = [[NSMutableArray alloc]init];
    placeIdArray = [[NSMutableArray alloc]init];
    primaryTextArray = [[NSMutableArray alloc]init];
    
    
    if (predictions.count !=0)
    {
        NSMutableString *resultsStr = [NSMutableString string];
        for (GMSAutocompletePrediction *prediction in predictions) {
            [resultsStr appendFormat:@"%@\n", [prediction.attributedPrimaryText string]];
            NSLog(@"Result '%@' with placeID %@", prediction.attributedFullText.string, prediction.placeID);
            
            [primaryTextArray addObject:[prediction.attributedPrimaryText string]];
            [cityNameArray addObject:[prediction.attributedFullText string]];
            [placeIdArray addObject:prediction.placeID];
            NSLog(@"Google Data: %@", cityNameArray);
        }
    }
    else
    {
    }
    [locationTableView reloadData];
}

- (void)didFailAutocompleteWithError:(NSError *)error
{
    NSLog(@"Autocomplete: %@", error);
    
}

#pragma mark - Name Search


#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return cityNameArray.count > 0 ? cityNameArray.count :1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    for(UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    NSString *centernameStr;
    NSString *fullAddressStr;
    
    if (indexPath.row ==0)
    {
        cell.textLabel.text = LocalizedString(@"Set Pin Location");
    }
    else
    {
        if (cityNameArray.count >0)
        {
            if(indexPath.row <= primaryTextArray.count-1){
               centernameStr = [primaryTextArray objectAtIndex:indexPath.row];
            }
            fullAddressStr = [cityNameArray objectAtIndex:indexPath.row];
        }
        
        cell.textLabel.text =centernameStr;
        cell.detailTextLabel.text = fullAddressStr;
    }
    
    
    [CSS_Class APP_labelName:cell.textLabel];
    [CSS_Class APP_fieldValue_Small:cell.detailTextLabel];
    
    cell.detailTextLabel.textColor =TEXTCOLOR_LIGHT ;
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell.contentView.superview setClipsToBounds:NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self.view endEditing:YES];
    
    if (indexPath.row ==0)
    {
        if (gotLocation ==false)
        {
            
            if ([_fromText.text isEqualToString:@""]) {
                
                [self->_delegate getLatLong:@"" :@"" :@"" :@"":@"":@""];
                [self backBtn:self];
            }else {
                
                [self->_delegate getLatLong:self-> strSourceLat :self->strSourceLong :@"" :@"":self-> strSourceAddress:@""];
                
                [self backBtn:self];
            }
        }
    }else {
        NSString *placeIdStr = [placeIdArray objectAtIndex:indexPath.row];
        [self getPlaceDetailForReferance:placeIdStr];
    }
    
}

- (void)getPlaceDetailForReferance:(NSString*)strReferance
{
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    
    NSDictionary *params =@{@"key":GOOGLE_API_KEY,@"placeid":strReferance};
    
    [afn getAddressFromGooglePlace:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
        
    
        NSDictionary *dictPayment=[response valueForKey:@"result"];
        NSString *str = [[dictPayment valueForKey:@"formatted_address"]stringValue];
        NSDictionary *dictPayment555=[dictPayment valueForKey:@"geometry"];
        NSDictionary *dictPayment2=[dictPayment555 valueForKey:@"location"];
        
        NSString *str22 = [[dictPayment2 valueForKey:@"lat"]stringValue];
        NSString *str2233 = [[dictPayment2 valueForKey:@"lng"]stringValue];
        
        if (self->nCheckVal==1)
        {
            self->_fromText.text = str ;
            self->strSourceLat=str22;
            self->strSourceLong=str2233;
            self->strSourceAddress=str;
            [self->_toText becomeFirstResponder];
        }
        else
        {
            self->_toText.text = str;
            [self->_delegate getLatLong:self->strSourceLat :self->strSourceLong :str22 :str2233:self->strSourceAddress:self->_toText.text];
            [self backBtn:self];
        }
        
    }];
    
}

-(IBAction)doneBtn:(id)sender
{
    if ([_fromText.text isEqualToString:@""] || [_toText.text isEqualToString:@""])
    {
        //Dont proceed
        [CommenMethods alertviewController_title:LocalizedString(@"Alert") MessageAlert:@"Please enter location to ride" viewController:self okPop:nil];
    }
    else
    {
        NSString *latitudeStr = [NSString stringWithFormat:@"%f", newCoords.latitude];
        NSString *longitudeStr = [NSString stringWithFormat:@"%f", newCoords.longitude];
        [_delegate getLatLong:strSourceLat :strSourceLong :latitudeStr :longitudeStr:strSourceAddress:_toText.text];
        [self backBtn:self];
    }
}



@end
