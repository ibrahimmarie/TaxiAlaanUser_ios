//
//  HistoryViewController.m
//  Provider
//
//  Created by iCOMPUTERS on 17/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "HistoryViewController.h"
#import "CSS_Class.h"
#import "config.h"
#import "Colors.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "Constants.h"
#import "CommenMethods.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Utilities.h"
#import "ViewController.h"


@interface HistoryViewController ()
{
    AppDelegate *appDelegate;
}

@end

@implementation HistoryViewController
@synthesize strID;

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setDesignStyles];
    [self getHistory];
    
    if ([_historyHintStr isEqualToString:@"UPCOMING"])
    {
        [_commentsView setHidden:YES];
        [_cashLb setHidden:YES];
    }
    
    self.userImg.layer.cornerRadius=self.userImg.frame.size.height/2;
    self.userImg.clipsToBounds=YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self LocalizationUpdate];
    
}

-(void)LocalizationUpdate{
    _headerLbl.text = LocalizedString(@"History");
    _paymentLb.text = LocalizedString(@"Payment method");
    _commentTitleLb.text = LocalizedString(@"Comments");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setDesignStyles
{
    [CSS_Class APP_fieldValue_Small:_dateLb];
    [CSS_Class APP_SmallText:_timeLb];
    [CSS_Class APP_fieldValue_Small:_nameLb];
    [CSS_Class APP_labelName:_paymentLb];
    [CSS_Class APP_labelName:_commentTitleLb];
    [CSS_Class APP_fieldValue_Small:_payTypeLb];
    [CSS_Class APP_fieldValue:_cashLb];
    [_timeLb setTextColor:TEXTCOLOR_LIGHT];
    
    [CSS_Class APP_SmallText:_pickLb];
    [CSS_Class APP_SmallText:_dropLb];
    [CSS_Class APP_SmallText:_commentsLb];
    
    _userImg.layer.cornerRadius=_userImg.frame.size.height/2;
    _userImg.clipsToBounds=YES;
}
-(void)getHistory
{
    if ([appDelegate internetConnected])
    {
        NSDictionary *param=@{@"request_id":strID};
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [appDelegate onStartLoader];
        
        NSString *serviceStr;
        
        if([_historyHintStr isEqualToString:@"PAST"])
        {
            serviceStr = MD_GET_SINGLE_HISTORY;
        }
        else
        {
            serviceStr = MD_UPCOMING_HISTORYDETAILS;
        }
        
        [afn getDataFromPath:serviceStr withParamData:param withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [appDelegate onEndLoader];
            if (response)
            {
                NSLog(@"History details....%@", response);
                if ([response count]!=0)
                {
                    NSDictionary *dictLocal=[response objectAtIndex:0];
                    
                    NSString *strVal=[dictLocal valueForKey:@"static_map"];
                    NSString *escapedString =[strVal stringByReplacingOccurrencesOfString:@"%7C" withString:@"|"];
                    NSURL *mapUrl = [NSURL URLWithString:[escapedString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
                    [ _mapImg sd_setImageWithURL:mapUrl placeholderImage:[UIImage imageNamed:@"rd-map"]];
                    
                    if (![dictLocal[@"provider"] isKindOfClass:[NSNull class]]) {
                        if (![[dictLocal[@"provider"] valueForKey:@"avatar"] isKindOfClass:[NSNull class]])
                        {
                            NSString *imageUrl =[dictLocal[@"provider"] valueForKey:@"avatar"];
                            
                            if ([imageUrl containsString:@"http"])
                            {
                                imageUrl = [NSString stringWithFormat:@"%@",[dictLocal[@"provider"] valueForKey:@"avatar"]];
                            }
                            else
                            {
                                imageUrl = [NSString stringWithFormat:@"%@/storage/%@",SERVICE_URL, [dictLocal[@"provider"] valueForKey:@"avatar"]];
                            }
                            
                            [ _userImg sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                         placeholderImage:[UIImage imageNamed:@"userProfile"]];
                        }
                        else
                        {
                            _userImg.image=[UIImage imageNamed:@"userProfile"];
                        }
                        
                        _nameLb.text=[NSString stringWithFormat:@"%@" @"%@",[dictLocal[@"provider"] valueForKey:@"first_name"],[dictLocal[@"provider"] valueForKey:@"last_name"]] ;
                        
                        [_btnCall setTitle:[[dictLocal valueForKey:@"provider"] valueForKey:@"mobile"] forState:UIControlStateNormal];
                        
                    }
                    
                    if (![dictLocal[@"rating"] isKindOfClass:[NSNull class]])
                    {
                        if (![[dictLocal[@"rating"] valueForKey:@"provider_rating"] isKindOfClass:[NSNull class]])
                            _userRating.value=[[dictLocal[@"rating"] valueForKey:@"provider_rating"] intValue];
                        else
                            _userRating.value=0;
                        
                        if (![[dictLocal[@"rating"] valueForKey:@"provider_comment"] isKindOfClass:[NSNull class]])
                        {
                            if ([[dictLocal[@"rating"] valueForKey:@"provider_comment"] isEqualToString:@""])
                            {
                                _commentsLb.text=@"no comments";
                            }
                            else
                            {
                                _commentsLb.text=[dictLocal[@"rating"] valueForKey:@"provider_comment"];

                            }
                        }
                    }
                    
                    if (![dictLocal[@"s_address"] isKindOfClass:[NSNull class]])
                        _pickLb.text=dictLocal[@"s_address"];
                    
                    if (![dictLocal[@"d_address"] isKindOfClass:[NSNull class]])
                        _dropLb.text=dictLocal[@"d_address"];
                    
                    if (![dictLocal[@"payment"] isKindOfClass:[NSNull class]])
                    {
                        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                        NSString *currencyStr=[user valueForKey:@"currency"];
                        
                        if([_historyHintStr isEqualToString:@"PAST"])
                        {
                            _cashLb.text= [NSString stringWithFormat:@"%@%@", currencyStr, [dictLocal[@"payment"] valueForKey:@"total"]];
                        }
                        else
                        {
                            _cashLb.text= [NSString stringWithFormat:@"%@0.00", currencyStr];
                        }
                    }
                    
                    if (![dictLocal[@"payment_mode"] isKindOfClass:[NSNull class]])
                        _payTypeLb.text=dictLocal[@"payment_mode"];
                    
                    _dateLb.text=[Utilities convertDateTimeToGMT:dictLocal[@"assigned_at"]];
                    _timeLb.text=[Utilities convertTimeFormat:dictLocal[@"assigned_at"]];
                    _bookingIdLbl.text =[Utilities  removeNullFromString:[dictLocal valueForKey:@"booking_id"]];

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
                    
                    ViewController *logout = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                    [self.navigationController pushViewController:logout animated:YES];
                }
                
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}

-(IBAction)backBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnCallClick:(id)sender {
    if (![sender isKindOfClass:[UIButton class]])
            return;

        NSString *mobileStr = [(UIButton *)sender currentTitle];
    
      if ([mobileStr isEqualToString:@""])
    {
      
    }
    else
    {
        NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:mobileStr]];
        NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:mobileStr]];
        
        if ([UIApplication.sharedApplication canOpenURL:phoneUrl])
        {
            [UIApplication.sharedApplication openURL:phoneUrl options:@{} completionHandler:nil];
        }
        else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl])
        {
            [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:nil];
        }
     
}
}

@end
