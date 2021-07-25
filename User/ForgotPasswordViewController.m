//
//  ForgotPasswordViewController.m
//  User
//
//  Created by iCOMPUTERS on 12/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "EmailViewController.h"
#import "CSS_Class.h"
#import "config.h"
#import "Constants.h"
#import "CommenMethods.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface ForgotPasswordViewController ()
{
    AppDelegate *appDelegate;
    NSString *emailString, *emailAddressStr, *idStr, *strEmail;
    BOOL backstatus;
}

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setDesignStyles];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    strEmail=appDelegate.strEmail;
    _emailAddress.text=strEmail;
    [_emailAddress becomeFirstResponder];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    backstatus = NO;
    [self LocalizationUpdate];
}
-(void)LocalizationUpdate{
    _helpLbl.text = LocalizedString(@"Enter the Password");
    _confirmPassLbl.text = LocalizedString(@"Confirm Password");
    _otpLbl.text = LocalizedString(@"Otp");
    _passLbl.text = LocalizedString(@"New Password");
    _emailLbl.text = LocalizedString(@"E-mail");
    [_changePasswordBtn setTitle:LocalizedString(@"Reset password") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

-(void)setDesignStyles
{
    [CSS_Class APP_labelName:_helpLbl];
    [CSS_Class APP_textfield_Outfocus:_emailAddress];
    [CSS_Class APP_textfield_Outfocus:_passText];
    [CSS_Class APP_textfield_Outfocus:_confirmPassText];
    [CSS_Class APP_textfield_Outfocus:_OtpText];

    [CSS_Class APP_labelName_Small:_passLbl];
    [CSS_Class APP_labelName_Small:_confirmPassLbl];
    [CSS_Class APP_Blackbutton:_changePasswordBtn];
}

-(IBAction)backBtn:(id)sender
{
    backstatus = YES;
    EmailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==_emailAddress)
    {
        [self validateEmailAddress];
    }
    else if(textField==_passText)
    {
        [_confirmPassText becomeFirstResponder];
    }
    else if(textField==_confirmPassText)
    {
        [_confirmPassText resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(textField == _passText)
    {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= PASSWORDLENGTH || returnKey;
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
    if ((textField == _emailAddress) && (backstatus == NO))
    {
        [self validateEmailAddress];
    }
    [CSS_Class APP_textfield_Outfocus:textField];
    return YES;
}

-(void)validateEmailAddress
{
    [self.view endEditing:YES];
    emailString = @"true";
    
    if(_emailAddress.text.length != 0)
    {
        NSString *email = _emailAddress.text;
        NSString *emailRegEx =
        @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
        @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        NSPredicate *regExPredicate =
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:email];
        
        if(myStringMatchesRegEx)
        {
            emailString = @"true";
        }
        else
        {
            emailString = @"false";
        }
    }
    
    if(_emailAddress.text.length==0)
    {
        emailString = false;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"Alert!") message:LocalizedString(@"EMAIL_REQ") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else if ([emailString isEqualToString:@"false"])
    {
        emailString = false;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"Alert!") message:LocalizedString(@"EMAIL_INVALID") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    if ([emailString isEqualToString:@"true"])
    {
        NSDictionary *params=@{@"email":_emailAddress.text};
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        
        [appDelegate onStartLoader];
        
        [afn getDataFromPath:MD_FORGOTPASSWORD withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [appDelegate onEndLoader];
            if (response) {
                
                NSDictionary *dict = [response valueForKey:@"user"];
                
                emailAddressStr = [dict valueForKey:@"email"];
                idStr = [dict valueForKey:@"id"];
                strOtp=[NSString stringWithFormat:@"%@", [dict valueForKey:@"otp"]];
                [_passText becomeFirstResponder];
                
                [CommenMethods alertviewController_title:@"" MessageAlert:[response valueForKey:@"message"] viewController:self okPop:NO];
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if([errorcode  intValue]==3)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_IMG];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_NAME];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_TOKEN_TYPE];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_ACCESS_TOKEN];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_REFERSH_TOKEN];
                    
                    ViewController *logout = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                    [self.navigationController pushViewController:logout animated:YES];
                }
                else{
                    if ([error objectForKey:@"email"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"email"] objectAtIndex:0]  viewController:self okPop:NO];
                        _emailAddress.text =@"";
                        [_emailAddress becomeFirstResponder];
                    }
                    else {
                        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG")  viewController:self okPop:NO];
                    }
                    
                }
            }
        }];
        
    }
}


-(IBAction)Nextbtn:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *otp = [NSString stringWithFormat:@"%@", _OtpText.text];
   
    if(_emailAddress.text.length==0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:LocalizedString(@"EMAIL_PWD") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else if(_passText.text.length==0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:LocalizedString(@"NEW_PWD") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else if(_confirmPassText.text.length==0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:LocalizedString(@"CON_PWD") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else if(![_passText.text isEqualToString:_confirmPassText.text])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:LocalizedString(@"MATCH_PWD") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if ([_OtpText.text isEqualToString:@""])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:@"Please enter the OTP" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (![otp isEqualToString:strOtp])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"ALERT") message:@"You entered wrong Otp " preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        NSDictionary *params=@{@"email":emailAddressStr,@"password":_passText.text,@"password_confirmation":_confirmPassText.text, @"id":idStr};
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        
        [appDelegate onStartLoader];
        
        [afn getDataFromPath:MD_RESETPASSWORD withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
             [appDelegate onEndLoader];
            if (response) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:LocalizedString(@"PWD_CHD") preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *ok=[UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isLoggedin"];
                    
                    ViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                    [self.navigationController pushViewController:wallet animated:YES];
                    
                }];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else
            {
                if ([errorcode intValue]==1)
                {
                    [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
                else if([errorcode  intValue]==3)
                {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_IMG];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_NAME];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_TOKEN_TYPE];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_ACCESS_TOKEN];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_REFERSH_TOKEN];
                    
                    ViewController *logout = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                    [self.navigationController pushViewController:logout animated:YES];
                }
                else{
                    if ([error objectForKey:@"old_password"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"old_password"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                    else if ([error objectForKey:@"password"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"password"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                    else if ([error objectForKey:@"password_confirmation"]) {
                        [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"password_confirmation"] objectAtIndex:0]  viewController:self okPop:NO];
                    }
                   
                }
            }
        }];
     
    }
}


@end
