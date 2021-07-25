//
//  CouponsViewController.m
//  User
//
//  Created by iCOMPUTERS on 18/01/17.
//  Copyright © 2017 iCOMPUTERS. All rights reserved.
//

#import "CouponsViewController.h"
#import "CSS_Class.h"
#import "Colors.h"
#import "config.h"
#import "AFNHelper.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "CommenMethods.h"
#import "ViewController.h"

@interface CouponsViewController ()
{
    AppDelegate *appDelegate;
}

@end

@implementation CouponsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setDesignStyles];
    [self getPromoCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDesignStyles
{
    [CSS_Class APP_Blackbutton:_addBtn];
    [CSS_Class APP_textfield_Outfocus:_couponText];
    [_listTableView setBackgroundColor:[UIColor clearColor]];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==_couponText)
    {
        [_couponText resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(textField == _couponText)
    {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= 20 || returnKey;
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
    
    if(_couponText.text.length==0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedString(@"Alert!") message:LocalizedString(@"PROMO_CODE") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        if ([appDelegate internetConnected])
        {
            [appDelegate onStartLoader];
            NSDictionary * params= @{@"promocode":_couponText.text};
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
           [afn getDataFromPath:@"api/user/promocode/add" withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
               [self->appDelegate onEndLoader];
                if (response)
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[response valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:LocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                         {
                                         }];
                    [alertController addAction:ok];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                    if ([[response valueForKey:@"code"] isEqualToString:@"promocode_applied"])
                    {
                        [self getPromoCode];
                    }
                }
                else
                {
                    if ([errorcode intValue]==1)
                    {
                        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                    }
                    else if([errorcode  intValue]==3)
                    {
//                        [CommenMethods onRefreshToken];
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_IMG];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_PROFILE_NAME];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_TOKEN_TYPE];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_ACCESS_TOKEN];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UD_REFERSH_TOKEN];
                        
                        ViewController *wallet = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                        [self.navigationController pushViewController:wallet animated:YES];
                    }
                    else{
                        if ([error objectForKey:@"promocode"]) {
                            [CommenMethods alertviewController_title:@"" MessageAlert:[[error objectForKey:@"promocode"]objectAtIndex:0]  viewController:self okPop:NO];
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
}

-(void)getPromoCode
{
    if ([appDelegate internetConnected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [appDelegate onStartLoader];
        [afn getDataFromPath:@"api/user/promocodes" withParamData:nil withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
            [self->appDelegate onEndLoader];
            if (response)
            {
                if (response ==0)
                {
                    //No PromoCode Avaliable
                }
                else
                {
                    self->promoArray = [[NSMutableArray alloc]init];
                    self ->ghemat = [[NSMutableArray alloc]init];
                    for (int i=0; i<[response count]; i++)
                    {
                        NSDictionary *dict = [response objectAtIndex:i];
                        NSDictionary *promoDict = [dict valueForKey:@"promocode"];
                        NSString *str = [promoDict valueForKey:@"promo_code"];
                        NSString *gh = [dict valueForKey:@"discount"];
                        [self-> promoArray addObject:str];
                        [self -> ghemat addObject:gh];
                    }
                    self->_couponText.text =@"";
                    [self->_listTableView reloadData];
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
                }
                else
                {
                    [CommenMethods alertviewController_title:LocalizedString(@"Alert") MessageAlert:LocalizedString(@"ERRORMSG") viewController:self okPop:NO];
                }
            }
            
        }];
    }
    else
    {
        [CommenMethods alertviewController_title:@"" MessageAlert:LocalizedString(@"CHKNET") viewController:self okPop:NO];
    }
}


#pragma mark -- Table View Delegates Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [promoArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.text = [NSString stringWithFormat:@"Code : %@ OFF %@", [promoArray objectAtIndex:indexPath.row],[ghemat objectAtIndex:indexPath.row]];
    [CSS_Class APP_fieldValue:cell.textLabel];
    return cell;
}


-(IBAction)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
