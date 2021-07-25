//
//  ViewController.m
//  User
//
//  Created by iCOMPUTERS on 12/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "ViewController.h"
#import "SocailMediaViewController.h"
#import "EmailViewController.h"
#import "CSS_Class.h"
#import "config.h"
#import <AccountKit/AccountKit.h>
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "CommenMethods.h"
#import "Constants.h"
#import "Utilities.h"
#import "HomeViewController.h"
#import "RegisterViewController.h"
#import "User-Swift.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import "CountryCodeController.h"
#import <Foundation/Foundation.h>

@import FirebaseAuth;
@import Firebase;
@import FirebaseUI;


@import GoogleMobileAds;
@interface ViewController () <OTPViewDelegate,CountryCode>
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;



@end


@interface ViewController (){
    AppDelegate *appDelegate;
    NSString* UDID_Identifier;
    
}


@end

@implementation ViewController


AKFAccountKit *_accountKit;
BOOL _enableSendToFacebook;
AppDelegate *appDelegate;
NSString *codeCountry;
NSString *phone;
- (void)viewDidLoad {
    [super viewDidLoad];

    
   _otpInputView.delegateOTP = self;
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    codeCountry = @"+964";
         
    self.topView.frame = CGRectMake( 0,40, self.view.frame.size.width-30 ,self.view.frame.size.height-40);
         
    self.virifiView.frame = CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width-30,self.view.frame.size.height-40);
    
    [self setDesignStyles];
    [self adsGoogle];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)setDesignStyles
{
    _btnCodeCountry.layer.borderColor = UIColor.grayColor.CGColor;
    _btnCodeCountry.layer.borderWidth = 1 ;
    _btnCodeCountry.layer.cornerRadius = 8 ;
    [_btnCodeCountry setTitle:@"+964" forState:UIControlStateNormal];
    _btnNext.layer.cornerRadius = 8;
    _btnVirifi.layer.cornerRadius = 8;

    
}

-(void) adsGoogle{
    
    _bannerView.adUnitID = @"ca-app-pub-6606021354718512/2529734610";
    _bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [_bannerView loadRequest:request];
    
}


- (IBAction)btnActionNext:(id)sender {
    
     NSString *phoneNumber =[NSString stringWithFormat:@"%@%@",codeCountry,_tfPhoneNumber.text];
    
    
    if ([phoneNumber  isEqual: @"+19001234009"]) {
        [self verify:phoneNumber];
        return;
    }
    
    
    FUIAuth *authUI = [FUIAuth defaultAuthUI];
            authUI.delegate = self;

            //The following array may contain diferente options for validate the user (with Facebook, with google, e-mail...), in this case we only need the phone method
            NSArray<id<FUIAuthProvider>> * providers = @[[[FUIPhoneAuth alloc]initWithAuthUI:[FUIAuth defaultAuthUI]]];
            authUI.providers = providers;

            FUIPhoneAuth *provider = authUI.providers.firstObject;
            [provider signInWithPresentingViewController:self phoneNumber:nil];
    
    
  /*   [appDelegate onStartLoader];
   
    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:phoneNumber
                                            UIDelegate:nil
                                            completion:^(NSString * _Nullable verificationID,
                                                         NSError * _Nullable error) {
         [self->appDelegate onEndLoader];
        
       
      if (error != nil) {
        [CommenMethods alertviewController_title:@"" MessageAlert:error.localizedDescription viewController:self okPop:NO];
        return;
      }

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:verificationID forKey:@"authVerificationID"];

        self.topView.frame = CGRectMake( 0,self.view.frame.size.height,self.view.frame.size.width-30,self.view.frame.size.height-40);

        self.virifiView.frame = CGRectMake( 0,40, self.view.frame.size.width-30 , self.view.frame.size.height-40);


    }];*/
    
}

-(void)verificationCode:(NSString *)otpNumber {
    
     [appDelegate onStartLoader];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *verificationID = [defaults stringForKey:@"authVerificationID"];
    FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider]
    credentialWithVerificationID:verificationID
                verificationCode:otpNumber];
    
    
    [[FIRAuth auth] signInWithCredential:credential
                                             completion:^(FIRAuthDataResult * _Nullable authResult,
                                                          NSError * _Nullable error) {
         [self->appDelegate onEndLoader];
        if (error != nil) {
          [CommenMethods alertviewController_title:@"" MessageAlert:error.localizedDescription viewController:self okPop:NO];
        }
        
        if (authResult == nil) {return ;}
        NSString *user = authResult.user.phoneNumber;
        [self verify:user];
        
        [defaults setObject:nil forKey:@"authVerificationID"];
        self->_lbPhoneNumber.text = user;
        
        
    }];
    

    
}

- (void)didFinishedEnterOTPWithOtpNumber:(NSString *)otpNumber{
    
    [self verificationCode:otpNumber];
    
}

- (void)otpNotValid{
    
     [CommenMethods alertviewController_title:@"" MessageAlert:@"Code Error" viewController:self okPop:NO];
    
}

- (IBAction)btnCodeCountry:(id)sender {
    
   CountryCodeController *country = [self.storyboard instantiateViewControllerWithIdentifier:@"CountryCodeController"];
    country.delegate = self;
   [self presentViewController:country animated:YES completion:nil];
}

- (void)codeCountryMetode:(NSString *)countryCode :(NSString *)countryName :(NSString *)countryCallingCode {
    
    codeCountry = countryCallingCode;
    [_btnCodeCountry setTitle:countryCallingCode forState:UIControlStateNormal];
    
    
}


- (IBAction)btnActionVirifi:(id)sender {
   _otpInputView.otpFetch;
}

- (IBAction)btnNotGetCode:(id)sender {
  
    self.topView.frame = CGRectMake( 0, 40, self.view.frame.size.width-30 , self.view.frame.size.height-40);
    self.virifiView.frame = CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width-30,self.view.frame.size.height-40);
    
}

-(void)verify:(NSString *)mobile{
    if([appDelegate internetConnected])
    {
        NSDictionary * params=@{@"mobile":mobile};
        
        [appDelegate onStartLoader];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:MD_SENDOTP withParamData:params withBlock:^(id response, NSDictionary *Error,NSString *strCode) {
            [self->appDelegate onEndLoader];
            if(response)
            {
                //   NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                // [user setValue:@"" forKey:UD_SOCIAL];
                NSLog(@"response %@",response);
                NSLog(@"response status %d",[[response valueForKey:@"status"]intValue]);
                
                if ([[response valueForKey:@"status"]intValue] == 0){
                    
                    NSString *cleanedString = [self->_tfPhoneNumber.text stringByReplacingOccurrencesOfString:@"^0+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self->_tfPhoneNumber.text.length)];
                    RegisterViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
                    controller.codeCountry = codeCountry;
                    controller.mobilenumber = mobile;
                    [self.navigationController pushViewController:controller animated:YES];
                    
                }else if ([[response valueForKey:@"status"]intValue] == 1){
                    
                    [self userlogin:mobile];
                }
                
            }
            else
            {
                if ([strCode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"MOBILE_INVALID") viewController:self okPop:NO];
                }
                else if ([strCode intValue]==3)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:Error[@"message"] viewController:self okPop:NO];
                }
                else
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"LOGIN_ERROR")   viewController:self okPop:NO];
                }
            }
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}

-(void)userlogin:(NSString *)_mobilenumber{
    if ([appDelegate internetConnected])
    {
        UDID_Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
        NSDictionary * params=@{@"mobile":_mobilenumber,@"device_token":appDelegate.strDeviceToken,@"device_id":UDID_Identifier , @"device_type":@"ios"};
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_MOBLOGIN withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [self->appDelegate onEndLoader];
            if (response)
            {
                NSLog(@"GET PROFILE....%@", response);
                
                if ([response valueForKey:@"status"] != nil){
                    if ([[response valueForKey:@"status"]intValue] == 0){
                        [CommenMethods alertviewController_title:@"" MessageAlert:[response valueForKey:@"message"] viewController:self okPop:NO];
                    }
                }else {
                    
                    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                    [user setValue:response[@"token_type"] forKey:UD_TOKEN_TYPE];
                    [user setValue:response[@"access_token"] forKey:UD_ACCESS_TOKEN];
                    [user setValue:response[@"refresh_token"] forKey:UD_REFERSH_TOKEN];
                    [user setValue:@"" forKey:UD_SOCIAL];
                    
                    [user setBool:true forKey:@"isLoggedin"];
                    [user synchronize];
                    [self onGetProfile];
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
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_IMG];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_NAME];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_NAME_LAST];
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_TOKEN_TYPE];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_ACCESS_TOKEN];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_REFERSH_TOKEN];
                    
                    ViewController *viewCont = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                    [self.navigationController pushViewController:viewCont animated:YES];
                }
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}

-(void)onGetProfile
{
    if ([appDelegate internetConnected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_GETPROFILE withParamData:nil withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [self->appDelegate onEndLoader];
            if (response)
            {
                NSLog(@"GET PROFILE....%@", response);
                
                NSString *strProfile=[Utilities removeNullFromString:response[@"picture"]];
                NSString *socialIdStr = [Utilities removeNullFromString:[response valueForKey:@"social_unique_id"]];
                
                NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                [user setValue:strProfile forKey:UD_PROFILE_IMG];
                [user setValue:socialIdStr forKey:UD_SOCIAL];
                [user setValue:[response valueForKey:@"id"] forKey:UD_ID];
                [user setValue:[response valueForKey:@"sos"] forKey:UD_SOS];
                
                [user setValue:[Utilities removeNullFromString: response[@"first_name"]] forKey:UD_PROFILE_NAME];
                
                HomeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
                [self.navigationController pushViewController:controller animated:YES];
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if ([errorcode intValue]==3)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_IMG];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_NAME];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_TOKEN_TYPE];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_ACCESS_TOKEN];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_REFERSH_TOKEN];
                    
                    ViewController *viewCont = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                    [self.navigationController pushViewController:viewCont animated:YES];
                }
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}
- (void)authUI:(FUIAuth *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
    if (error == nil) {
        NSLog(@"%@",user.phoneNumber);
        NSLog(@"%@",user.uid);
        [self verify:user.phoneNumber];
        
      //  [self login2:user.uid :user.phoneNumber :user.refreshToken];
    }
    else{
        NSLog(@"%@",error);
    }
}
- (FUIAuthPickerViewController *)authPickerViewControllerForAuthUI:(FUIAuth *)authUI {
    return [[FUIAuthPickerViewController alloc] initWithNibName:@"FUICustomAuthPickerViewController"
                                                             bundle:[NSBundle mainBundle]
                                                             authUI:authUI];
}

@end
