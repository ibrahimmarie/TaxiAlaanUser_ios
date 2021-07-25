//
//  RegisterViewController.m
//  User
//
//  Created by iCOMPUTERS on 12/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "RegisterViewController.h"
#import "CSS_Class.h"
#import "EmailViewController.h"
#import "config.h"
#import "UIScrollView+EKKeyboardAvoiding.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "CommenMethods.h"
#import "ViewController.h"
#import "Utilities.h"
#import "Colors.h"
#import "ValidateViewController.h"
#import "CountryCodeController.h"
#import "PasswordViewController.h"
@import GoogleMobileAds;
@interface RegisterViewController ()
{
    AppDelegate *appDelegate;
     NSString* UDID_Identifier;
    NSString *strLoginType,*emailStr, *firstNameStr, *lastNameStr, *passwordStr,*code;
    
    __weak IBOutlet GADBannerView *bannerView;
    
}

@end

@implementation RegisterViewController
{
    AKFAccountKit *_accountKit;
    UIViewController<AKFViewController> *_pendingLoginViewController;
    NSString *_authorizationCode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];

    appDelegate.strSmsFrom=@"register";
    // initialize Account Kit
   
    strLoginType=@"manual";
    
    //_emailText.text=appDelegate.strEmail;
    
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, 20)];
    _RegcountrycodeTF.leftView = paddingView1;
    _RegcountrycodeTF.leftViewMode = UITextFieldViewModeAlways;
 
    
    [_emailText becomeFirstResponder];
    
    [_detailsScrollView setContentSize:[_detailsScrollView frame].size];
    [_detailsScrollView setKeyboardAvoidingEnabled:YES];
    
    [self setDesignStyles];
    [self setDefaultValues];
    [self adsGoogle];
}

- (void)setDefaultValues
{
    [self parseJSON];
    
    dialCodeStr = @"";
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSLog(@"country code %@",countryCode);
    
    for (int i=0; i<countriesList.count; i++)
    {
        NSDictionary *countryDict = [countriesList objectAtIndex:i];
        
        NSString *code = [countryDict valueForKey:@"code"];
        
        if ([code isEqualToString:countryCode])
        {
            dialCodeStr = [countryDict valueForKey:@"dial_code"];
        }
    }
    _RegcountrycodeTF.text = dialCodeStr;
    [[NSUserDefaults standardUserDefaults] setValue:dialCodeStr forKey:@"dial_code"];
    NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@", countryCode];
    UIImage *image = [UIImage imageNamed:imagePath];
    _RegcountryflagImgeView.image = image;
    isFlagSet = @"YES";
    [[NSUserDefaults standardUserDefaults] setValue:isFlagSet forKey:@"isFlag"];
}

- (void)parseJSON {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"countryCodes" ofType:@"json"]];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    if (localError != nil) {
        NSLog(@"%@", [localError userInfo]);
    }
    countriesList = (NSArray *)parsedObject;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@",appDelegate.strSmsFrom);
    [self LocalizationUpdate];
    if ([appDelegate.strSmsFrom isEqualToString:@"validation"] || (_strPhn != nil))
    {
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        NSString *email = [user valueForKey:@"email"];
        NSString *firstName = [user valueForKey:@"firstName"];
        NSString *lastName = [user valueForKey:@"lastName"];
        NSString *password = [user valueForKey:@"password"];


        _emailText.text=email;
        _firstNameText.text=firstName;
        _lastNameText.text=lastName;
        _passwordText.text=password;
        _phoneText.text=_strPhn;

      //  [self onRegister];
    }
    else
    {
        
    }
    
    isFlagSet = [[NSUserDefaults standardUserDefaults] valueForKey:@"isFlag"];
    if ([isFlagSet isEqualToString:@"YES"])
    {
        
    }
    else
    {
        dialCodeStr =[[NSUserDefaults standardUserDefaults] valueForKey:@"dial_code"];
        NSString *country_flag=[[NSUserDefaults standardUserDefaults] valueForKey:@"country_flag"];
        
        country_flag = [Utilities removeNullFromString:country_flag];
        dialCodeStr = [Utilities removeNullFromString:dialCodeStr];
        
        if ([country_flag isEqualToString:@""])
        {
            
        }
        else
        {
            UIImage *image = [UIImage imageNamed:country_flag];
            _RegcountryflagImgeView.image = image;
        }
        
        self.RegcountrycodeTF.text = dialCodeStr;
    }
}

-(void) adsGoogle{
    
    bannerView.adUnitID = @"ca-app-pub-6606021354718512/2529734610";
    bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [bannerView loadRequest:request];
    
}

-(void)LocalizationUpdate{
    _headerLbl.text = LocalizedString(@"Enter the details to register");
    _emailLbl.text = LocalizedString(@"Mobile number");
    _firstNameLbl.text = LocalizedString(@"Name");
    _firstNameText.placeholder =LocalizedString(@"First name");
    _lastNameText.placeholder =LocalizedString(@"Last name");
    _passwordLbl.text = LocalizedString(@"E-mail");
    _phoneLbl.text = LocalizedString(@"Phone Number");
    _emailText.text =  _mobilenumber;
    _emailText.enabled = NO;
    _textFieldCode.placeholder = LocalizedString(@"IntroducerCode");
    _labelCode.text = LocalizedString(@"IntroducerCode");

    _RegcountrycodeTF.hidden = true;
    _RegcountryflagImgeView.hidden = true;
    
}

-(void)setDesignStyles
{
    [CSS_Class APP_labelName:_headerLbl];
    [CSS_Class APP_textfield_Outfocus:_emailText];
    [CSS_Class APP_textfield_Outfocus:_firstNameText];
    [CSS_Class APP_textfield_Outfocus:_RegcountrycodeTF];
    [CSS_Class APP_textfield_Outfocus:_lastNameText];
    [CSS_Class APP_textfield_Outfocus:_passwordText];
    [CSS_Class APP_textfield_Outfocus:_phoneText];
    [CSS_Class APP_textfield_Outfocus:_textFieldCode];
    
    [CSS_Class APP_labelName_Small:_emailLbl];
    [CSS_Class APP_labelName_Small:_firstNameLbl];
    [CSS_Class APP_labelName_Small:_lastNameLbl];
    [CSS_Class APP_labelName_Small:_passwordLbl];
    [CSS_Class APP_labelName_Small:_phoneLbl];
    [CSS_Class APP_labelName_Small:_labelCode];
    _emailText.placeholder = LocalizedString(@"PHN_NO");
    _passwordText.placeholder = LocalizedString(@"EMAIL_EG");

}

-(IBAction)backBtn:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    ViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==_emailText)
    {
        [_firstNameText becomeFirstResponder];
    }
    else if(textField==_firstNameText)
    {
        [_lastNameText becomeFirstResponder];
    }
    else if(textField==_lastNameText)
    {
        [_passwordText becomeFirstResponder];
    }
    else if(textField==_passwordText)
    {
        [_passwordText resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if((textField == _emailText) || (textField == _firstNameText) || (textField == _lastNameText))
    {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= INPUTLENGTH || returnKey;
    }
    else if (textField == _phoneText)
    {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= PHONELENGTH || returnKey;
    }
    else
    {
        return YES;
    }
    return NO;
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

-(IBAction)Nextbtn:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *phonenumber = _emailText.text;
    
    if((_emailText.text.length==0) || (_firstNameText.text.length==0) || (_lastNameText.text.length==0))
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:LocalizedString(@"VALIDATE") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
    //}else if (([self validatePhoneWithString:[NSString stringWithFormat:@"%@%@%@", @"+", _codeCountry,_mobilenumber]] == NO) || (self.emailText.text.length > 12)){
       // [self.view makeToast:LocalizedString(@"VALIDATEMOBILE")];
    }else{
        
        emailStr=_emailText.text;
        passwordStr=_passwordText.text;
        firstNameStr=_firstNameText.text;
        lastNameStr=_lastNameText.text;
        
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        [user setObject:emailStr forKey:@"email"];
        [user setObject:passwordStr forKey:@"password"];
        [user setObject:firstNameStr forKey:@"firstName"];
        [user setObject:lastNameStr forKey:@"lastName"];
        [user setValue:self->lastNameStr forKey:UD_PROFILE_NAME_LAST];
        //PasswordViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PasswordViewController"];
        //controller.callbackstring = @"register";
        //[self.navigationController pushViewController:controller animated:YES];
        //[self sendotp:phonenumber];
        [self registeruserdetails:_mobilenumber];
    }
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePhoneWithString:(NSString*)phone
{
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}



-(void)registeruserdetails:(NSString *)otp{
    if ([appDelegate internetConnected])
    {
         UDID_Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; 
        NSDictionary * params=@{@"mobile":_mobilenumber,
                                @"first_name":firstNameStr,
                                @"last_name":lastNameStr,
                              //  @"country_code":[NSString stringWithFormat:@"%@",_codeCountry],
                                @"email":passwordStr,
                                @"device_token":[[NSUserDefaults standardUserDefaults]objectForKey:@"device_Token"],
                                @"device_type":@"ios",
                                @"device_id":UDID_Identifier,
                                @"share_key":_textFieldCode.text,
                                @"app_version":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

                                };
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:MD_REGMOB withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [self->appDelegate onEndLoader];
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
                [user setValue:self->lastNameStr forKey:UD_PROFILE_NAME_LAST];
                [user setValue:strProfile forKey:UD_PROFILE_IMG];
                [user setValue:socialIdStr forKey:UD_SOCIAL];
                [user setValue:[response valueForKey:@"id"] forKey:UD_ID];
                [user setValue:[response valueForKey:@"sos"] forKey:UD_SOS];
                [user setValue:response[@"share_key"] forKey:@"share_key"];
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

@end
