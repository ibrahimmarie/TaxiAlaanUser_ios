//
//  Constants.h
//  Truck
//
//  Created by veena on 1/12/17.
//  Copyright © 2017 appoets. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Service URL

#define SERVICE_URL @"https://taxialaan.com/"//@"https://staging.taxialaan.com/"         //@"http://174.138.50.87/"

//#define SERVICE_URL @"http://testing.taxialaan.com/"
//#define SERVICE_URL @"https://mobile.taxialaan.com/"
//#define WEB_SOCKET @"http://taxialaan.com:7000"
//#define WEB_SOCKET @"http://mobile.taxialaan.com:7000"

#define Address_URL @"https://maps.googleapis.com/maps/api/geocode/json?"
#define AutoComplete_URL @"https://maps.googleapis.com/maps/api/place/autocomplete/json?"
#define Google_Client_ID @"710279630663-4lgj6e2c98imgiv4t2d6207l3296987e.apps.googleusercontent.com"
#define placs @"https://maps.googleapis.com/maps/api/place/details/json?"
#define GOOGLE_API_KEY @"AIzaSyCa3yhDGMZM2xHCc5ieYeyz87SuHYDzozU"

//#define GOOGLE_API_KEY @"AIzaSyBbCyTCKL0vIQoidBc4_pd4zQs9r0X8fmM"
//#define GMSMAP_KEY @"AIzaSyBKwV2w7uWSf3bpgZeRNbMTBKdRbqnmQew"
//#define GMSPLACES_KEY @"AIzaSyDxJ4RB9Ztj7apIVAbHWY9gITnH_Wu5dOU"

//#define GMSMAP_KEY @"AIzaSyBbCyTCKL0vIQoidBc4_pd4zQs9r0X8fmM"
//#define GMSPLACES_KEY @"AIzaSyBbCyTCKL0vIQoidBc4_pd4zQs9r0X8fmM"

#define Stripe_KEY @"pk_test_0G4SKYMm8dK6kgayCPwKWTXy"

#define ClientID @"2"
#define Client_SECRET @"1seil0BqIM6TdcyZ0hIlEuNctAaxdatqK44AhwdW"

#define Clientmobi_SECRET @"DCE3FCF1-1718-4B4B-B6BA-3C1A268DE291"


//convert latlng to address;

#pragma mark - userdefaults
#pragma mark -

extern NSString *const UD_TOKEN_TYPE;
extern NSString *const UD_ACCESS_TOKEN;
extern NSString *const UD_REFERSH_TOKEN;
extern NSString *const UD_PROFILE_IMG;
extern NSString *const UD_PROFILE_NAME;
extern NSString *const UD_PROFILE_NAME_LAST;
extern NSString *const UD_REQUESTID;
extern NSString *const UD_SOCIAL;
extern NSString *const UD_ID;
extern NSString *const UD_SOS;

#pragma mark - Parameters
#pragma mark - --
extern NSString *const PICTURE;

#pragma mark - Parameters
#pragma mark - --   Seque

extern NSString *const LOGIN;
extern NSString *const REGISTER;

#pragma mark - methods
#pragma mark - 

extern NSString *const MD_LOGIN;
extern NSString *const MD_REGISTER;
extern NSString *const MD_GETPROFILE;
extern NSString *const MD_UPDATEPROFILE;
extern NSString *const MD_UPDATELOCATION;
extern NSString *const MD_CHANGEPASSWORD;
extern NSString *const MD_GET_SERVICE;
extern NSString *const MD_GET_FAREESTIMATE;
extern NSString *const MD_CREATE_REQUEST;
extern NSString *const MD_CANCEL_REQUEST;
extern NSString *const MD_REQUEST_CHECK;
extern NSString *const MD_RATE_PROVIDER;
extern NSString *const MD_GET_HISTORY;
extern NSString *const MD_GET_SINGLE_HISTORY;
extern NSString *const MD_ADD_CARD;
extern NSString *const MD_LIST_CARD;
extern NSString *const MD_PAYMENT;
extern NSString *const MD_CARD_DELETE;
extern NSString *const MD_WALLET;
extern NSString *const MD_UPCOMING;
extern NSString *const MD_UPCOMING_HISTORYDETAILS;
extern NSString *const MD_GETPROVIDERS;
extern NSString *const MD_RESETPASSWORD;
extern NSString *const MD_FORGOTPASSWORD;
extern NSString *const MD_FACEBOOK;
extern NSString *const MD_GOOGLE;
extern NSString *const MD_LOGOUT;
extern NSString *const MD_HELP;
extern NSString *const MD_SENDOTP;
extern NSString *const MD_VERIFYOTP;
extern NSString *const MD_REGMOB;
extern NSString *const MD_MOBLOGIN;
extern NSString *const MD_PROVIDER_INFO;
extern NSString *const MD_APPLAY;
extern NSString *const MD_DETAILS_WALLET;
extern NSString *const MD_TRANSFER;
extern NSString *const MD_TRANSACTIONLOG;
extern NSString *const SENDERORR;
extern NSString *const TEST;
