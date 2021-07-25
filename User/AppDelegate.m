//
//  AppDelegate.m
//  User
//
//  Created by iCOMPUTERS on 18/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "LoadingViewClass.h"
#import "HomeViewController.h"
#import "Stripe.h"
//#import <SplunkMint/SplunkMint.h>
#import "CheckMobiService.h"
#import "LanguageController.h"
#import "IQKeyboardManager.h"
#import <Fabric/Fabric.h>
#import <Firebase/Firebase.h>
#import "Siren-Swift.h"


@import GoogleMobileAds;
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@import GoogleMaps;
@import GooglePlaces;
@class LoadingViewClass;
//@import SplunkMint;

@interface AppDelegate ()
{
    LoadingViewClass *loader;
}

@end

@implementation AppDelegate
@synthesize strDeviceToken,strEmail,strSmsFrom;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    // NSLog(@"device token %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"]);
    
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;

    LocalizationSetLanguage(@"en");
    
    [[CheckMobiService sharedInstance] setSecretKey:@"2BA5FF58-BCCA-4160-9C98-6E78BC4ED934"];

    strDeviceToken=@"no device";
    strEmail=@"";
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
 //   NSError* configureError;
//    [[GGLContext sharedInstance] configureWithError: &configureError];
//    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
//
//    [GIDSignIn sharedInstance].delegate = self;
    
     [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] setObject: strDeviceToken forKey:@"device_Token"];
    
    NSString*devType=@"ios";
    [[NSUserDefaults standardUserDefaults]setObject:devType forKey:@"device_type"];
    // [Fabric with:@[[Crashlytics class], [STPAPIClient class]]];
//    [[Crashlytics sharedInstance] crash];

    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    [GMSPlacesClient provideAPIKey:GOOGLE_API_KEY];
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:Stripe_KEY];
    
    BOOL yes=  [defaults valueForKey:@"isLoggedin"];
     if([[NSUserDefaults standardUserDefaults]objectForKey:@"FirstLoad"] !=nil){
         LocalizationSetLanguage([[NSUserDefaults standardUserDefaults] objectForKey:@"LanguageCode"]);

         if (yes)      

         {
             UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
             HomeViewController * infoController = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
             self.navigationController = [[UINavigationController alloc] initWithRootViewController:infoController];
             self.window.rootViewController = self.navigationController;
             self.window.backgroundColor = [UIColor whiteColor];
             [self.window makeKeyAndVisible];
         }
         else
         {
             //Do nothing
         }

     }else{
         [[NSUserDefaults standardUserDefaults]setValue:@"Load" forKey:@"FirstLoad"];
         UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
         LanguageController * infoController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LanguageController"];
         infoController.page_identifier = @"Appdelegate";
         self.navigationController = [[UINavigationController alloc] initWithRootViewController:infoController];
         self.window.rootViewController = self.navigationController;
         self.window.backgroundColor = [UIColor whiteColor];
         [self.window makeKeyAndVisible];
     }
    self.navigationController.navigationBar.hidden = YES;
    [self registerForRemoteNotification];
    [FIRApp configure];
    

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark
#pragma mark - Check NetConnetion

-(BOOL)internetConnected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}
-(void)onStartLoader
{
    loader = [LoadingViewClass new];
    [loader startLoading];
    
}
-(void)onEndLoader
{
    [loader stopLoading];
}

#pragma mark state preservation / restoration

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[self.window makeKeyAndVisible];
    return YES;
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{ BOOL device;
    device=NO;
    //[[FIRAuth auth] setAPNSToken:deviceToken type:FIRAuthAPNSTokenTypeProd];
    NSString *strDevicetoken = [[NSString alloc]initWithFormat:@"%@",[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSLog(@"Device Token = %@",strDevicetoken);
    self.strDeviceToken = strDevicetoken;
    
    [[NSUserDefaults standardUserDefaults] setObject: strDeviceToken forKey:@"device_Token"];
    
    NSString * deviceTokenString = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString: @"<" withString: @""]
                            stringByReplacingOccurrencesOfString: @">" withString: @""]
                           stringByReplacingOccurrencesOfString: @" " withString: @""];

    NSLog(@"The generated device token string is : %@",deviceTokenString);
    [[NSUserDefaults standardUserDefaults] setObject: deviceTokenString forKey:@"device_Token"];
    NSLog(@"device token %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"device_Token"]);
    
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)notification
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  // Pass notification to auth and check if they can handle it.
  if ([[FIRAuth auth] canHandleNotification:notification]) {
    completionHandler(UIBackgroundFetchResultNoData);
    return;
  }
  // This notification is not auth related, developer should handle it.
}
-(void)showLoadingWithTitle:(NSString *)title
{
    
}

-(void)hideLoadingView
{
}
-(void)addShadowto:(UIView *)view {
    // drop shadow
}
//connected
- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return (networkStatus != NotReachable);
}
//shared appdelegate
+(AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}




-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSLog(@"User Info = %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    
    NSLog(@"User Info = %@",response.notification.request.content.userInfo);
    completionHandler();
}

#pragma mark - Class Methods

/**
 Notification Registration
 */
- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
              
            }
        }];
    }
    else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}



@end
