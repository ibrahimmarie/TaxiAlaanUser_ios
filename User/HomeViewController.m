
//  HomeViewController.m
//  User
//
//  Created by iCOMPUTERS on 12/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HomeViewController.h"
#import "EmailViewController.h"
#import "WalletViewController.h"
#import "YourTripViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "ViewController.h"
#import "CSS_Class.h"
#import "config.h"
#import "Colors.h"
#import "Utilities.h"
#import "ProfileViewController.h"
#import "UIScrollView+EKKeyboardAvoiding.h"
#import "CouponsViewController.h"
#import "PaymentsViewController.h"
#import "HoursCollectionViewCell.h"


#import "CommenMethods.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNHelper.h"
#import "ServiceListCollectionViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+animatedGIF.h"

#import <FLAnimatedImage.h>


#import "LanguageController.h"
#import "UIView+Toast.h"
#import "User-Swift.h"


@interface HomeViewController ()
{
    CLLocation *myLocation;
    NSMutableArray *services;
    GMSCameraPosition *lastCameraPosition;
    CLLocationCoordinate2D newCoords;
    GMSMarker *endLocationMarker, *startLocationMarker ,*markerCarLocation, *lstproviderMarkers,*providerMarkers;
    
    GMSCoordinateBounds *bounds;
    CLGeocoder *geocoder;
    AppDelegate *appDelegate;
    NSTimer *timerLocationUpdate,*timeRequestCheck, *timerDriverLocationUpdate;
    NSString *strServiceID,*strKM,*strProviderCell,*strRating;
    NSString *strSourceAddress,*strDestAddress;
    Boolean *checkDriverLocation;
    
    NSString *strCardID,*strCardLastNo;
    
    UIButton *btnCurrentLocation;
    int* statusSource ;
    NSString* flowStatus;
    NSMutableArray *pointss;
    int nSocketCheck;
    NSArray *waypoints;
    NSString *previousStatus;
    NSTimeInterval  timerMoveMap;
    int countDestination;
    bool statusDestinationTripNormal;
    
}
@property (weak, nonatomic) IBOutlet UIButton *changePaymentBtn;
@property (nonatomic,retain)UIView*mapV;
@property (nonatomic,strong) WalletController *vcWallet;

@end

@implementation HomeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    walletFlag = @"0";
    [self onClearLatLong];
    [self onLocationUpdateStart];
    
    flowStatus = @"";
    strCardID=@"";
    strCardLastNo=@"";
    scheduleStr = @"false";
    LoggedOut = false;
    serviceView_Height = 0;
    
    scheduleNav_Str =@"FALSE";
    
    countDestination = 1;
    previousStatus = @"";
    statusDestinationTripNormal = true;
    timerMoveMap = 0;
    providerMarkers=[[GMSMarker alloc]init];
    
    socketConnectFlag = false;
    _rateToProvider.value=1;
    
    [self onRequestCheck];
    timeRequestCheck= [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(onRequestCheck)
                                                     userInfo:nil
                                                      repeats:YES];
    
    gotLocation = false;
    geocoder = [[CLGeocoder alloc] init];
    
    [_rateScrollView setContentSize:[_rateScrollView frame].size];
    [_rateScrollView setKeyboardAvoidingEnabled:YES];
    
    
    _mkap=[[GMSMapView alloc]initWithFrame:_mapView.frame];
    _mkap.myLocationEnabled = YES;
    _mkap.delegate=self;
    NSError *error;
    NSURL *url1 =[[NSBundle mainBundle] URLForResource:@"map_style" withExtension:@"json"];
    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:url1 error:&error];
    
    if (!style) {
        NSLog(@"The style definition could not be loaded: %@", error);
    }
    _mkap.mapStyle = style;
    [_mapView addSubview:_mkap];
    
    _arrayPolylineGreen = [[NSMutableArray alloc] init];
    _path2 = [[GMSMutablePath alloc]init];
    
    //Current Location Button
    btnCurrentLocation=[[UIButton alloc]initWithFrame:CGRectMake(_mapView.frame.size.width-60, _mapView.frame.origin.y+20, 50, 50)];
    [btnCurrentLocation addTarget:self action:@selector(onLocationUpdateStart) forControlEvents:UIControlEventTouchUpInside];
    [btnCurrentLocation setBackgroundImage:[UIImage imageNamed:@"tracker"] forState:UIControlStateNormal];
    btnCurrentLocation.hidden=YES;
    [_mapView addSubview:btnCurrentLocation];
    
    _LanguageArray = @[@{@"name":@"English",@"code":@"en"},@{@"name":@"Arabic",@"code":@"ar"},@{@"name":@"Kurdish",@"code":@"ckb"}];
    [_BtnEng setTitle:_LanguageArray[0][@"name"] forState:UIControlStateNormal];
    [_BtnArab setTitle:_LanguageArray[1][@"name"] forState:UIControlStateNormal];
    [_BtnKurdi setTitle:_LanguageArray[2][@"name"] forState:UIControlStateNormal];
    
    [_BtnEng addTarget:self action:@selector(changelanguage:) forControlEvents:UIControlEventTouchUpInside];
    [_BtnArab addTarget:self action:@selector(changelanguage:) forControlEvents:UIControlEventTouchUpInside];
    [_BtnKurdi addTarget:self action:@selector(changelanguage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SelectLanguageIndex"]==nil){
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:0] forKey:@"SelectLanguageIndex"];
        [_BtnEng setTintColor:UIColor.yellowColor];
    }else{
        [_BtnKurdi setTintColor:UIColor.whiteColor];
        [_BtnArab setTintColor:UIColor.whiteColor];
    }
    
    [self.view bringSubviewToFront:_mapView];
    [self.view bringSubviewToFront:_menuImgBtn];
    [self.view bringSubviewToFront:_languageView];
    [self.view bringSubviewToFront:_menuBtn];
    [self.view bringSubviewToFront:_whereView];
    [self.view bringSubviewToFront:_btnTemp];
    [self.view bringSubviewToFront:_viewSourceandDestination];
    
    [UIView animateWithDuration:0.2 animations:^{
        self->_initialCommonView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height - 166), self.view.frame.size.width,  166);
        self->_selectCarView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 166);
        
        self->_approximateRateView.frame = CGRectMake(self.view.frame.size.width+5, 0, self.view.frame.size.width, 220);
        [self.view bringSubviewToFront:self->_initialCommonView];
    }];
    //  [self.view bringSubviewToFront:_selectCarView];
    _lblCardName.text = LocalizedString(@"CASH");;
    //[_serviceListCollectionView reloadData];
    [self.view bringSubviewToFront:_sosBtn];
    [self.view bringSubviewToFront:_shareBtn];
    
    [_shareBtn setHidden:YES];
    [_sosBtn setHidden:YES];
    
    hoursArray = [[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    arrServiceList=[[NSMutableArray alloc]init];
    selectedIndex = -1;
    serviceSelectIndex=0;
    
    date_pickerViewContainer                 = [[UIView alloc] init];
    date_datePicker                          = [[UIDatePicker alloc] init];
    date_pickerViewContainer.backgroundColor = [UIColor whiteColor];
    
    
    NSURL *urls = [[NSBundle mainBundle] URLForResource:@"location" withExtension:@"gif"];
    
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:urls]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = CGRectMake(0.0, 0.0, 75.0, 75.0);
    [_imgAnimation addSubview:imageView];
    
    
    [_btnBack addTarget:self action:@selector(onClearLatLong) forControlEvents:UIControlEventTouchDown];
    _BackView.hidden=YES;
    [self.view bringSubviewToFront:_menuView];
    
    
    UITapGestureRecognizer *lpgr = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(touched:)];
    lpgr.numberOfTapsRequired = 2.0;
    lpgr.delegate = self;
    [_serviceListCollectionView addGestureRecognizer:lpgr];
    
    
    [self TapCallView];
    checkDriverLocation = false;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2, 2, _notifyViewCirle.layer.frame.size.width-3, _notifyViewCirle.layer.frame.size.height-3)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.strokeColor = [UIColor blackColor].CGColor;
    maskLayer.lineWidth = 3;
    
    maskLayer.path = path.CGPath;
  
    _notifyViewCirle.layer.mask = maskLayer;
    _notifyViewCirle.layer.masksToBounds = YES;
    
    _userImg.hidden = YES;
    _ServiceImg.hidden = YES;
    
    [self getWeather];
    

   markerView = [[MarkerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-25, (self.view.frame.size.height/2)-70, 50, 70)];
    

    [markerView initDelegateWithDelegate:self];
    [self.view addSubview:markerView];


    statusSource = (int *)1;
    //[self.navigationController setToolbarHidden:YES];
    
    
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    
    NSString *strValue=[NSString stringWithFormat:@"%@ %@",[user valueForKey:UD_TOKEN_TYPE],[user valueForKey:UD_ACCESS_TOKEN]];
    
    NSLog(@"strValue...%@",strValue);

}

-(void)TapCallView{
    
    UITapGestureRecognizer *viber = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viber)];
    viber.numberOfTapsRequired = 1;
    [_viberCall setUserInteractionEnabled:YES];
    [_viberCall addGestureRecognizer:viber];
    
    
    UITapGestureRecognizer *whatsapp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whatsapp)];
    whatsapp.numberOfTapsRequired = 1;
    [_whatsappCall setUserInteractionEnabled:YES];
    [_whatsappCall addGestureRecognizer:whatsapp];
    
    
    
    UITapGestureRecognizer *phone = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phone)];
    phone.numberOfTapsRequired = 1;
    [_phoneCall setUserInteractionEnabled:YES];
    [_phoneCall addGestureRecognizer:phone];
    
    UITapGestureRecognizer *closed = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closed)];
    closed.numberOfTapsRequired = 1;
    [_closeBtn setUserInteractionEnabled:YES];
    [_closeBtn addGestureRecognizer:closed];
    
}

-(void)viber{
    
    NSString *phoneNumber = strProviderCell;
    NSString * const viberScheme = @"viber://";
    NSString * const tel = @"tel";
    NSString * const chat = @"chat";
    NSString *action = @"<user selection, chat or tel>"; // this could be @"chat" or @"tel" depending on the choice of the user
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:viberScheme]]) {
        
        // viber is installed
        NSString *myString;
        if ([action isEqualToString:tel]) {
            myString = [NSString stringWithFormat:@"%@:%@", tel, phoneNumber];
        } else if ([action isEqualToString:chat]) {
            myString = [NSString stringWithFormat:@"%@:%@", chat, phoneNumber];
        }
        
        NSURL *myUrl = [NSURL URLWithString:[viberScheme stringByAppendingString:myString]];
        
        if ([[UIApplication sharedApplication] canOpenURL:myUrl]) {
            [[UIApplication sharedApplication] openURL:myUrl options:@{} completionHandler:nil];
        } else {
            // wrong parameters
        }
        
    } else {
        // viber is not installed
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:@"viber is not installed" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_callView.frame =  CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height+100), self.view.frame.size.width,  185);
    }];
    
}


-(void)whatsapp{
    
    NSString* newString=[NSString stringWithFormat:@"https://api.whatsapp.com/send?phone=%@&text=%@",strProviderCell,@""];
    
    NSURL *whatsappURL = [NSURL URLWithString:newString];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL:whatsappURL options:@{} completionHandler:nil];
        // UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
    }else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:@"whatsapp is not installed" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_callView.frame =  CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height+100), self.view.frame.size.width,  185);
    }];
    
}


-(void)phone{
    
    if ([strProviderCell isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"Alert") message:LocalizedString(@"Driver was not provided the number to call.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:strProviderCell]];
        NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:strProviderCell]];
        
        if ([UIApplication.sharedApplication canOpenURL:phoneUrl])
        {
            [UIApplication.sharedApplication openURL:phoneUrl options:@{} completionHandler:nil];
        }
        else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl])
        {
            [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:nil];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"Alert") message:LocalizedString(@"Your device does not support calling") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];    }
    }
    
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_callView.frame =  CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height+100), self.view.frame.size.width,  185);
    }];
    
    
}

-(void)closed{
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_callView.frame =  CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height+100), self.view.frame.size.width,  185);
    }];
    
    
}

-(void)LocalizationUpdate{
    
    _whereLbl.text = LocalizedString(@"Where to?(Optional)");
    //_lblSource.text = LocalizedString(@"Source");
    // _lblDestination.text = LocalizedString(@"Destination");
    _lookingForproviderLbl.text = LocalizedString(@"Looking for Provider");
    
    [_cancelBtn setTitle:LocalizedString(@"CANCEL REQUEST") forState:UIControlStateNormal];
    [_statusBtn setTitle:LocalizedString(@"CALL") forState:UIControlStateNormal];
    
    [_rejectBtn setTitle:LocalizedString(@"Cancel") forState:UIControlStateNormal];
    [_callBtn setTitle:LocalizedString(@"CALL") forState:UIControlStateNormal];
    _nameLbl.text = LocalizedString(@"Name");
    _lblServiceName.text = LocalizedString(@"BMW");
   // _invoiceIdLbl.text = LocalizedString(@"INVOICE");
    _basefareLbl.text = LocalizedString(@"Base Fare");
    _taxLbl.text = LocalizedString(@"Tax");
    _totalLbl.text = LocalizedString(@"Total");
   // [_paymentBtn setTitle:LocalizedString(@"CONTINUE TO PAY") forState:UIControlStateNormal];
    
   // _lblWaitingforPayment.text = LocalizedString(@"Waiting for payment");
    _distanceFareLbl.text = LocalizedString(@"Distance Fare");
    
   // _lblStaticDiscount.text = LocalizedString(@"Discount");
   // _lblStaticWallet.text = LocalizedString(@"Wallet deduction");
    
    _serviceChargeLbl.text = LocalizedString(@"Service Charge");
   // [_btnChange setTitle:LocalizedString(@"Change") forState:UIControlStateNormal];
    _lblRatewithName.text = LocalizedString(@"Rate your trip");
    
    [_submitBtn setTitle:LocalizedString(@"SUBMIT") forState:UIControlStateNormal];
    _capacityLbl.text = LocalizedString(@"Capacity");
    _fareLbl.text = LocalizedString(@"Base Fare");
    [_changePaymentBtn setTitle:LocalizedString(@"CHANGE") forState:UIControlStateNormal];
    [_selectCarRequestBtn setTitle:LocalizedString(@"REQUEST NOW") forState:UIControlStateNormal];
    
    _useWallet.text = LocalizedString(@"Use Wallet");
    _surgeLbl.text = LocalizedString(@"Due to high demand price may vary");
    _etaLbl.text = LocalizedString(@"ETA");
    _estimatedLbl.text = LocalizedString(@"Estimated Fare");
    [_app_RateRequestBtn setTitle:LocalizedString(@"RIDE NOW") forState:UIControlStateNormal];
    _modelLbl.text = LocalizedString(@"Model");
    _app_RateOptionsLbl.text = LocalizedString(@"Pickup & drop");
    [_scheduleBtn setTitle:LocalizedString(@"SCHEDULE") forState:UIControlStateNormal];
    [_changeBtn setTitle:LocalizedString(@"CHANGE") forState:UIControlStateNormal];
    _lblCardName.text = LocalizedString(@"CASH");
    
    _labelTravel.text = LocalizedString(@"Travel costs");
    _labelDiscount.text = LocalizedString(@"Discount");
    _labelTotal.text = LocalizedString(@"Total");
    
}

-(void)onClearLatLong
{
     strKM=@"";
     strServiceID=@"";
     strRating=@"1";
    _sourceLat =@"";
    _sourceLng =@"";
    _destLat =@"";
    _destLng =@"";
     countDestination = 1;
     _whereView.hidden=NO;
     statusSource = (int*)1;
     statusDestinationTripNormal = true;
     previousStatus = @"";
    
    strSourceAddress = @"";
    strDestAddress = @"";
    
    _lblSource.text = @"";
    _lblDestination.text = @"";
    
    self-> _initialCommonView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self->_initialCommonView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height - 166), self.view.frame.size.width,  166);
        self->_selectCarView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 166);
        
        self->_approximateRateView.frame = CGRectMake(self.view.frame.size.width+5, 0, self.view.frame.size.width, 220);
        [self.view bringSubviewToFront:self->_initialCommonView];
    }];
    [_serviceListCollectionView reloadData];
    [_surgeBgView setHidden:YES];
    _viewSourceandDestination.hidden=YES;
    [_mkap clear];
    GMSPolyline *polyline = nil;
    polyline.map = nil;
    
    _BackView.hidden=YES;
    _menuView.hidden=NO;
    [self.view bringSubviewToFront:_menuView];

    [self getProvidersInCurrentLocation];
    markerView.hidden = NO;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:myLocation.coordinate.latitude
                                 
                                                            longitude:myLocation.coordinate.longitude
                                                                 zoom:16];
    [_mkap animateToCameraPosition:camera];
    markerView.hidden = NO;
    
}



#pragma mark
#pragma mark - Source and Destination Delegates Method
-(void)getLatLong:(NSString *)SourceLat :(NSString *)sourceLong :(NSString *)destLat :(NSString *)destLong :(NSString *)sourceAddress :(NSString *)destAddress
{
    
    if ([sourceAddress isEqualToString:@""]) {
        
       
        
    } else if (![sourceAddress isEqualToString:@""] && [destAddress isEqualToString:@""]) {
        
        _sourceLat =SourceLat;
        _sourceLng =sourceLong;
        strSourceAddress=sourceAddress;
        _viewSourceandDestination.hidden=NO;
        _whereView.hidden=YES;
        _lblSource.text=strSourceAddress;
        _menuView.hidden=YES;
        _BackView.hidden=NO;
        [self.view bringSubviewToFront:_BackView];
        
        statusSource = (int*)2;
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([_sourceLat doubleValue], [_sourceLng doubleValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.icon = [UIImage imageNamed:@"ic_origin_selected_marker"];
        marker.map = _mkap;
        [_mkap animateWithCameraUpdate:[GMSCameraUpdate scrollByX:-60 Y:-60]];
        
        
        
    }else if (![sourceAddress isEqualToString:@""] && ![destAddress isEqualToString:@""]){
        
        markerView.hidden = YES;
        _sourceLat =SourceLat;
        _sourceLng =sourceLong;
        strSourceAddress=sourceAddress;
        _viewSourceandDestination.hidden=NO;
        _whereView.hidden=YES;
        _lblSource.text=strSourceAddress;
        _menuView.hidden=YES;
        _BackView.hidden=NO;
        
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([_sourceLat doubleValue], [_sourceLng doubleValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.icon = [UIImage imageNamed:@"ic_origin_selected_marker"];
        marker.map = _mkap;
        
        _destLat =destLat;
        _destLng =destLong;
        strDestAddress=destAddress;
        _lblDestination.text=strDestAddress;
        statusSource = (int*)2;
        
        CLLocationCoordinate2D position2 = CLLocationCoordinate2DMake([_destLat doubleValue], [_destLng doubleValue]);
        GMSMarker *marker2 = [GMSMarker markerWithPosition:position2];
        marker2.icon = [UIImage imageNamed:@"ic_dest_selected_marker"];
        marker2.map = _mkap;
        
        
        
        [self.view bringSubviewToFront:_BackView];
    
        [self getPath];
 
    }
 

    //[self loadMapView];
   // [_serviceListCollectionView reloadData];
}

#pragma mark
#pragma mark - Choose Payment Delegates Method
-(void)onChangePaymentMode:(NSDictionary *)choosedPayment
{
    //strCardID=[choosedPayment valueForKey:@"card_id"] ;
    //strCardLastNo=[choosedPayment valueForKey:@"last_four"];
    
    if ([strCardID isEqualToString:@""])
    {
        _imgCard.image=[UIImage imageNamed:@"money_icon"];
        _lblCardName.text=LocalizedString(@"CASH");
    }
    else
    {
        // _imgCard.image=[UIImage imageNamed:@"visa"];
        // _lblCardName.text=[NSString stringWithFormat:@"XXXX-XXXX-XXXX-%@",[choosedPayment valueForKey:@"last_four"]];
        _lblCardName.text=LocalizedString(@"CASH");
    }
}

#pragma mark
#pragma mark - Get Current Location

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


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    //    btnCurrentLocation.hidden=YES;
    [_locationManager stopUpdatingLocation];
    
    myLocation = [locations lastObject];
    NSLog(@"Location: %@", [NSString stringWithFormat:@"%.8f", myLocation.coordinate.latitude]);
    NSLog(@"Location: %@", [NSString stringWithFormat:@"%.8f", myLocation.coordinate.longitude]);
    
    NSString *strLat=[NSString stringWithFormat:@"%.8f", myLocation.coordinate.latitude];
    NSString *strLong=[NSString stringWithFormat:@"%.8f", myLocation.coordinate.longitude];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:myLocation.coordinate.latitude
                                 
                                                            longitude:myLocation.coordinate.longitude
                                                                 zoom:16];
    
    [_mkap animateToCameraPosition:camera];
    NSLog(@"Resolving the Address");
    
    [geocoder reverseGeocodeLocation:myLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks lastObject];
            self->currentAddress = [Utilities removeNullFromString: [NSString stringWithFormat:@"%@,%@,%@",placemark.name,placemark.locality,placemark.subAdministrativeArea]];
            NSLog(@"Placemark %@",self->currentAddress);
            
            //Location Update to server
            NSDictionary *params=@{@"latitude":strLat,@"longitude":strLong,@"address":self->currentAddress};
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:MD_UPDATELOCATION withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
                if (response) {
                    
                }
            }];
        }
        else
        {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
}


-(void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{
    if ([marker.userData isEqualToString:@"PICKUP"])
    {
        dragMarkerStr =@"PICKUP";
        NSLog(@"marker dragged to FromLocation: %f,%f", marker.position.latitude, marker.position.longitude);
        _sourceLat = [NSString stringWithFormat:@"%f", marker.position.latitude];
        _sourceLng = [NSString stringWithFormat:@"%f", marker.position.longitude];
        
        NSString *PickupAddressStr = [NSString stringWithFormat:@"%@",[self getAddressFromLatLon:[[NSString stringWithFormat:@"%f", marker.position.latitude] doubleValue] withLongitude:[[NSString stringWithFormat:@"%f", marker.position.longitude] doubleValue]]];
        _lblSource.text = [Utilities removeNullFromString:PickupAddressStr];
        NSLog(@"Pickup Address...%@", _lblSource.text);
    }
    else
    {
        dragMarkerStr =@"DROP";
        
        NSLog(@"marker dragged to FromLocation: %f,%f", marker.position.latitude, marker.position.longitude);
        _destLat = [NSString stringWithFormat:@"%f", marker.position.latitude];
        _destLng = [NSString stringWithFormat:@"%f", marker.position.longitude];
        
        NSString *addressStr = [NSString stringWithFormat:@"%@",[self getAddressFromLatLon:[_destLat doubleValue] withLongitude:[_destLng doubleValue]]];
        _lblDestination.text = [Utilities removeNullFromString:addressStr];
        NSLog(@"Pickup Address...%@", _lblDestination.text);
    }
    [self onMapReload];
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
                  
                      //String to hold address
                      NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
      
                      self->locationString = locatedAt;
                      
                      if ([self->dragMarkerStr isEqualToString:@"DROP"])
                      {
                          self->_lblDestination.text = self->locationString;
                      }
                      else
                      {
                          self->_lblSource.text = self->locationString;
                      }
                  }
                  else {
                      NSLog(@"Could not locate");
                      self->locationString = @"";
                  }
              }
     ];
    [self onMapReload];
    [_serviceListCollectionView reloadData];
    return locationString;
}


#pragma mark - Own Method

-(void)onGetProfile:(int)status
{
    if ([appDelegate internetConnected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
      
       // [appDelegate onStartLoader];
        
        NSString* UDID_Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
        NSLog(@"output is : %@", UDID_Identifier);
        
        NSDictionary *params=@{@"device_token":appDelegate.strDeviceToken,@"device_type":@"ios", @"device_id":UDID_Identifier};
        
        [afn getDataFromPath:MD_GETPROFILE withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
          //  [self->appDelegate onEndLoader];
            if (response)
            {
                NSLog(@"GET PROFILE...%@", response);
                
                 [self->_walletView setHidden:YES];
                
                NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                if( [response[@"picture"] isKindOfClass:[NSNull class]] )
                    [user setValue:@"" forKey:UD_PROFILE_IMG];
                else
                    [user setValue:response[@"picture"] forKey:UD_PROFILE_IMG];
                
                
                NSString *balance =[NSString stringWithFormat:@"%@",[response valueForKey:@"balance"]];
                
                NSString *wallet_id =[NSString stringWithFormat:@"%@",[response valueForKey:@"wallet_id"]];
                
                [user setValue:response[@"first_name"] forKey:UD_PROFILE_NAME];
                [user setValue:response[@"last_name"]  forKey:UD_PROFILE_NAME_LAST];
                [user setValue:response[@"currency"] forKey:@"currency"];
                [user setValue:balance forKey:@"balance"];
                [user setValue:wallet_id forKey:@"wallet_id"];
                [user setValue:response[@"share_key"] forKey:@"share_key"];
                
                [user synchronize];
                
                self->categoryStr = @"SMALL";
                [self onGetService];
                
                if (status == 1) {
                    [user setInteger:2 forKey:@"prograss"];
                    [self->leftMenuViewClass awakeFromNib];
                    
                }else {
                    
                    [self onGetService];
                }
                
                
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    //                    [CommenMethods onRefreshToken];
                    
                    [self logOut];
                }
            }
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}

-(void)onGetService
{
    if ([appDelegate internetConnected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:MD_GET_SERVICE withParamData:nil withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            
            
            self->  arrServiceList=[[NSMutableArray alloc]init];
            self->  serviceNameArray_Small = [[NSMutableArray alloc]init];
            self->  serviceImageArray_Small = [[NSMutableArray alloc]init];
            self->  serviceIDArray_Small = [[NSMutableArray alloc]init];
            
            self-> serviceNameArray_Big = [[NSMutableArray alloc]init];
            self-> serviceImageArray_Big = [[NSMutableArray alloc]init];
            self-> serviceIDArray_Big = [[NSMutableArray alloc]init];
            
            if (response)
            {
                NSLog(@"Services....%@", response);
                
                self->  arrServiceList= response;
                
                for (int i=0; i<[response count]; i++)
                {
                    NSDictionary *dict = [response objectAtIndex:i];
                    
                    [self->serviceImageArray_Small addObject:[dict valueForKey:@"image"]];
                    [self->serviceIDArray_Small addObject:[dict valueForKey:@"id"]];
                    [self->serviceNameArray_Small addObject:[dict valueForKey:@"name"]];
                    
                }
                
                [self->_serviceListCollectionView reloadData];
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                       [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    
                    [self logOut];
                }
            }
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setDesignStyles
{
    [_smallPackageBtn setBackgroundColor:BLACKCOLOR];
    _smallPackageBtn.layer.cornerRadius = _smallPackageBtn.frame.size.height/2;
    _smallPackageBtn.clipsToBounds = YES;
    [_smallPackageBtn setTitleColor:RGB(255, 255, 255)
                           forState:UIControlStateNormal];
    
    _bigPackageBtn.layer.cornerRadius = _bigPackageBtn.frame.size.height/2;
    _bigPackageBtn.clipsToBounds = YES;
    
    [_bigPackageBtn setBackgroundColor:RGB(255, 255, 255)];
    [_bigPackageBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    
    [CSS_Class APP_Blackbutton:_statusBtn];
    [CSS_Class APP_Blackbutton:_scheduleBtn];
    
   // [CSS_Class APP_Blackbutton:_rejectBtn];
    //[CSS_Class APP_BlackbuttonPayment:_paymentBtn];
    [CSS_Class APP_Blackbutton:_submitBtn];
    
   // [CSS_Class APP_Blackbutton:_callBtn];
    [CSS_Class APP_Blackbutton:_selectCarRequestBtn];
    [CSS_Class APP_Blackbutton:_app_RateRequestBtn];
    [CSS_Class APP_SocialLabelName:_useWallet];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_notifyView.frame];
    _notifyView.layer.masksToBounds = NO;
    _notifyView.layer.shadowColor = [UIColor blackColor].CGColor;
    _notifyView.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    _notifyView.layer.shadowOpacity = 0.5f;
    _notifyView.layer.shadowPath = shadowPath.CGPath;
    
    UIBezierPath *_initialView = [UIBezierPath bezierPathWithRect:_initialCommonView.frame];
    _initialCommonView.layer.masksToBounds = NO;
    _initialCommonView.layer.shadowColor = [UIColor blackColor].CGColor;
    _initialCommonView.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    _initialCommonView.layer.shadowOpacity = 0.5f;
    _initialCommonView.layer.shadowPath = _initialView.CGPath;
    
    UIBezierPath *shadows = [UIBezierPath bezierPathWithRect:_commonRateView.frame];
    _commonRateView.layer.masksToBounds = NO;
    _commonRateView.layer.shadowColor = [UIColor blackColor].CGColor;
    _commonRateView.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    _commonRateView.layer.shadowOpacity = 0.5f;
    _commonRateView.layer.shadowPath = shadows.CGPath;
    
    UIBezierPath *whereViewPath = [UIBezierPath bezierPathWithRect:_whereView.bounds];
    _whereView.layer.masksToBounds = NO;
    _whereView.layer.shadowColor = [UIColor blackColor].CGColor;
    _whereView.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    _whereView.layer.shadowOpacity = 0.5f;
    _whereView.layer.shadowPath = whereViewPath.CGPath;
    
    UIBezierPath *viewSourceandDestinationPath = [UIBezierPath bezierPathWithRect:_viewSourceandDestination.bounds];
    _viewSourceandDestination.layer.masksToBounds = NO;
    _viewSourceandDestination.layer.shadowColor = [UIColor blackColor].CGColor;
    _viewSourceandDestination.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    _viewSourceandDestination.layer.shadowOpacity = 0.5f;
    _viewSourceandDestination.layer.shadowPath = viewSourceandDestinationPath.CGPath;
    
    _userImg.layer.cornerRadius = _userImg.frame.size.height/2;
    _userImg.clipsToBounds = YES;
    
    _surge_XViewLbl.layer.cornerRadius = _surge_XViewLbl.frame.size.height/2;
    _surge_XViewLbl.clipsToBounds = YES;
    
    _ratingProviderImg.layer.cornerRadius = _ratingProviderImg.frame.size.height/2;
    _ratingProviderImg.clipsToBounds = YES;
    
    [CSS_Class APP_textfield_Outfocus:_commentsText];
    
    [_surgeBgView setHidden:YES];
    
    
    
  /*  _paymentBtn.titleLabel.font = [UIFont fontWithName:@"ClanPro-NarrMedium" size:16];
    _paymentBtn.frame = CGRectMake(_paymentBtn.frame.origin.x, _paymentBtn.frame.origin.y, _paymentBtn.frame.size.width, 70);
    _paymentBtn.layer.cornerRadius = 5.0f;
    
    [_paymentBtn setTitleColor:RGB(255,255,255) forState:UIControlStateNormal];
    [_paymentBtn setTitleColor:RGB(255,255,255) forState:UIControlStateSelected];
    [_paymentBtn.titleLabel.text uppercaseString];
    _paymentBtn.clipsToBounds = NO;
    _paymentBtn.backgroundColor = BLACKCOLOR;*/
}

-(IBAction)menuBtn:(id)sender
{
    [leftMenuViewClass setHidden:NO];
    [self LeftMenuView];
}

-(void)viewWillAppear:(BOOL)animated
{
    UITapGestureRecognizer *tapGesture_condition=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ViewOuterTap)];
    tapGesture_condition.cancelsTouchesInView=NO;
    tapGesture_condition.delegate=self;
    [self.view addGestureRecognizer:tapGesture_condition];
    
    leftMenuViewClass = [[[NSBundle mainBundle] loadNibNamed:@"LeftMenuView" owner:self options:nil] objectAtIndex:0];
    [leftMenuViewClass setFrame:CGRectMake(-(self.view.frame.size.width - 100), 0, self.view.frame.size.width - 100, self.view.frame.size.height)];
    
    leftMenuViewClass.LeftMenuViewDelegate =self;
    leftMenuViewClass.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:leftMenuViewClass];
    [leftMenuViewClass setHidden:YES];
    [self setDesignStyles];
    [self setLanguage];
      //[self onGetProfile];
    [self onGetProfile:0];
}

- (void)changelanguage:(UIButton *)sender {
    NSLog(@"%ld",(long)sender.tag);
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:sender.tag] forKey:@"SelectLanguageIndex"];
    [[NSUserDefaults standardUserDefaults]setObject:_LanguageArray[sender.tag][@"code"] forKey:@"LanguageCode"];
    LocalizationSetLanguage(_LanguageArray[sender.tag][@"code"]);
    [self setLanguage];
    
}

-(void)setLanguage
{
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectLanguageIndex"]integerValue] == 0){
        [_BtnEng setTintColor:UIColor.yellowColor];
        [_BtnArab setTintColor:UIColor.whiteColor];
        [_BtnKurdi setTintColor:UIColor.whiteColor];
    }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectLanguageIndex"]integerValue] == 1){
        [_BtnEng setTintColor:UIColor.whiteColor];
        [_BtnKurdi setTintColor:UIColor.whiteColor];
        [_BtnArab setTintColor:UIColor.yellowColor];
    }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectLanguageIndex"]integerValue] == 2){
        [_BtnEng setTintColor:UIColor.whiteColor];
        [_BtnArab setTintColor:UIColor.whiteColor];
        [_BtnKurdi setTintColor:UIColor.yellowColor];
    }
    [self LocalizationUpdate];
}

#pragma mark
#pragma mark - Slide Menu controllers

-(void)LeftMenuView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self->leftMenuViewClass.frame = CGRectMake(0, 0, self.view.frame.size.width - 100,  self.view.frame.size.height);
        
    }];
    waitingBGView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width  ,self.view.frame.size.height)];
    
    [waitingBGView setBackgroundColor:[UIColor blackColor]];
    [waitingBGView setAlpha:0.6];
    [self.view addSubview:waitingBGView];
    [self.view bringSubviewToFront:leftMenuViewClass];
   
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"prograss"];
    [defaults synchronize];
    [leftMenuViewClass awakeFromNib];

    [self onGetProfile:1];
}

- (void)ViewOuterTap
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self->leftMenuViewClass.frame = CGRectMake(-(self.view.frame.size.width - 100), 0, self.view.frame.size.width - 100,  self.view.frame.size.height);
        
    }];
    
    [waitingBGView removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer* )gestureRecognizer shouldReceiveTouch:(UITouch* )touch
{
    if ([touch.view isDescendantOfView:leftMenuViewClass])
    {
        return NO;
    }
    return YES;
}

-(void)yourTripsView
{
    [self ViewOuterTap];
    YourTripViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"YourTripViewController"];
    [self.navigationController pushViewController:wallet animated:YES];
}
-(void)wallet
{
    [self ViewOuterTap];
    // [self.navigationController setToolbarHidden:NO];
    //_vcWallet = [[WalletController alloc]init];
    //[self.navigationController pushViewController:_vcWallet animated:YES];
    //[self presentViewController:_vcWallet animated:true completion:nil];
    WalletController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"walletController"];
    [self.navigationController pushViewController:wallet animated:YES];
    
    // [self presentViewController:wallet animated:YES completion:nil];
}


-(void)helpView
{
    [self ViewOuterTap];
    HelpViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    [self presentViewController:wallet animated:YES completion:nil];
}
-(void)shareView
{
    [self ViewOuterTap];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:[NSURL URLWithString:@"http://taxialaan.com/redirect/store"]];
    [sharingItems addObject:@"\n"];
    [sharingItems addObject:@"Introducer : "];
    [sharingItems addObject:[defaults valueForKey:@"share_key"]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

-(void)settingsView
{
    [self ViewOuterTap];
    LanguageController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LanguageController"];
    controller.page_identifier = @"Profile";
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)profileView
{
    [self ViewOuterTap];
    ProfileViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [self.navigationController pushViewController:wallet animated:YES ];
}

-(void)logOut
{
    
    [self-> timeRequestCheck invalidate];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(LocalizedString(@"Alert!")) message:LocalizedString(@"Are you sure want to logout?") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* no = [UIAlertAction actionWithTitle:LocalizedString(@"NO") style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([self->appDelegate internetConnected])
        {
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [self->appDelegate onStartLoader];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *idStr = [defaults valueForKey:UD_ID];
            NSDictionary *param = @{@"id":idStr};
            
            [afn getDataFromPath:MD_LOGOUT withParamData:param withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
                [self->appDelegate onEndLoader];
                if (response)
                {
                    self->LoggedOut = true;
                    
                    [self ViewOuterTap];
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isLoggedin"];
                    
                    ViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                    [self.navigationController pushViewController:wallet animated:YES];
                }
                else
                {
                    [CommenMethods alertviewController_title:LocalizedString(@"Alert") MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
            }];
        }
        else
        {
            [CommenMethods alertviewController_title:LocalizedString(@"Alert") MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
        }
        
        
    }];
    [alertController addAction:ok];
    [alertController addAction:no];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)payments
{
    [self ViewOuterTap];
    PaymentsViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"PaymentsViewController"];
    wallet.fromWhereStr = @"LEFT MENU";
    [self.navigationController pushViewController:wallet animated:YES];
}

-(void)coupons
{
    [self ViewOuterTap];
    CouponsViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"CouponsViewController"];
    [self.navigationController pushViewController:wallet animated:YES];
}

-(IBAction)rejectBtn:(id)sender
{
    [_statusView setHidden:YES];
}

-(IBAction)callBtn:(id)sender
{
    
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_callView.frame =  CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height -100), self.view.frame.size.width,  185);
    }];
    
    [self.view bringSubviewToFront:_callView];
    
}

- (IBAction)statusBtnAction:(id)sender
{
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_notifyView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height +50), self.view.frame.size.width,  185);
    }];
    
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_commonRateView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height - 300), self.view.frame.size.width,  300);
        
        [self.view bringSubviewToFront:self->_commonRateView];
        
    }];
}

- (IBAction)paymentBtnAction:(id)sender
{
    if ([appDelegate internetConnected])
    {
        
        NSString *strReqID=[[NSUserDefaults standardUserDefaults] valueForKey:UD_REQUESTID];
        NSDictionary *params=@{@"request_id":strReqID};
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_PAYMENT withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [self->appDelegate onEndLoader];
            if (response)
            {
               
                  [CommenMethods alertviewController_title:@"" MessageAlert:[response objectForKey:@"message"] viewController:self okPop:NO];
               /* [UIView animateWithDuration:0.3 animations:^{
                    
                    self->_invoiceView.frame = CGRectMake( -self.view.frame.size.width, 0, self.view.frame.size.width, 300);
                    
                    self->_rateViewView.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
                    
                }];*/
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    //                    [CommenMethods onRefreshToken];
                    [self logOut];
                }
                else if ([errorcode intValue]==2)
                {
                    if ([error objectForKey:@"rating"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"rating"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                    else if([error objectForKey:@"comments"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"comments"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                    else if([error objectForKey:@"is_favorite"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"is_favorite"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                    
                }
                
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
    
}
- (IBAction)didChangeValue:(HCSStarRatingView *)sender
{
    //%.02f
    strRating=[NSString stringWithFormat:@"%.f",sender.value];
    NSLog(@"%@",strRating);
}

- (IBAction)submitBtnAction:(id)sender
{
    if ([appDelegate internetConnected])
    {
        NSString *strReqID=[[NSUserDefaults standardUserDefaults] valueForKey:UD_REQUESTID];
        NSDictionary *params=@{@"request_id":strReqID,@"rating":strRating,@"comment":_commentsText.text};
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_RATE_PROVIDER withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [self->appDelegate onEndLoader];
            if (response)
            {
                self->_rateToProvider.value=1;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_REQUESTID];
                [self onClearLatLong];
                self->strRating=@"1";
                self-> _commentsText.text=@"";
                [UIView animateWithDuration:0.45 animations:^{
                    self->_commonRateView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height +30), self.view.frame.size.width,  300);
                }];
                
                self->_initialCommonView.hidden = NO;
       
                [UIView animateWithDuration:0.45 animations:^{
                    
                    self->_notifyView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height +20), self.view.frame.size.width,  220);
                }];
          
               
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    //                    [CommenMethods onRefreshToken];
                    [self logOut];
                }
                else if ([errorcode intValue]==2)
                {
                    if ([error objectForKey:@"rating"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"rating"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                    else if([error objectForKey:@"comments"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"comments"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                    else if([error objectForKey:@"is_favorite"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"is_favorite"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                    
                }
                
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==_commentsText)
    {
        [_commentsText resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(IBAction)selectCarRequestBtn:(id)sender
{
    if ([strDestAddress isEqualToString:@""]||strDestAddress == (id)[NSNull null]||strDestAddress.length==0)
    {
        [self app_RateRequestBtn:self];
    }
    else
    {
        [self onGetFareEsitmate];
        
    }
    
}

-(IBAction)walletBtnAction:(id)sender
{
    if ([walletFlag isEqualToString:@"0"])
    {
        walletFlag = @"1";
        _checkBoxImg.image = [UIImage imageNamed:@"checked"];
        
    }
    else
    {
        walletFlag = @"0";
        _checkBoxImg.image = [UIImage imageNamed:@"uncheck"];
    }
}

-(IBAction)app_RateRequestBtn:(id)sender
{
    
    NSString *strLat=[NSString stringWithFormat:@"%.8f", myLocation.coordinate.latitude];
    NSString *strLong=[NSString stringWithFormat:@"%.8f", myLocation.coordinate.longitude];
    
    if ([appDelegate internetConnected])
    {
        NSString *strPay=@"";
        if ([strCardID isEqualToString:@""])
        {
            strPay=@"CASH";
            //  [CommenMethods alertviewController_title:LocalizedString(@"ALERT")  MessageAlert:@"Tilføj venligst et kort for at fortsætte" viewController:self okPop:NO];
        }
        else
            strPay=[NSString stringWithFormat:@"CARD"];
        NSDictionary *params;
        if ([scheduleStr isEqualToString:@"true"])
        {
            
            NSArray *dateArr = [scheduleDate.text componentsSeparatedByString:@" "];
            NSString *schDate = [dateArr objectAtIndex:0];
            NSString *schtime = [dateArr objectAtIndex:1];
            
            params=@{@"s_latitude":_sourceLat,@"s_longitude":_sourceLng,@"d_latitude":_destLat,@"d_longitude":_destLng,@"service_type":strServiceID,@"distance":strKM,@"payment_mode":strPay,@"card_id":strCardID,@"s_address":strSourceAddress,@"d_address":strDestAddress, @"use_wallet":walletFlag, @"schedule_date": schDate, @"schedule_time": schtime};
        }
        else
        {
            if([strDestAddress isEqualToString:@""]||[_destLng isEqualToString:@""]||[_destLat isEqualToString:@""])
            {
                params=@{@"flow":@"OPTIONAL",@"s_latitude":strLat,@"s_longitude":strLong,@"service_type":strServiceID,@"distance":strKM,@"payment_mode":strPay,@"card_id":strCardID,@"s_address":currentAddress, @"use_wallet":walletFlag};
            }
            
            else
            {
                params=@{@"flow":@"NORMAL",@"s_latitude":_sourceLat,@"s_longitude":_sourceLng,@"d_latitude":_destLat,@"d_longitude":_destLng,@"service_type":strServiceID,@"distance":strKM,@"payment_mode":strPay,@"card_id":strCardID,@"s_address":strSourceAddress,@"d_address":strDestAddress, @"use_wallet":walletFlag};
            }
        }
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_CREATE_REQUEST withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [self->appDelegate onEndLoader];
            if (response)
            {
                [self->_surgeBgView setHidden:YES];
                
                if ([self->scheduleStr isEqualToString:@"true"])
                {
                    self->scheduleNav_Str =@"TRUE";
                }
                NSString *reqStr = [[response objectForKey:@"request_id"] stringValue];
                if ([reqStr isEqualToString:@""] || reqStr.length ==0)
                {
                    [CommenMethods alertviewController_title:LocalizedString(@"ALERT")  MessageAlert:[response objectForKey:@"message"] viewController:self okPop:NO];
                }
                else
                {
                    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                    [user setValue:[NSString stringWithFormat:@"%@",response[@"request_id"]] forKey:UD_REQUESTID];
                    [UIView animateWithDuration:0.45 animations:^{
                        
                        self->_initialCommonView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height +30), self.view.frame.size.width,  300);
                        
                        self-> _selectCarView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 300);
                        self->_approximateRateView.frame = CGRectMake(self.view.frame.size.width+5, 0, self.view.frame.size.width, 300);
                        self-> _lblCardName.text = LocalizedString(@"CASH");;
                        
                    }];
                    
                    [self->_serviceListCollectionView reloadData];
                    [self->_requestWaitingView setHidden:NO];
                    [UIView animateWithDuration:0.45 animations:^{
                        
                        self->_requestWaitingView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                        
                        [self.view bringSubviewToFront:self->_requestWaitingView];
                    }];
                    
                }
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    if ([error objectForKey:@"error"])
                        [CommenMethods alertviewController_title:@"" MessageAlert:[error objectForKey:@"error"] viewController:self okPop:NO];
                    else
                        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    //                    [CommenMethods onRefreshToken];
                    [self logOut];
                }
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
    
}

-(void)helpPopUp
{
    {
        backgroundView_Pop = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [backgroundView_Pop setBackgroundColor:[UIColor blackColor]];
        [backgroundView_Pop setAlpha:0.6];
        [self.view addSubview:backgroundView_Pop];
        
        [UIView animateWithDuration:0.45 animations:^{
            
            self->_serviceDetailsView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height-300+self->serviceView_Height), self.view.frame.size.width, 300);
        }];
        
        _serviceDetailsView.clipsToBounds = NO;
        _serviceDetailsView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_serviceDetailsView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
        [tapGestureRecognizer setDelegate:self];
        [backgroundView_Pop addGestureRecognizer:tapGestureRecognizer];
    }
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self closeActionPop];
}


-(IBAction)pickUpDrop:(id)sender
{
    pickUpDrop.selected = YES;
    fixedHrs.selected = NO;
    
    [_app_RateHelpLbl setText:LocalizedString(@"Including all other charges")];
    [_app_RateOptionsLbl setText:LocalizedString(@"Pickup & Drop")];
    [_pickupImg setHidden:NO];
    [_hoursCollectionView setHidden:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_initialCommonView.frame = CGRectMake(0, self.view.frame.size.height-166, self.view.frame.size.width,  166);
        self-> _selectCarView.frame = CGRectMake( -self.view.frame.size.width, 0, self.view.frame.size.width, 166);
        self->_approximateRateView.frame = CGRectMake(0, 0, self.view.frame.size.width, 180);
        self->_surgeBgView.frame = CGRectMake(0,-80, self.view.frame.size.width, 80);
        [self.view bringSubviewToFront:self->_initialCommonView];
        
    }];
}


-(IBAction)fixedHrs:(id)sender
{
    fixedHrs.selected = YES;
    pickUpDrop.selected = NO;
    
    [_app_RateHelpLbl setText:LocalizedString(@"How many hours do you need")];
    [_app_RateOptionsLbl setText:LocalizedString(@"Fixed hours")];
    [_pickupImg setHidden:YES];
    [_hoursCollectionView setHidden:NO];
    [_hoursCollectionView reloadData];
    [_serviceListCollectionView reloadData];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self->_selectCarView.frame = CGRectMake( -self.view.frame.size.width, 0, self.view.frame.size.width, 300);
        self->_approximateRateView.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
        
    }];
}

-(IBAction)changePaymentBtn:(id)sender
{
    PaymentsViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"PaymentsViewController"];
    wallet.fromWhereStr = @"HOME";
    wallet.delegate=self;
    [self presentViewController:wallet animated:YES completion:nil];
}

-(IBAction)whereBtn:(id)sender
{
    LocationViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
    wallet.delegate=self;
    if ([currentAddress isEqualToString:@""])
    {
        currentAddress = @"";
    }
    else
    {
        
    }
    wallet.currentAddress = currentAddress;
    [self presentViewController:wallet animated:YES completion:nil];
    
}



-(void)loadMapView
{
    [self onMapReload];
    
    if ([strCardID isEqualToString:@""])
    {
        _imgCard.image=[UIImage imageNamed:@"money_icon"];
        _lblCardName.text=LocalizedString(@"CASH");
    }
    
    //   [self smallPackageBtn:self];
    
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_initialCommonView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height - 166), self.view.frame.size.width,  166);
        self->_selectCarView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 166);
        
        self->_approximateRateView.frame = CGRectMake(self.view.frame.size.width+5, 0, self.view.frame.size.width, 220);
        [self.view bringSubviewToFront:self->_initialCommonView];
        
    }];
    [_serviceListCollectionView reloadData];
}



- (void)getPath
{
    NSString *googleUrl = @"https://maps.googleapis.com/maps/api/directions/json";
    NSString *urlString;
    
    if ([_destLat isEqualToString:@"0"]||[_destLng isEqualToString:@"0"]||[_destLat isEqualToString:@""]||[_destLng isEqualToString:@""]||_destLat == (id)[NSNull null]||_destLng == (id)[NSNull null])
    {
        
        
        urlString = [NSString stringWithFormat:@"%@?origin=%@,%@&destination=%@,%@&sensor=false&waypoints=%@&mode=driving&key=%@", googleUrl, _sourceLat, _sourceLng, _d_lat, _d_lng, @"",GOOGLE_API_KEY];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:urlString]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error)
          {
              
              if (response != nil){
                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                  
                  NSArray *routesArray = [json objectForKey:@"routes"];
                  
                  if ([routesArray count] > 0)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          GMSPolyline *polyline = nil;
                          [polyline setMap:nil];
                          NSDictionary *routeDict = [routesArray objectAtIndex:0];
                          NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                          NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                          GMSPath *path = [GMSPath pathFromEncodedPath:points];
                          polyline = [GMSPolyline polylineWithPath:path];
                          polyline.strokeWidth = 3.f;
                          polyline.strokeColor = BLACKCOLOR;
                          polyline.map = self->_mkap;

                      });
                  }
              }
              
          }] resume];
 
    }
    else
    {
        urlString = [NSString stringWithFormat:@"%@?origin=%@,%@&destination=%@,%@&sensor=false&waypoints=%@&mode=driving&key=%@", googleUrl, _sourceLat, _sourceLng, _destLat, _destLng, @"",GOOGLE_API_KEY];
        
        NSLog(@"my driving api URL --- %@", urlString);
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:urlString]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error)
          {
              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
              
              NSArray *routesArray = [json objectForKey:@"routes"];
              
              if ([routesArray count] > 0)
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      GMSPolyline *polyline = nil;
                      [polyline setMap:nil];
                      NSDictionary *routeDict = [routesArray objectAtIndex:0];
                      NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                      NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                      GMSPath *path = [GMSPath pathFromEncodedPath:points];
                      polyline = [GMSPolyline polylineWithPath:path];
                      polyline.strokeWidth = 3.f;
                      polyline.strokeColor = BLUECOLOR_TEXT;
                      polyline.map = self->_mkap;
                      
                      
                      [self->_mkap animateWithCameraUpdate:[GMSCameraUpdate fitBounds:self->bounds withPadding:80.0f]];
                 
                  });
              }
          }] resume];
        
        
    }
    
    
    
}

- (void)getEstimations
{
    
    NSString * startLat = [NSString stringWithFormat:@"%f",myLocation.coordinate.latitude];
    NSString * startLang = [NSString stringWithFormat:@"%f",myLocation.coordinate.longitude];

    NSString *googleUrl = @"https://maps.googleapis.com/maps/api/directions/json";
    
    NSString * urlString = [NSString stringWithFormat:@"%@?origin=%@,%@&destination=%@,%@&sensor=false&waypoints=%@&mode=driving&key=%@", googleUrl,startLat,startLang, _sourceLat, _sourceLng, @"",GOOGLE_API_KEY];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
      {
          
          if (response != nil){
              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
              
              NSArray *routesArray = [json objectForKey:@"routes"];
              
              if ([routesArray count] > 0)
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      GMSPolyline *polyline = nil;
                      [polyline setMap:nil];
                      NSDictionary *routeDict = [routesArray objectAtIndex:0];
                      self->_driverEstimatelbl = [routeDict[@"legs"] firstObject][@"duration"][@"text"];
                      NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                      NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                      GMSPath *path = [GMSPath pathFromEncodedPath:points];
                      polyline = [GMSPolyline polylineWithPath:path];
                      polyline.strokeWidth = 3.f;
                      polyline.strokeColor = BLACKCOLOR;
                      polyline.map = self->_mkap;
                      
                      
                      //   [_mkap animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:80.0f]];
                      
                      //                  [NSTimer scheduledTimerWithTimeInterval:0.000003 repeats:true block:^(NSTimer * _Nonnull timer) {
                      //                      [self animate:path];
                      //                  }];
                  });
              }
          }
          
      }] resume];
    
    
    // }
}

-(void)animate:(GMSPath *)path {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->i < path.count) {
            [self->_path2 addCoordinate:[path coordinateAtIndex:self->i]];
            self->_polylineGray = [GMSPolyline polylineWithPath:self->_path2];
            self->_polylineGray.strokeColor = [UIColor grayColor];
            self->_polylineGray.strokeWidth = 3.f;
            self->_polylineGray.map = self->_mkap;
            [self->_arrayPolylineGreen addObject:self->_polylineGray];
            self-> i++;
        }
        else {
            self->i = 0;
            self-> _path2 = [[GMSMutablePath alloc] init];
            
            for (GMSPolyline *line in self->_arrayPolylineGreen) {
                line.map = nil;
            }
            
        }
    });
}

-(IBAction)scheduleBtn:(id)sender
{
    //    [UIView animateWithDuration:0.45 animations:^{
    //
    //        _initialCommonView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height +300), self.view.frame.size.width,  300);
    //    }];
    
    [scheduleDate removeFromSuperview];
    [self setDate];
}

#pragma mark -- date
- (void)setDate
{
    @try
    {
        [self.view endEditing:YES];
        
        date_pickerViewContainer.frame = CGRectMake(0, (self.view.bounds.size.height)-250, self.view.bounds.size.width, 250);
        date_datePicker.frame=CGRectMake(0, 55, self.view.frame.size.width, 140);
        date_datePicker.hidden = NO;
        date_datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [date_datePicker addTarget:self action:@selector(dateChangedValue) forControlEvents:UIControlEventValueChanged]; //no.2
        
        
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        backgroundView.alpha = 0.4f;
        backgroundView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:backgroundView];
        
        UILabel *header = [[UILabel alloc]initWithFrame:CGRectMake(16, 8, 200, 21)];
        header.text = LocalizedString(@"Schedule a ride");
        [CSS_Class APP_labelName:header];
        [date_pickerViewContainer addSubview:header];
        
        scheduleDate = [[UILabel alloc]initWithFrame:CGRectMake(16, 30, 280, 21)];
        NSDate *now = [[NSDate alloc] init];
        now = [now dateByAddingTimeInterval:120];
        
        NSDateFormatter *DateFormatter = [[NSDateFormatter alloc]init];
        [DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mma"];
        scheduleDate.text =[DateFormatter stringFromDate:now];
        
        [CSS_Class APP_fieldValue_Small:scheduleDate];
        [date_pickerViewContainer addSubview:scheduleDate];
        
        UILabel *lineLbl = [[UILabel alloc]initWithFrame:CGRectMake(16, 53, 288, 1)];
        lineLbl.backgroundColor = RGB(200, 200, 200);
        [date_pickerViewContainer addSubview:lineLbl];
        
        UIButton *PickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [PickerBtn addTarget:self
                      action:@selector(setDateFromPicker)
            forControlEvents:UIControlEventTouchUpInside];
        PickerBtn.frame = CGRectMake(date_datePicker.frame.size.width-290, 190, 260, 40);
        [PickerBtn setTitle:LocalizedString(@"SCHEDULE REQUEST") forState:UIControlStateNormal];
        [CSS_Class APP_Blackbutton:PickerBtn];
        
        [date_pickerViewContainer addSubview:date_datePicker];
        [date_pickerViewContainer addSubview:PickerBtn];
        
        /// From Current Date
        
        NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *max_DateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
        
        NSInteger day = [max_DateComponents day];
        [max_DateComponents setDay:day + 7];
        
        NSDate *maxDate = [calendar dateFromComponents:max_DateComponents];
        
        date_datePicker.minimumDate = now;
        date_datePicker.maximumDate = maxDate;
        
        [self.view addSubview:date_pickerViewContainer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(canceldatePick)];
        [tapGestureRecognizer setDelegate:self];
        [backgroundView addGestureRecognizer:tapGestureRecognizer];
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
}

- (void)dateChangedValue
{
    @try
    {
        NSArray *listofViews = [date_pickerViewContainer subviews];
        
        for(UIView *subView in listofViews)
        {
            if([subView isKindOfClass:[UIDatePicker class]])
            {
                scheduleDate.text = @"";
                pickerDate = [(UIDatePicker *)subView date];
            }
        }
        
        NSDate *now = [[NSDate alloc] init];
        NSDateFormatter *DateFormatter = [[NSDateFormatter alloc]init];
        [DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        NSString *date=[DateFormatter stringFromDate:now];
        [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mma"];
        date=[DateFormatter stringFromDate:now];
        [scheduleDate setText:[DateFormatter stringFromDate:pickerDate]];
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
}

-(void)setDateFromPicker
{
    scheduleStr = @"true";
    [self canceldatePick];
    [self app_RateRequestBtn:self];
}

- (void)canceldatePick
{
    [date_pickerViewContainer removeFromSuperview];
    [backgroundView removeFromSuperview];
}



-(void)closeActionPop
{
    [backgroundView_Pop removeFromSuperview];
    //    [popUpView removeFromSuperview];
    
    [UIView animateWithDuration:0.45 animations:^{
        
        self->_serviceDetailsView.frame = CGRectMake(0, self.view.frame.origin.y +self.view.frame.size.height+10, self.view.frame.size.width,  300);
    }];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [CSS_Class APP_textfield_Infocus:textField];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [CSS_Class APP_textfield_Outfocus:textField];
    return YES;
}

-(void)start
{
    loading = [LoadingViewClass new];
    [loading startLoading];
}

-(void)stop
{
    [loading stopLoading];
}

#pragma mark - Collection View Delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView==_serviceListCollectionView)
    {
        return [serviceIDArray_Small count];
    }
    else{
        return [hoursArray count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView==_serviceListCollectionView)
    {
        ServiceListCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ServiceListCollectionViewCell"forIndexPath:indexPath];
        
        NSDictionary *dictVal=[arrServiceList objectAtIndex:indexPath.row];
        
        cell.lblServiceName.text=[dictVal valueForKey:@"name"];
        
        
        if (serviceSelectIndex==indexPath.row)
        {
            strServiceID=[NSString stringWithFormat:@"%@",[serviceIDArray_Small objectAtIndex:indexPath.row]];
            _modelValueLbl.text=[NSString stringWithFormat:@"%@",[serviceNameArray_Small objectAtIndex:indexPath.row]];
            
            [cell.lblServiceName setBackgroundColor:BLACKCOLOR];
            cell.lblServiceName.layer.cornerRadius = cell.lblServiceName.frame.size.height/2;
            cell.lblServiceName.clipsToBounds = YES;
            //  cell.lblServiceName.textColor = RGB(255, 255, 255);
            cell.lblServiceName.textColor = [UIColor whiteColor];
            
        }
        else
        {
            [CSS_Class APP_fieldValue:cell.lblServiceName];
        }
        
        NSString *strProfile = [Utilities removeNullFromString:[serviceImageArray_Small objectAtIndex:indexPath.row]];
        
        if (![strProfile isKindOfClass:[NSNull class]])
        {
            if ([strProfile length]!=0)
            {
                [ cell.imgService sd_setImageWithURL:[NSURL URLWithString:strProfile]
                                    placeholderImage:[UIImage imageNamed:@"sedan-car-model"]];
            }
        }
        else
        {
            cell.imgService.image=[UIImage imageNamed:@"sedan-car-model"];
        }
        cell.imgSelected.hidden=YES;
        
        return cell;
        
    }
    else
    {
        HoursCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HoursCollectionViewCell"forIndexPath:indexPath];
        cell.numberLbl.text = [NSString stringWithFormat:@"%@", [hoursArray objectAtIndex:indexPath.row]];
        [CSS_Class App_Header:cell.numberLbl];
        [cell.numberLbl setTextColor:BLACKCOLOR];
        
        if (selectedIndex==indexPath.row)
        {
            [cell.selectedImg setHidden:NO];
        }
        else
        {
            [cell.selectedImg setHidden:YES];
        }
        
        return cell;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (collectionView==_serviceListCollectionView)
        return [arrServiceList count];
    else
        return hoursArray.count;
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView==_serviceListCollectionView)
    {
        serviceSelectIndex=indexPath.row;
        strServiceID=[NSString stringWithFormat:@"%@",[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"id"]];
        _modelValueLbl.text =[NSString stringWithFormat:@"%@",[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"name"]];
        
        [_serviceListCollectionView reloadData];
        
        if (![[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"image"] isKindOfClass:[NSNull class]])
        {
            NSString *strProfile = [[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"image"];
            if ([strProfile length]!=0)
            {
                [ _serviceImage sd_setImageWithURL:[NSURL URLWithString:strProfile]
                                  placeholderImage:[UIImage imageNamed:@"sedan-car-model"]];
            }
        }
        else
        {
            _serviceImage.image=[UIImage imageNamed:@"sedan-car-model"];
        }
        
        NSString *calculator =[NSString stringWithFormat:@"%@",[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"calculator"]];
        
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        NSString *currencyStr=[Utilities removeNullFromString: [user valueForKey:@"currency"]];
        
        _fareValue.text =[NSString stringWithFormat:@"%@%@",currencyStr,[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"fixed"]];
        
        _capacityValue.text =[NSString stringWithFormat:@"%@ People",[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"capacity"]];
        
        NSString *descriptionStr =[Utilities removeNullFromString:[NSString stringWithFormat:@"%@",[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"description"]]];
        
        if ([descriptionStr isEqualToString:@""])
        {
            serviceView_Height = 65;
        }
        else
        {
            _descriptionLbl.text =descriptionStr;
            serviceView_Height = 0;
        }
        
        _serviceNameLbl.text =[NSString stringWithFormat:@"%@",[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"name"]];
        
        [_priceValue setHidden:YES];
        [_priceLbl setHidden:YES];
        
        if ([calculator isEqualToString:@"DISTANCE"])
        {
            _kmLbl.text =@"per Km";
            _minValue.text =[NSString stringWithFormat:@"%@%@",currencyStr,[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"price"]];
        }
        else if ([calculator isEqualToString:@"DISTANCEMIN"] || [calculator isEqualToString:@"DISTANCEHOUR"])
        {
            [_priceValue setHidden:NO];
            [_priceLbl setHidden:NO];
            
            _kmLbl.text =@"per min";
            _minValue.text =[NSString stringWithFormat:@"%@%@",currencyStr,[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"minute"]];
            
            _priceValue.text =[NSString stringWithFormat:@"%@%@",currencyStr,[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"price"]];
            
        }
        else if ([calculator isEqualToString:@"MIN"] || [calculator isEqualToString:@"HOUR"])
        {
            _kmLbl.text =@"per min";
            _minValue.text =[NSString stringWithFormat:@"%@%@",currencyStr,[[arrServiceList objectAtIndex:indexPath.row] valueForKey:@"minute"]];
        }
        
        [self getProvidersInCurrentLocation];
    }
    else
    {
        selectedIndex=indexPath.row;
        [_hoursCollectionView reloadData];
        [_serviceListCollectionView reloadData];
    }
}



-(void)touched:(UIGestureRecognizer *)tap{
    
    NSLog(@"the touch happened");
    [self helpPopUp];
}

-(void)getProvidersInCurrentLocation
{
    NSString *strLat=[NSString stringWithFormat:@"%.8f", myLocation.coordinate.latitude];
    NSString *strLong=[NSString stringWithFormat:@"%.8f", myLocation.coordinate.longitude];
    
    if ([appDelegate internetConnected])
    {
        NSDictionary *params=@{@"latitude":strLat,@"longitude":strLong,@"service":strServiceID};
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        //        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_GETPROVIDERS withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            //            [appDelegate onEndLoader];
            if (response)
            {
                NSLog(@"CALLED");
                
                if([response isKindOfClass:[NSArray class]])
                {
                    if ([response count]!=0)
                    {
                        for (int j=0; j<[response count]; j++)
                        {
                            NSDictionary *providerDict = [response objectAtIndex:j];
                            
                            NSString *latStr = [providerDict valueForKey:@"latitude"];
                            NSString *longStr = [providerDict valueForKey:@"longitude"];
                            
                            self->lstproviderMarkers=[[GMSMarker alloc]init];
                            self-> lstproviderMarkers.position=CLLocationCoordinate2DMake([latStr doubleValue], [longStr doubleValue]);
                            self-> lstproviderMarkers.groundAnchor=CGPointMake(0.5,0.5);
                            self-> lstproviderMarkers.draggable = NO;
                            self-> lstproviderMarkers.icon = [UIImage imageNamed:@"car"];
                            self-> lstproviderMarkers.map=self->_mkap;
                        }
                    }
                    else
                    {
                        //DO NOTHING
                    }
                }
                else if([response isKindOfClass:[NSDictionary class]])
                {
                    NSString *error = [Utilities removeNullFromString:[response objectForKey:@"message"]];
                    NSLog(@"NO PROVIDERS....%@",error);
                    
                    [self onMapReload];
                }
                else
                {
                    
                }
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    [self logOut];
                }
                
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}

-(void)onGetFareEsitmate
{
    if ([appDelegate internetConnected])
    {
        NSDictionary *params=@{@"s_latitude":_sourceLat,@"s_longitude":_sourceLng,@"d_latitude":_destLat,@"d_longitude":_destLng,@"service_type":strServiceID};
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_GET_FAREESTIMATE withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [self->appDelegate onEndLoader];
            if (response)
            {
                NSLog(@"ESTIMATE...%@", response);
                if (![response[@"estimated_fare"] isKindOfClass:[NSNull class]]) {
                    
                    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                    NSString *currencyStr=[Utilities removeNullFromString: [user valueForKey:@"currency"]];
                    NSString *surge = [NSString stringWithFormat:@"%@", [response valueForKey:@"surge"]];
                    
                    self->_app_RateAmountLbl.text= [NSString stringWithFormat:@"%@%@" , currencyStr, response[@"estimated_fare"]];
                    self->_lblapproximateTime.text=[NSString stringWithFormat:@"%@", [response valueForKey:@"time"]];//response[@"time"];
                  //  self->_walletAmount.text =[Utilities removeNullFromString:[NSString stringWithFormat:@"%@%@", currencyStr, [response valueForKey:@"wallet_balance"]] ];
                    if ([surge isEqualToString:@"1"])
                    {
                        [self->_surgeLbl setText:@"Due to high demand price may vary"];
                        //                        [self.view makeToast:@"Due to high demand price may vary" duration:5 position:CSToastPositionCenter];
                        self->_surge_XLbl.text = [NSString stringWithFormat:@"%@", [response valueForKey:@"surge_value"]];
                        
                        [self->_surgeBgView setHidden:NO];
                    }
                }
                if (![response[@"distance"] isKindOfClass:[NSNull class]]) {
                    self->strKM=response[@"distance"];
                }
                [self pickUpDrop:nil];
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    //                    [CommenMethods onRefreshToken];
                    [self logOut];
                }
                
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
    
}

-(IBAction)onReqCancel:(id)sender
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(LocalizedString(@"Alert!")) message:LocalizedString(@"Are you sure want to Cancel the request?") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* no = [UIAlertAction actionWithTitle:LocalizedString(@"NO") style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([self->appDelegate internetConnected])
        {
            NSString *strReqID=[[NSUserDefaults standardUserDefaults] valueForKey:UD_REQUESTID];
            
            NSDictionary *params=@{@"request_id":strReqID};
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [self->appDelegate onStartLoader];
            [afn getDataFromPath:MD_CANCEL_REQUEST withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
                [self->appDelegate onEndLoader];
                if (response)
                {
                    self-> strSourceAddress = @"";
                    self->strDestAddress = @"";
                    
                    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UD_REQUESTID];
                    self->_requestWaitingView.hidden=YES;
                    
                    [UIView animateWithDuration:0.45 animations:^{
                        self->_commonRateView.frame = CGRectMake(-self.view.frame.size.width, (self.view.frame.origin.y +self.view.frame.size.height -300), self.view.frame.size.width,  300);
                    }];
                    
                    
                    [UIView animateWithDuration:0.45 animations:^{
                        
                        self-> _notifyView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height +20), self.view.frame.size.width,  220);
                    }];
                    
                   self-> _initialCommonView.hidden = NO;
                }
                else
                {
                    
                    if ([errorcode intValue]==1)
                    {
                        [CommenMethods alertviewController_title:@"Error!" MessageAlert:[error objectForKey:@"error"] viewController:self okPop:NO];
                    }
                    else if ([errorcode intValue]==3)
                    {
                        //                    [CommenMethods onRefreshToken];
                        [self logOut];
                    }
                    else
                    {
                        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                    }
                }
                [self onClearLatLong];
                self->_requestWaitingView.hidden=YES;
                
                
                
                
            }];
        }
        else
        {
            [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
        }
    }];
    
    [alertController addAction:ok];
    [alertController addAction:no];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)onRequestCheck
{
    if ([appDelegate internetConnected])
    {
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:MD_REQUEST_CHECK withParamData:Nil withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            if (response)
            {
                
                NSArray *arrLocal=response[@"data"];
                
                [self->_shareBtn setHidden:YES];
                [self->_sosBtn setHidden:YES];
                
                if ([arrLocal count]!=0)
                {
                    self->markerView.hidden = YES;
                    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                    self->_BackView.hidden=YES;
                    self->_menuView.hidden=NO;
                    
                    [self.view bringSubviewToFront:self->_menuView];
                    
                    NSDictionary *dictVal=[response[@"data"]objectAtIndex:0];
                    
                    self->flowStatus = [dictVal valueForKey:@"flow"];
                    self->waypoints = [dictVal valueForKey:@"waypoints"];
                    
                    
                    self-> _sourceLat = [dictVal valueForKey:@"s_latitude"];
                    self-> _sourceLng = [dictVal valueForKey:@"s_longitude"];
                    self-> _destLat = [dictVal valueForKey:@"d_latitude"];
                    self-> _destLng = [dictVal valueForKey:@"d_longitude"];
                    
                    
                    NSString *strCheck=[dictVal valueForKey:@"status"];
                    NSString *str = [[dictVal valueForKey:@"id"]stringValue];
                    
                    [user setValue:str forKey:UD_REQUESTID];
                    
                    self-> globalStatus = strCheck;
                    ////////////////////////////////////////////////////////////////////////////////////////////////////////
                    
                    if ([strCheck isEqualToString:@"ACCEPTED"])
                        self-> _lblStatusText.text= LocalizedString(@"Driver Accepted");
                    else if ([strCheck isEqualToString:@"STARTED"]){
                 
                        self->_lblStatusText.text=[NSString stringWithFormat:@"%@",LocalizedString(@"Arriving at your location")];
            
                        
                    }
                    
                    else if ([strCheck isEqualToString:@"ARRIVED"])
                        self->_lblStatusText.text=LocalizedString(@"Arrived");
                    else if ([strCheck isEqualToString:@"PICKEDUP"])
                        self->_lblStatusText.text=LocalizedString(@"On Ride");
                    ////////////////////////////////////////////////////////////////////////////////////////////////////////

                    NSDictionary *dictLocal=[dictVal valueForKey:@"provider"];
                    
                    if ([strCheck isEqualToString:@"STARTED"]) {
                        self-> _estimateTimeLbl.hidden = NO;
                        NSLog(@"ssssds%@", [NSString stringWithFormat:@"%@ : %@", LocalizedString(@"Estimated Time"), [dictLocal valueForKey:@"estimate_time"]]);
                        self-> _estimateTimeLbl.text = [NSString stringWithFormat:@"%@ : %@", LocalizedString(@"Estimated Time"), [dictLocal valueForKey:@"estimate_time"]];
                    } else {
                        self->_estimateTimeLbl.hidden = YES;
                    }
                    
                    
                    NSString *strPayment;
                    if (![[dictVal valueForKey:@"payment_mode"] isKindOfClass:[NSNull class]])
                        strPayment=[dictVal valueForKey:@"payment_mode"];
                    else
                        strPayment=@"";
                    
                    if (![self->previousStatus isEqualToString:strCheck]) {
                        
                        self->previousStatus = strCheck;
 
                    //////////////////////////////////////////////////////////////////////////////////////////////
                    
                    if ([strCheck isEqualToString:@"STARTED"]||[strCheck isEqualToString:@"ARRIVED"]||[strCheck isEqualToString:@"ACCEPTED"]||[strCheck isEqualToString:@"PICKEDUP"])
                    {
                        self-> startLocationMarker.draggable = NO;
                        self-> endLocationMarker.draggable = NO;
                        self-> _requestWaitingView.hidden=YES;
                        self-> _whereView.hidden=YES;
                        self-> _viewSourceandDestination.hidden=YES;
                        self-> btnCurrentLocation.hidden=YES;
                        
                        NSDictionary *userDictLocal=[dictVal valueForKey:@"user"];
                        if (![[userDictLocal valueForKey:@"user"] isKindOfClass:[NSNull class]])
                        {
                            self->userNameStr =[NSString stringWithFormat:@"%@ %@",[userDictLocal valueForKey:@"first_name"],[userDictLocal valueForKey:@"last_name"]];
                        }
                        
                        
                        if([strCheck isEqualToString:@"ACCEPTED"] || [strCheck isEqualToString:@"ARRIVED"]){
                            self->_estimateTimeView.hidden = NO;
                           // [self getEstimations];
                        }
                        else{
                            self-> _estimateTimeView.hidden = YES;
                        }
                        
                        if (![[dictVal valueForKey:@"provider"] isKindOfClass:[NSNull class]])
                        {
                            
                            
                            if (![[dictLocal valueForKey:@"avatar"] isKindOfClass:[NSNull class]]) {
                                
                                NSString *imageUrl = [dictLocal valueForKey:@"avatar"];
                                
                                if ([imageUrl containsString:@"http"])
                                {
                                    imageUrl = [NSString stringWithFormat:@"%@",[dictLocal valueForKey:@"avatar"]];
                                }
                                else
                                {
                                    imageUrl = [NSString stringWithFormat:@"%@/storage/%@",SERVICE_URL, [dictLocal valueForKey:@"avatar"]];
                                }
                                
                                [ self->_userImg sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                                   placeholderImage:[UIImage imageNamed:@"userProfile"]];
                            }
                            else
                            {
                                self->_userImg.image=[UIImage imageNamed:@"userProfile"];
                            }
                            self->_nameLbl.text=[NSString stringWithFormat:@"%@ %@",[dictLocal valueForKey:@"first_name"],[dictLocal valueForKey:@"last_name"]];
                        //    self-> _estimateTimeLbl.text = [NSString stringWithFormat:@"%@ : %@", LocalizedString(@"Estimated Time"), [dictLocal valueForKey:@"estimate_time"]];
                            self-> strProviderCell= [Utilities removeNullFromString: [dictLocal valueForKey:@"mobile"]];
                            
                            NSString *latit = [dictLocal valueForKey:@"latitude"];
                            NSString *longi = [dictLocal valueForKey:@"longitude"];
                            
                            CLLocationCoordinate2D navi_location = CLLocationCoordinate2DMake([latit doubleValue], [longi doubleValue]);
                            CLLocationCoordinate2D old=  self->markerCarLocation.position;
                            CLLocationCoordinate2D new= navi_location;
                            
                            if ( self->markerCarLocation == nil)
                            {
                                self-> markerCarLocation = [GMSMarker markerWithPosition:navi_location];
                                self->  markerCarLocation.icon = [UIImage imageNamed:@"car"];
                                self-> markerCarLocation.map=  self->_mkap;
                            }
                            else
                            {
                                [CATransaction begin];
                                [CATransaction setAnimationDuration:2.0];
                                self->markerCarLocation.position = navi_location;
                                [CATransaction commit];
                            }
                            float getAngle = [self angleFromCoordinate:old toCoordinate:new];
                            self->markerCarLocation.rotation = getAngle * (180.0 / M_PI);
                            
                            if (![[dictLocal valueForKey:@"rating"] isKindOfClass:[NSNull class]])
                                self-> _rating_default.value=[[dictLocal valueForKey:@"rating"] floatValue];
                            else
                                self->_rating_default.value=0;
                        }
                        
                        NSDictionary *dictServiceType=[dictVal valueForKey:@"service_type"];
                        if (![[dictServiceType valueForKey:@"image"] isKindOfClass:[NSNull class]])
                        {
                            
                            NSString *imageUrl = [NSString stringWithFormat:@"%@",[dictServiceType valueForKey:@"image"]];
                            
                            [ self->_ServiceImg sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                                  placeholderImage:[UIImage imageNamed:@"sedan-car-model"]];
                        }
                        else
                        {
                            self->_ServiceImg.image=[UIImage imageNamed:@"sedan-car-model"];
                        }
                        
                        self->  _lblServiceName.text=[dictServiceType valueForKey:@"name"];
                        
                        NSDictionary *carNumberDict=[dictVal valueForKey:@"provider_service"];
                        NSString *carNumber = [carNumberDict valueForKey:@"service_number"];
                        NSString *carModel = [carNumberDict valueForKey:@"service_model"];
                        self-> _lblCarNumber.text= [Utilities removeNullFromString:[NSString stringWithFormat:@"%@\n%@", carModel, carNumber]] ;
                        
                        if ([strCheck isEqualToString:@"STARTED"]||[strCheck isEqualToString:@"ACCEPTED"])
                        {
                            self->_statusView.hidden=NO;
                            self->_initialCommonView.hidden = YES;
                            self->_lblStatusText.hidden = YES;
                            [UIView animateWithDuration:0.45 animations:^{
                                
                                self-> _notifyView.frame = CGRectMake(0, (self.view.frame.origin.y), self.view.frame.size.width,  170);
                                
                                [self.view bringSubviewToFront: self->_notifyView];
                            }];
                        }
                        
                        if ([strCheck isEqualToString:@"ARRIVED"])
                        {
                            self-> _statusView.hidden=NO;
                            self->_lblStatusText.hidden = NO;
                            self->_initialCommonView.hidden = YES;
                            [UIView animateWithDuration:0.45 animations:^{
                                
                                self->  _notifyView.frame = CGRectMake(0, (self.view.frame.origin.y), self.view.frame.size.width,  180);
                                
                                [self.view bringSubviewToFront: self->_notifyView];
                            }];
                        }
                        
                        if ([strCheck isEqualToString:@"PICKEDUP"])
                        {
                            
                            [self->_mkap clear];
                            self->statusDestinationTripNormal = true;
                            [self.view bringSubviewToFront: self-> _sosBtn];
                            [self.view bringSubviewToFront: self->_shareBtn];
                            
                            [ self->_shareBtn setHidden:NO];
                            [ self->_sosBtn setHidden:NO];
                            
                            self->_statusView.hidden=YES;
                            self-> _rejectBtn.hidden = YES;
                            self->_initialCommonView.hidden = YES;
                            
                            [UIView animateWithDuration:0.45 animations:^{
                                
                                self-> _notifyView.frame = CGRectMake(0, (self.view.frame.origin.y), self.view.frame.size.width,  180);
                                
                                [self.view bringSubviewToFront: self->_notifyView];
                            }];
                        }
                    }
                    
                    
                    ///////////////////////////////////////////////////////////////////////////////////////////////////
                    else if (([strCheck isEqualToString:@"DROPPED"] ||[strCheck isEqualToString:@"COMPLETED"])&&[[dictVal valueForKey:@"paid"]intValue]==0 && [strPayment isEqualToString:@"CARD"])
                    {
                        self-> _statusView.hidden=YES;
                        self->   _whereView.hidden=YES;
                        self->   _viewSourceandDestination.hidden=YES;
                        self->   _requestWaitingView.hidden=YES;
                       // self-> _paymentBtn.hidden=YES;
                        
                        self->_initialCommonView.hidden = YES;
                        self->   strSourceAddress = @"";
                        self->   strDestAddress = @"";
                        if (![[dictVal valueForKey:@"payment"] isKindOfClass:[NSNull class]]) {
                            
                            
                            NSDictionary *dictPayment=[dictVal valueForKey:@"payment"];
                            NSString *currencyStr=[user valueForKey:@"currency"];
                            
                
                            self->  _lblTotalAmt.text=[NSString stringWithFormat:@"%@%@",currencyStr,[dictPayment valueForKey:@"total"]];
                            
                            self->_labelValueTravel.text = [NSString stringWithFormat:@"%@%@",currencyStr,[dictPayment valueForKey:@"trip_price"]];
              
                            
                            NSString *discount=[NSString stringWithFormat:@"%@",[dictPayment valueForKey:@"discount"]];
                            self-> _labelValueDiscount.text=[NSString stringWithFormat:@"%@%@",currencyStr,discount];
                            
                            
                            
                            [UIView animateWithDuration:0.45 animations:^{
                                self-> _commonRateView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height -170), self.view.frame.size.width,  170);
                                
                                 self->_invoiceView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 170);
                                self->   _notifyView.frame = CGRectMake(self.view.frame.size.width, (self.view.frame.origin.y +self.view.frame.size.height -220), self.view.frame.size.width,  220);
                                
                                self->  _rateViewView.frame = CGRectMake(self.view.frame.size.width+5, 0, self.view.frame.size.width, 300);
                                [self.view bringSubviewToFront: self->_commonRateView];
                                
                          
                            }];

                        }
                    }
                    else if ([strCheck isEqualToString:@"DROPPED"]&&[[dictVal valueForKey:@"paid"]intValue]==0 && [strPayment isEqualToString:@"CASH"])
                    {
                        self-> strSourceAddress = @"";
                        self-> strDestAddress = @"";
                        [ self-> _whereView setHidden:YES];
                        self->_requestWaitingView.hidden=YES;
                        self->_initialCommonView.hidden = YES;
                        if (![[dictVal valueForKey:@"payment"] isKindOfClass:[NSNull class]]) {
                            
                            
                            
                            NSDictionary *dictPayment=[dictVal valueForKey:@"payment"];
                            
                            NSString *currencyStr= [Utilities removeNullFromString:[user valueForKey:@"currency"]];
                            
                            self->_lblTotalAmt.text=[NSString stringWithFormat:@"%@%@",currencyStr,[dictPayment valueForKey:@"total"]];
                            
                            self->  _lblTotalAmt.text=[NSString stringWithFormat:@"%@%@",currencyStr,[dictPayment valueForKey:@"total"]];
                            
                            self->_labelValueTravel.text = [NSString stringWithFormat:@"%@%@",currencyStr,[dictPayment valueForKey:@"trip_price"]];
                            
                            
                            NSString *discount=[NSString stringWithFormat:@"%@",[dictPayment valueForKey:@"discount"]];
                            self-> _labelValueDiscount.text=[NSString stringWithFormat:@"%@%@",currencyStr,discount];
                            
                            [UIView animateWithDuration:0.45 animations:^{
                                
                                if ([strPayment isEqualToString:@"CASH"])
                                {
                                    self->_commonRateView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height -50), self.view.frame.size.width,  50);
                                    
                                    self->_invoiceView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 220);
                                    self->_rateViewView.frame = CGRectMake(self.view.frame.size.width+5, 0, self.view.frame.size.width, 250);
                                }
                                else
                                {
                                    
                                    self->_commonRateView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height -300), self.view.frame.size.width,  300);
                                    
                                    self->_invoiceView.frame = CGRectMake( 0, 0, self.view.frame.size.width, 50);
                                    self->_rateViewView.frame = CGRectMake(self.view.frame.size.width+5, 0, self.view.frame.size.width, 300);
                                }
                                
                                
                                [self.view bringSubviewToFront:self->_commonRateView];
                                
                            }];
                        }
                    }
                    else if ([strCheck isEqualToString:@"COMPLETED"]&&[[dictVal valueForKey:@"paid"]intValue]==1)
                    {
                        self->strSourceAddress = @"";
                        self->strDestAddress = @"";
                        self->_statusView.hidden=YES;
                        
                        self->_requestWaitingView.hidden=YES;
                        self->_lblRatewithName.text=[NSString stringWithFormat:@"%@ %@ %@",LocalizedString(@"RATING_VIEW"),[[dictVal valueForKey:@"provider"] valueForKey:@"first_name"],[[dictVal valueForKey:@"provider"] valueForKey:@"last_name"]];
                        
                        NSDictionary *dictLocal=[dictVal valueForKey:@"provider"];
                        if (![[dictLocal valueForKey:@"avatar"] isKindOfClass:[NSNull class]]) {
                            
                            NSString *imageUrl =[dictLocal valueForKey:@"avatar"];
                            
                            if ([imageUrl containsString:@"http"])
                            {
                                imageUrl = [NSString stringWithFormat:@"%@",[dictLocal valueForKey:@"avatar"]];
                            }
                            else
                            {
                                imageUrl = [NSString stringWithFormat:@"%@/storage/%@",SERVICE_URL, [dictLocal valueForKey:@"avatar"]];
                            }
                            
                            [self->_ratingProviderImg sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                                        placeholderImage:[UIImage imageNamed:@"userProfile"]];
                        }
                        else
                        {
                            self->_ratingProviderImg.image=[UIImage imageNamed:@"userProfile"];
                        }
                        self->_initialCommonView.hidden = YES;
                        
                        [UIView animateWithDuration:0.45 animations:^{
                            
                            self->_commonRateView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height -300), self.view.frame.size.width,  300);
                            
                            self->_invoiceView.frame = CGRectMake( -self.view.frame.size.width, 0, self.view.frame.size.width, 300);
                            self->_rateViewView.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
                            
                            [self.view bringSubviewToFront:self->_commonRateView];
                            
                        }];
                        
                    }
                    else if ([strCheck isEqualToString:@"SEARCHING"])
                    {
                        self->_whereView.hidden=YES;
                        self->_viewSourceandDestination.hidden=NO;
                        self->_lblSource.text=self->strSourceAddress;
                        self->_lblDestination.text=self->strDestAddress;
                        
                        [self->_requestWaitingView setHidden:NO];
                        [UIView animateWithDuration:0.45 animations:^{
                            
                            self->_requestWaitingView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                            
                            [self.view bringSubviewToFront:self->_requestWaitingView];
                        }];
                    }
                    else if ([strCheck isEqualToString:@"CANCELLED"])
                    {
                        [self->_mkap clear];
                        [self onClearLatLong];
                        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UD_REQUESTID];
                        self->_requestWaitingView.hidden=YES;
                    }
                    
                }
                    /////////////////////////////////////////////////////////////////////////////////////////////////////
                    if (![[dictVal valueForKey:@"provider"] isKindOfClass:[NSNull class]]){
                       
                        NSDictionary *dictLocal=[dictVal valueForKey:@"provider"];
                      //  NSDictionary *userDictLocal=[dictVal valueForKey:@"user"];
                        
                        NSString *prolat = [dictLocal valueForKey:@"latitude"];
                        NSString *prolon = [dictLocal valueForKey:@"longitude"];
                        
                        NSString *s_lat_user = [dictVal valueForKey:@"s_latitude"];
                        NSString *s_lot_user = [dictVal valueForKey:@"s_longitude"];
                        
                        [self liveNavigation:prolat :prolon :strCheck :s_lat_user :s_lot_user];

                        
                    }
                   
                    
                    
                }
                
                
                
                ////////////////////////// response count 0
                else {
                    if ([self->globalStatus isEqualToString:@"SEARCHING"] || [self->globalStatus isEqualToString:@"STARTED"] || [self->globalStatus isEqualToString:@"ARRIVED"])
                    {
                        //Clear the view after the request cancel without accept by any driver
                        
                        
                        [self->_shareBtn setHidden:YES];
                        [self->_sosBtn setHidden:YES];
                        
                        self->globalStatus = @"";
                        [self->_mkap clear];
                        [self onClearLatLong];
                        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UD_REQUESTID];
                        self->_requestWaitingView.hidden=YES;
                        
                        [UIView animateWithDuration:0.45 animations:^{
                            
                            self->_notifyView.frame = CGRectMake(0, (self.view.frame.origin.y +self.view.frame.size.height +20), self.view.frame.size.width,  280);
                        }];
                    }
                    else
                    {
                        
                    }
                    self->_requestWaitingView.hidden=YES;
                    self->strRating=@"1";
                    self->_commentsText.text=@"";
                    
                    /// For schedule
                    
                    if ([self->scheduleNav_Str isEqualToString:@"TRUE"])
                    {
                        self->scheduleNav_Str  =@"FALSE";
                        [self onClearLatLong];
                        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UD_REQUESTID];
                        self->_requestWaitingView.hidden=YES;
                        
                        YourTripViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"YourTripViewController"];
                        wallet.navigateStr = @"Home";
                        [self.navigationController pushViewController:wallet animated:YES];
                    }
                    else
                    {
                        //Nothing
                    }
                }
            }
            //////////////////////////////////////////////////////////////////////////////////// error response
            else
            {
                [self->timerDriverLocationUpdate invalidate];
                self->checkDriverLocation = false;
                if ([errorcode intValue]==1)
                {
                   // [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    if (self->LoggedOut ==false)
                    {
                        [self->timeRequestCheck invalidate];
                        [self logOut];
                    }
                    
                }
            }
            
        }];
    }
    
    ////////////////////////////////////////////////////////////////net check
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}

-(void) liveNavigation :(NSString*) lat :(NSString *) lng :(NSString *) status : (NSString *) s_lat_user :(NSString *)s_lot_user {
    
 
       double proLat = [lat doubleValue];
       double prolng = [lng doubleValue];
        
        if (proLat == 0 && prolng == 0) {
            return;
        }
    
      CLLocationCoordinate2D new= CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
    
    
    if (self -> providerMarkers != nil) {
        CLLocationCoordinate2D old=  self->providerMarkers.position;
        self->providerMarkers.position = new;
        self->providerMarkers.groundAnchor=CGPointMake(0.5,0.5);
        self->providerMarkers.draggable = NO;
        self->providerMarkers.icon = [UIImage imageNamed:@"car"];
        float getAngle = [self angleFromCoordinate:old toCoordinate:new];
        self->providerMarkers.rotation = getAngle * (180.0 / M_PI);
        self->providerMarkers.map = nil;
        self->providerMarkers.map=self->_mkap;
        
    }else {
        
        self->providerMarkers.position = new;
        self->providerMarkers.groundAnchor=CGPointMake(0.5,0.5);
        self->providerMarkers.draggable = NO;
        self->providerMarkers.icon = [UIImage imageNamed:@"car"];
        self->providerMarkers.map=self->_mkap;
        
    }
    
        
        if (![status isEqualToString:@"STARTED"] && [flowStatus isEqualToString:@"OPTIONAL"] && ([waypoints count] > 0)) {
        
            GMSMutablePath *path = [GMSMutablePath path];
            for (NSObject *object in waypoints) {
                NSString *lati = [object valueForKey:@"latitude"];
                NSString *longi = [object valueForKey:@"longitude"];
                [path addCoordinate:CLLocationCoordinate2DMake(lati.doubleValue,longi.doubleValue)];
            }  
           GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
            polyline.strokeWidth = 3.f;
            polyline.strokeColor = BLUECOLOR_TEXT;
            polyline.map = self->_mkap;

        }
    
    if (![status isEqualToString:@"STARTED"] && ![flowStatus isEqualToString:@"OPTIONAL"] &&
        ![status isEqualToString:@"SEARCHING"] && self-> statusDestinationTripNormal) {
        statusDestinationTripNormal = false;
        [self Destination:s_lat_user :s_lot_user :_destLat :_destLng];
        
    }
    
    if (countDestination == 1 && [status isEqualToString:@"STARTED"]) {
        [self Destination: lat :lng :s_lat_user :s_lot_user];
        countDestination = countDestination+1;
    }
 
    timerMoveMap +=30;
    NSTimeInterval timeCurent = [[NSDate date] timeIntervalSince1970];

    if (timerMoveMap < timeCurent){
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:proLat longitude:prolng zoom:16];
        [_mkap animateWithCameraUpdate:[GMSCameraUpdate setTarget:camera.target zoom:16]];
    }
    timerMoveMap -=30;

    
}

-(void)onMapReload
{
    GMSPolyline *polyline;
    polyline.map = nil;
    [_mkap clear];
    
    startLocationMarker.map=nil;
    bounds = [[GMSCoordinateBounds alloc] init];
    
    startLocationMarker=[[GMSMarker alloc]init];
    startLocationMarker.position=CLLocationCoordinate2DMake([_sourceLat doubleValue], [_sourceLng doubleValue]);
    startLocationMarker.icon=[UIImage imageNamed:@"ub__ic_pin_pickup"];
    startLocationMarker.groundAnchor=CGPointMake(0.5,0.5);
    startLocationMarker.draggable = YES;
    startLocationMarker.userData = @"PICKUP";
    bounds = [bounds includingCoordinate:startLocationMarker.position];
    startLocationMarker.map=_mkap;
    
    endLocationMarker.map=nil;
    endLocationMarker=[[GMSMarker alloc]init];
    endLocationMarker.position=CLLocationCoordinate2DMake([_destLat doubleValue], [_destLng doubleValue]);
    endLocationMarker.icon=[UIImage imageNamed:@"ub__ic_pin_dropoff"];
    endLocationMarker.groundAnchor=CGPointMake(0.5,0.5);
    endLocationMarker.draggable = YES;
    endLocationMarker.userData = @"DROP";
    bounds = [bounds includingCoordinate:endLocationMarker.position];
    endLocationMarker.map=_mkap;
   // [self getPath];
}

- (float)angleFromCoordinate:(CLLocationCoordinate2D)first
                toCoordinate:(CLLocationCoordinate2D)second {
    
    float deltaLongitude = second.longitude - first.longitude;
    float deltaLatitude = second.latitude - first.latitude;
    float angle = (M_PI * .5f) - atan(deltaLatitude / deltaLongitude);
    
    if (deltaLongitude > 0)      return angle;
    else if (deltaLongitude < 0) return angle + M_PI;
    else if (deltaLatitude < 0)  return M_PI;
    
    return 0.0f;
}

-(IBAction)sosBtnAction:(id)sender
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *sosNumber = [Utilities removeNullFromString:[def valueForKey:UD_SOS]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"Alert!") message:LocalizedString(@"Are you sure want to Call Emergency?") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* no = [UIAlertAction actionWithTitle:LocalizedString(@"NO") style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([sosNumber isEqualToString:@""])
        {
            //No SOS number was provided
        }
        else
        {
            NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:sosNumber]];
            NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:sosNumber]];
            
            if ([UIApplication.sharedApplication canOpenURL:phoneUrl])
            {
                [UIApplication.sharedApplication openURL:phoneUrl options:@{} completionHandler:nil];
            }
            else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl])
            {
                [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:nil];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"Alert") message:LocalizedString(@"Your device does not support calling") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];    }
        }
        
    }];
    [alertController addAction:ok];
    [alertController addAction:no];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
-(IBAction)shareBtnAction:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"Alert!") message:LocalizedString(@"Are you sure want to share the ride?") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* no = [UIAlertAction actionWithTitle:LocalizedString(@"NO") style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"YES") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *strLat=[NSString stringWithFormat:@"%.8f",  self->myLocation.coordinate.latitude];
        NSString *strLong=[NSString stringWithFormat:@"%.8f",  self->myLocation.coordinate.longitude];
        
        NSString *shareUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?q=loc:%@,%@",strLat, strLong];
        NSString *strTitle=[NSString stringWithFormat:@"TaxiAlaan - %@ would like to share a ride with you at ",  self->userNameStr];
        UIImage *img = [UIImage imageNamed:@"icon"];
        [self shareText:strTitle andImage:img andUrl:[NSURL URLWithString:shareUrlStr]];
    }];
    [alertController addAction:ok];
    [alertController addAction:no];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)updateDriverLocation
{
    if ([appDelegate internetConnected])
    {
        NSString *strReqID=[[NSUserDefaults standardUserDefaults] valueForKey:UD_REQUESTID];
        NSLog(@"Service Id:  %@", strReqID);
        NSNumber *requestId = @([strReqID intValue]);
        NSDictionary *params=@{@"id":requestId};
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        //        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_PROVIDER_INFO withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            //            [appDelegate onEndLoader];
            if (response)
            {
                NSLog(@"Driver Location %@", response);
                NSString *latStr = [response valueForKey:@"latitude"];
                NSString *longStr = [response valueForKey:@"longitude"];
                self->lstproviderMarkers.position=CLLocationCoordinate2DMake([latStr doubleValue], [longStr doubleValue]);
                self->lstproviderMarkers.groundAnchor=CGPointMake(0.5,0.5);
                self->lstproviderMarkers.draggable = NO;
                self->lstproviderMarkers.icon = [UIImage imageNamed:@"car"];
                self->lstproviderMarkers.map=self->_mkap;
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    [self logOut];
                }
                
            }
            
        }];
    }
}


-(void)getWeather
{
    
    if([appDelegate internetConnected])
    {
        
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval=600;
        
        NSString *URLString = @"http://api.openweathermap.org/data/2.5/weather";
        NSDictionary *parameter = @{@"lat":[NSString stringWithFormat:@"%.8f", myLocation.coordinate.latitude], @"lon": [NSString stringWithFormat:@"%.8f", myLocation.coordinate.longitude],@"units":@"metric",@"appid":@"5f36898450370d957056a3c7dd1a87ed"};
        
        [manager GET:URLString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             
             NSDictionary *paymentDict = [responseObject valueForKey:@"main"];
             NSString *AA = [paymentDict valueForKey:@"temp"];
             double latdouble = [AA doubleValue];
             NSLog(@"obk-%.0f",latdouble);
             [self->_btnTemp setTitle:[NSString stringWithFormat:@"%.0f",latdouble] forState:UIControlStateNormal];
             
         }
         
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error %@",error);
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                 NSLog(@"status code: %li", (long)httpResponse.statusCode);
                 
                 NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                 if (errorData == nil)
                 {
                     
                 }
                 
                 
             }];
        
    }
    
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    btnCurrentLocation.hidden=NO;
    [_mapView bringSubviewToFront:btnCurrentLocation];
    
    timerMoveMap =  [[NSDate date] timeIntervalSince1970];
    if (statusSource == (int*)1){
        
        [markerView openWithStatus:1];
        
    }else if (statusSource == (int*)2){
        
        [markerView openWithStatus:2];
    }

}

//idleAtCameraPosition

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    
    lastCameraPosition = position;
    [markerView close];
    
    NSLog(@"position..%f", position.target.latitude);
    NSLog(@"position..%f", position.target.longitude);
   
    
}

- (void)tapMarker {
    
    if (statusSource == (int*)1) {
      
        _sourceLat = [NSString stringWithFormat:@"%f",lastCameraPosition.target.latitude];
        _sourceLng = [NSString stringWithFormat:@"%F",lastCameraPosition.target.longitude];
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([_sourceLat doubleValue], [_sourceLng doubleValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.icon = [UIImage imageNamed:@"ic_origin_selected_marker"];
        marker.map = _mkap;

        [self getAddressFrom:[_sourceLat doubleValue] withLongitude:[_sourceLng doubleValue]];
    
      _menuView.hidden=YES;
      _BackView.hidden=NO;
      _viewSourceandDestination.hidden=NO;
      _whereView.hidden=YES;
       [self.view bringSubviewToFront:_BackView];
      [_mkap animateWithCameraUpdate:[GMSCameraUpdate scrollByX:-60 Y:-60]];
       
    
        
    } else {
        
        _destLat =[NSString stringWithFormat:@"%f",lastCameraPosition.target.latitude];;
        _destLng =[NSString stringWithFormat:@"%F",lastCameraPosition.target.longitude];;
        
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([_destLat doubleValue], [_destLng doubleValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.icon = [UIImage imageNamed:@"ic_dest_selected_marker"];
        marker.map = _mkap;

        [self getAddressFrom:[_destLat doubleValue] withLongitude:[_destLng doubleValue]];
        markerView.hidden = YES;
        [self getPath];
        
        
    }
 
}


-(NSString *)getAddressFrom:(double)pdblLatitude withLongitude:(double)pdblLongitude
{
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:pdblLatitude longitude:pdblLongitude];
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  if (placemark)
                  {
                      
                      //String to hold address
                      NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
 
                      if (self->statusSource == (int*)1) {
                          self->strSourceAddress = locatedAt;
                          self->_lblSource.text= self->strSourceAddress;
                          
                          [self->markerView changeIconWithStatus:2];
                          self->statusSource = (int*)2;
                          
                      }else {
                          
                          self->strDestAddress = locatedAt;
                          self->_lblDestination.text=self->strDestAddress;
                      }
                      
                   
                  }
                  else {
                      NSLog(@"Could not locate");
                      self->locationString = @"";
                  }
              }
     ];
    return locationString;
}



-(void)Destination : (NSString *)sourceLat :(NSString*)sourceLng :(NSString*)destLag:(NSString*)destLng {
    
     NSString *googleUrl = @"https://maps.googleapis.com/maps/api/directions/json";
    NSString *url =   [NSString stringWithFormat:@"%@?origin=%@,%@&destination=%@,%@&sensor=false&waypoints=%@&mode=driving&key=%@", googleUrl, sourceLat,sourceLng,destLag,destLng, @"",GOOGLE_API_KEY];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
      {
          NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
          
          NSArray *routesArray = [json objectForKey:@"routes"];
          
          if ([routesArray count] > 0)
          {
             [ self->_mkap clear];
              dispatch_async(dispatch_get_main_queue(), ^{
                  
                  CLLocationCoordinate2D position = CLLocationCoordinate2DMake([sourceLat doubleValue], [sourceLng doubleValue]);
                  GMSMarker *marker = [GMSMarker markerWithPosition:position];
                  marker.icon = [UIImage imageNamed:@"ic_origin_selected_marker"];
                  marker.map = self->_mkap;
                  
                  
                  CLLocationCoordinate2D position2 = CLLocationCoordinate2DMake([destLag doubleValue], [destLng doubleValue]);
                  GMSMarker *marker2 = [GMSMarker markerWithPosition:position2];
                  marker2.icon = [UIImage imageNamed:@"ic_dest_selected_marker"];
                  marker2.map = self->_mkap;
                  
                  GMSPolyline *polyline = nil;
                  [polyline setMap:nil];
                  NSDictionary *routeDict = [routesArray objectAtIndex:0];
                  NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                  NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                  GMSPath *path = [GMSPath pathFromEncodedPath:points];
                  polyline = [GMSPolyline polylineWithPath:path];
                  polyline.strokeWidth = 3.f;
                  polyline.strokeColor = BLUECOLOR_TEXT;
                  polyline.map = self->_mkap;
                  
                  
                  [self->_mkap animateWithCameraUpdate:[GMSCameraUpdate fitBounds:self->bounds withPadding:80.0f]];
                  
              });
          }
      }] resume];
    
}

@end
