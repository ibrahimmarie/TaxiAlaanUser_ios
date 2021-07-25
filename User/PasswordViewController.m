//
//  PasswordViewController.m
//  User
//
//  Created by iCOMPUTERS on 12/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "PasswordViewController.h"
#import "CSS_Class.h"
#import "config.h"
#import "HomeViewController.h"
#import "ForgotPasswordViewController.h"
#import "RegisterViewController.h"
#import "Constants.h"
#import "AFNHelper.h"
#import "AppDelegate.h"
#import "CommenMethods.h"
#import "Utilities.h"
#import "ViewController.h"

@interface PasswordViewController ()
{
    AppDelegate *appDelegate;
    NSString* UDID_Identifier;
}

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    [self setDesignStyles];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
//    [_passwordText becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self LocalizationUpdate];
}

-(void)LocalizationUpdate{
    _helpLbl.text = LocalizedString(@"Enter OTP sent to your mobile number");
    _password_Lbl.text = LocalizedString(@"Resend OTP");
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==_otptxt1){
        [_otptxt2 becomeFirstResponder];
    }else if(textField==_otptxt2){
        [_otptxt3 becomeFirstResponder];
    }else if(textField==_otptxt3){
        [_otptxt4 becomeFirstResponder];
    }else if(textField==_otptxt4){
        [_otptxt4 resignFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)setDesignStyles
{
    [CSS_Class APP_labelName:_helpLbl];
    [CSS_Class APP_textfield_Outfocus:_passwordText];
    
    [CSS_Class APP_SocialLabelName:_password_Lbl];
    [CSS_Class APP_textfield_custom:_otptxt1];
    [CSS_Class APP_textfield_custom:_otptxt2];
    [CSS_Class APP_textfield_custom:_otptxt3];
    [CSS_Class APP_textfield_custom:_otptxt4];
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.text.length >= 1) && (string.length > 0)){
        NSInteger nextTag = textField.tag + 1;
        // Try to find next responder
        UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
        if (! nextResponder)
            nextResponder = [textField.superview viewWithTag:1];
        
        if ((nextResponder)&&(nextTag <= 4))
            // Found next responder, so set it.
            [nextResponder becomeFirstResponder];
        
        return NO;
    }
    return YES;
}*/

//MARK:- TextField Delegate Methods:
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString* )string
{
    if ((textField.text.length < 1) && (string.length > 0)){
        NSInteger nextTag = textField.tag + 1;
        UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
        if (! nextResponder){
            [textField resignFirstResponder];
        }
        textField.text = string;
        if (nextResponder)
            [nextResponder becomeFirstResponder];
        return NO;
    }else if ((textField.text.length >= 1) && (string.length > 0)){  //For Maximum “1” Digit:
        NSInteger nextTag = textField.tag + 1;
        UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
        if (! nextResponder){
            [textField resignFirstResponder];
        }
        textField.text = string;
        if (nextResponder)
            [nextResponder becomeFirstResponder];
        return NO;
    }
    else if ((textField.text.length >= 1) && (string.length == 0)){  //deleting values from textfield:
        NSInteger prevTag = textField.tag - 1;
        UIResponder* prevResponder = [textField.superview viewWithTag:prevTag];
        if (! prevResponder){
            [textField resignFirstResponder];
        }
        textField.text = string;
        if (prevResponder)
            [prevResponder becomeFirstResponder];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
   // [CSS_Class APP_textfield_Infocus:textField];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
   // [CSS_Class APP_textfield_Outfocus:textField];
    return YES;
}

-(IBAction)Nextbtn:(id)sender
{
    NSLog(@"%@",_callbackstring);
    [self.view endEditing:YES];
    
    if(_otptxt1.text.length==0 || _otptxt2.text.length==0 || _otptxt3.text.length==0 || _otptxt4.text.length==0){
        
        [self.view makeToast:LocalizedString(@"OTP_REQ")];
    }else{
         NSString *otpstring = [NSString stringWithFormat:@"%@%@%@%@",_otptxt1.text,_otptxt2.text,_otptxt3.text,_otptxt4.text];
        if ([self.callbackstring isEqualToString:@"signin"]){
            
            [self userlogin:otpstring];
        }else if ([self.callbackstring isEqualToString:@"register"]){
            [self verifyotp:otpstring];
        }
    }
}

-(void)verifyotp:(NSString *)opt{
    if([appDelegate internetConnected])
    {
        NSDictionary * params=@{@"otp":opt,@"request_id":_requestid};
        
        [appDelegate onStartLoader];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:MD_VERIFYOTP withParamData:params withBlock:^(id response, NSDictionary *Error,NSString *strCode) {
            [appDelegate onEndLoader];
            if(response)
            {
                NSLog(@"%@",response);
                
                [self registeruserdetails:opt];
            }
            else
            {
                if ([strCode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
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

-(void)registeruserdetails:(NSString *)otp{
    if ([appDelegate internetConnected])
    {
        NSDictionary * params=@{@"mobile":_mobilenumber,@"otp":otp,@"request_id":_requestid,@"first_name":_firstnamestr,@"last_name":_lastnamestr,@"country_code":_countrycodestr,@"email":_email};
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_REGMOB withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [appDelegate onEndLoader];
            if (response)
            {
                NSLog(@"GET PROFILE....%@", response);
                
                NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                [user setValue:response[@"token_type"] forKey:UD_TOKEN_TYPE];
                [user setValue:response[@"access_token"] forKey:UD_ACCESS_TOKEN];
                [user setValue:response[@"refresh_token"] forKey:UD_REFERSH_TOKEN];
                [user setValue:@"" forKey:UD_SOCIAL];
                
                [user setBool:true forKey:@"isLoggedin"];
                [user synchronize];
                
                [self onGetProfile];
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

-(void)userlogin:(NSString *)otp{
    if ([appDelegate internetConnected])
    {
        UDID_Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
        NSDictionary * params=@{@"mobile":_mobilenumber,@"otp":otp,@"request_id":_requestid,@"type":@"exist",@"device_token":appDelegate.strDeviceToken,@"device_id":UDID_Identifier , @"device_type":@"ios"};

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

//MARK:- Old password call method:
/*
-(void)verifypassword{
    if([appDelegate internetConnected])
    {
        NSDictionary * params=@{@"username":appDelegate.strEmail,@"password":_passwordText.text,@"device_token":appDelegate.strDeviceToken,@"grant_type":@"password",@"device_type":@"ios",@"client_id":ClientID,@"client_secret":Client_SECRET};
        
        [appDelegate onStartLoader];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:MD_LOGIN withParamData:params withBlock:^(id response, NSDictionary *Error,NSString *strCode) {
            [appDelegate onEndLoader];
            if(response)
            {
                NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                [user setValue:response[@"token_type"] forKey:UD_TOKEN_TYPE];
                [user setValue:response[@"access_token"] forKey:UD_ACCESS_TOKEN];
                [user setValue:response[@"refresh_token"] forKey:UD_REFERSH_TOKEN];
                [user setValue:@"" forKey:UD_SOCIAL];
                
                [user setBool:true forKey:@"isLoggedin"];
                [user synchronize];
                
                //                    HomeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
                //                    [self.navigationController pushViewController:controller animated:YES];
                [self onGetProfile];
            }
            else
            {
                if ([strCode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
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
    
}*/

-(void)onGetProfile
{
    if ([appDelegate internetConnected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_GETPROFILE withParamData:nil withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [appDelegate onEndLoader];
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


-(IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)passwordbtn:(id)sender
{
//    ForgotPasswordViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
//    [self.navigationController pushViewController:controller animated:YES];
    [self sendotp:_mobilenumber];
}

-(void)sendotp:(NSString *)mobile{
    if([appDelegate internetConnected])
    {
        NSDictionary * params=@{@"mobile":mobile};
        
        [appDelegate onStartLoader];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:MD_SENDOTP withParamData:params withBlock:^(id response, NSDictionary *Error,NSString *strCode) {
            [appDelegate onEndLoader];
            if(response)
            {
                NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                [user setValue:@"" forKey:UD_SOCIAL];
                NSLog(@"response %@",response);
                NSLog(@"response status %d",[[response valueForKey:@"status"]intValue]);
                
                if ([[response valueForKey:@"status"]intValue] == 0){
                    [CommenMethods alertviewController_title:@"" MessageAlert:[response valueForKey:@"message"] viewController:self okPop:NO];
                }else if ([[response valueForKey:@"status"]intValue] == 1){
                    [self.view makeToast:LocalizedString(@"OTP sent to your number")];
                    self->_requestid = [response valueForKey:@"request_id"];
                }
                self->_otptxt1.text = @"";
                self->_otptxt2.text = @"";
                self->_otptxt3.text = @"";
                self->_otptxt4.text = @"";
                
                /*NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                 [user setValue:response[@"token_type"] forKey:UD_TOKEN_TYPE];
                 [user setValue:response[@"access_token"] forKey:UD_ACCESS_TOKEN];
                 [user setValue:response[@"refresh_token"] forKey:UD_REFERSH_TOKEN];
                 [user setValue:@"" forKey:UD_SOCIAL];
                 
                 [user setBool:true forKey:@"isLoggedin"];
                 [user synchronize];*/
                
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


- (IBAction)ShowPass:(UIButton *)sender
{
    if (self.passwordText.secureTextEntry == YES)
    {
        self.passwordText.secureTextEntry = NO;
    }
    else
    {
        self.passwordText.secureTextEntry = YES;
    }
}


@end
