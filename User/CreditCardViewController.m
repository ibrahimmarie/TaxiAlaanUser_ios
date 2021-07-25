//
//  CreditCardViewController.m
//  User
//
//  Created by iCOMPUTERS on 18/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "CreditCardViewController.h"
#import "Colors.h"
#import "CSS_Class.h"
#import "config.h"
#import "CommenMethods.h"
#import "Stripe.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ViewController.h"
#import "HomeViewController.h"


@interface CreditCardViewController ()
{
    AppDelegate *appDelegate;
}

@end

@implementation CreditCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setDesignStyles];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self LocalizationUpdate];
}

-(void)LocalizationUpdate{
    _navicationTlytleLnl.text = LocalizedString(@"Add credit or debit card");
    _cardLbl.text = LocalizedString(@"Card number");
    [_addBtn setTitle:LocalizedString(@"ADD") forState:UIControlStateNormal];
}
-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backBtn:(id)sender
{
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)addBtn:(id)sender
{
    if ([_cardText.text isEqualToString:@""] || [_dateText.text isEqualToString:@""] || [_cvvText.text isEqualToString:@""])
    {
        [CommenMethods alertviewController_title:LocalizedString(@"Alert") MessageAlert:LocalizedString(@"CARD_DETAILS") viewController:self okPop:NO];
    }
    else
    {
        
        NSArray *dateStr = [_dateText.text componentsSeparatedByString:@"-"];
        
        int mm = [[dateStr objectAtIndex:0] intValue];
        int yyyy = [[dateStr objectAtIndex:1] intValue];
        
        NSString *cardno = _cardText.text;
        //  NSString *lastfour = [cardno substringFromIndex: [cardno length] - 4];
        
        
        cardno = [cardno stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        STPCardParams *cardParams = [[STPCardParams alloc] init];
        cardParams.number = cardno;
        cardParams.expMonth = mm;
        cardParams.expYear = yyyy;
        cardParams.cvc = _cvvText.text;
        
        if ([appDelegate internetConnected])
        {
            [appDelegate onStartLoader];
            [[STPAPIClient sharedClient] createTokenWithCard:cardParams completion:^(STPToken* token, NSError *error)
             {
                 NSLog(@"STRIPE TOKEN ..%@", token);
                 [appDelegate onEndLoader];
                 if (!error)
                 {
                     if ([appDelegate internetConnected])
                     {
                         NSDictionary *params=@{@"stripe_token":[token tokenId]};
                         AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                         [appDelegate onStartLoader];
                         [afn getDataFromPath:MD_ADD_CARD withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
                             [appDelegate onEndLoader];
                             if (response)
                             {
                                 UIAlertController * alert = [UIAlertController
                                                              alertControllerWithTitle:@"Success!"
                                                              message:response[@"message"]
                                                              preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 //Add Buttons
                                 UIAlertAction* yesButton = [UIAlertAction
                                                             actionWithTitle:LocalizedString(@"OK")
                                                             style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //Handle your yes please button action here
                                                                 [self dismissViewControllerAnimated:YES completion:nil];
                                                             }];
                                 [alert addAction:yesButton];
                                 [self presentViewController:alert animated:YES completion:nil];
                             }
                             else
                             {
                                 if ([errorcode intValue]==1)
                                 {
                                     [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                                 }
                                 else if ([errorcode intValue]==3)
                                 {
//                                     [CommenMethods onRefreshToken];
                                     
                                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_IMG];
                                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_NAME];
                                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_TOKEN_TYPE];
                                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_ACCESS_TOKEN];
                                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_REFERSH_TOKEN];
                                     
                                     ViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                                     [self.navigationController pushViewController:wallet animated:YES];
                                 }
                             }
                             
                         }];
                     }
                     else
                     {
                         [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
                     }
                     
                 }
                 else
                 {
                     [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CARD") viewController:self okPop:NO];
                 }
                 
                 ///
             }];
        }
        else
        {
            [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
        }
    }
}

-(void)setDesignStyles
{
    [CSS_Class APP_Blackbutton:_addBtn];
    
    [CSS_Class APP_fieldValue_Small:_cardLbl];
    [CSS_Class APP_fieldValue_Small:_countryLbl];
    
    [CSS_Class APP_textfield_Outfocus:_cardText];
    [CSS_Class APP_textfield_Outfocus:_countryText];
    [CSS_Class APP_textfield_Outfocus:_dateText];
    [CSS_Class APP_textfield_Outfocus:_cvvText];

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 43, 30)];
    _cardText.leftView = paddingView;
    _cardText.leftViewMode = UITextFieldViewModeAlways;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==_cardText)
    {
        [_dateText becomeFirstResponder];
    }
    else if(textField==_dateText)
    {
        [_cvvText becomeFirstResponder];
    }
    else if(textField==_cvvText)
    {
        [_countryText becomeFirstResponder];
    }
    else if(textField==_countryText)
    {
        [_countryText resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == _cardText)
    {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 16 || returnKey;
    }
    else if(textField == _cvvText)
    {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 4 || returnKey;
    }
    else if(textField == _dateText)
    {
        int length = [self getLength:textField.text];
        
        if(length == 5)
        {
            if(range.length == 0)
                return NO;
        }
        if(length == 2)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"%@-",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:2]];
        }
        
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 5 || returnKey;
    }
    else
    {
        return YES;
    }
    
    return NO;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    @try
    {
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
        
        int length = (int)[mobileNumber length];
        if(length > 10)
        {
            mobileNumber = [mobileNumber substringFromIndex: length-10];
        }
        return mobileNumber;
    }
    @catch (NSException *exception)
    {
    }
    @finally
    {
        
    }
}


- (int)getLength:(NSString*)mobileNumber
{
    @try
    {
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
        
        int length = (int)[mobileNumber length];
        
        return length;
        
    }
    @catch (NSException *exception)
    {
    
    }
    @finally
    {
        
    }
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


@end
