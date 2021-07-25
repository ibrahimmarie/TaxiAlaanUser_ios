//
//  AFNHelper.m
//  Truck
//
//  Created by veena on 1/12/17.
//  Copyright © 2017 appoets. All rights reserved.
//
//

#import "AFNHelper.h"
#import "AFNetworking.h"
#import "Constants.h"

@implementation AFNHelper

@synthesize strReqMethod;

#pragma mark -
#pragma mark - Init

-(id)initWithRequestMethod:(NSString *)method
{
    if ((self = [super init])) {
        self.strReqMethod=method;
    }
    return self;
}

#pragma mark -
#pragma mark - Methods
-(void)getDataFromPath:(NSString *)path withParamData:(NSDictionary *)dictParam withBlock:(RequestCompletionBlock)block
{
    if (block) {
        dataBlock=[block copy];
    }
   
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    // manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@[@"XMLHttpRequest",@"application/json",@"text/html"]];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    //[manager.requestSerializer setValue:@"Content-Type" forHTTPHeaderField:@"application/json"];
    
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    
    NSString *strVal=[user valueForKey:UD_ACCESS_TOKEN];
    NSString *strValue=[NSString stringWithFormat:@"%@ %@",[user valueForKey:UD_TOKEN_TYPE],[user valueForKey:UD_ACCESS_TOKEN]];
    
    if ([strVal length]!=0)
    {
        [manager.requestSerializer setValue:strValue forHTTPHeaderField:@"Authorization"];
    }
    
    manager.requestSerializer.timeoutInterval=600;
    
    NSString *strURL=[NSString stringWithFormat:@"%@%@",SERVICE_URL,path];
    
    if ([self.strReqMethod isEqualToString:POST_METHOD])
    {
        [manager POST:strURL parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if(self->dataBlock){
               
                
                 if(responseObject==nil)
                     self->dataBlock(task.response,nil,nil);
                 else
                     self->dataBlock(responseObject,nil,nil);
             }
         }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"Error %@",error);
               
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                  NSLog(@"status code: %li", (long)httpResponse.statusCode);
                  
                  NSDictionary *serializedData;
                  
//                  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
//                  NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
//                  NSDictionary *params=@{@"mobile":@"",
//                                         @"method_name":@"",
//                                         @"status_code":[NSString stringWithFormat:@"%ld",(long)httpResponse.statusCode],
//                                         @"exception":error,
//                                         @"payload":dictParam,
//                                         @"url":strURL,
//                                         @"app_version":version,
//                                         @"user_agent":@"IOS-USER"
//                                         };
//
//                  AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
//
//                  [afn sendError:SENDERORR withParamData:params withBlock:^(id response, NSDictionary *error, NSString *errorcode) {
//
//                  }];
                  
                  if (httpResponse.statusCode==0) {
                      self->dataBlock(nil,nil,@"1");
                  }
                  else
                  {
                      NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                      
                      if (errorData != nil)
                      {
                         // serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                      }
                  }
                  
                  if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                  {
                      self->dataBlock(nil,serializedData,@"1");
                  }
                  else if(httpResponse.statusCode==422)
                  {
                      self->dataBlock(nil,serializedData,@"2");
                  }
                  else if(httpResponse.statusCode==401)
                  {
                    //  NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                    //  [user setValue:[serializedData valueForKey:@"access_token"] forKey:UD_ACCESS_TOKEN];
                      self->dataBlock(nil,nil,@"3");
                  }
                
                  
              }];
        
    }
    else
    {
        [manager GET:strURL parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if(self->dataBlock){
                 if(responseObject==nil)
                     self->dataBlock(task.response,nil,nil);
                 else
                     self->dataBlock(responseObject,nil,nil);
             }
             
         }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error %@",error);
                 
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                 NSLog(@"status code: %li", (long)httpResponse.statusCode);
                 NSDictionary *serializedData;
                 
                 
                  if (httpResponse.statusCode==0) {
                      self->dataBlock(nil,nil,@"1");
                 }
                 else
                 {
                     NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                     if (errorData != nil)
                     {
                         serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                     }
                  }
         
                 if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                 {
                     self->dataBlock(nil,serializedData,@"1");
                 }
                 else if(httpResponse.statusCode==422 )
                 {
                     self->dataBlock(nil,serializedData,@"2");
                 }
                 else if(httpResponse.statusCode==401)
                 {
                     self->dataBlock(nil,serializedData,@"3");
                 }

             }];
    }
}

-(void)getDataFromPath:(NSString *)path withParamDataImage:(NSDictionary *)dictParam andImage:(UIImage *)image withBlock:(RequestCompletionBlock)block{
    
    if (block) {
        dataBlock=[block copy];
    }
    NSData *imageToUpload = UIImageJPEGRepresentation(image, 1.0);//(uploadedImgView.image);
    if (imageToUpload)
    {
        NSString *url=[NSString stringWithFormat:@"%@%@",SERVICE_URL,path] ;//stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
        //[manager.requestSerializer setValue:@"Content-Type" forHTTPHeaderField:@"application/json"];
        
        
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        
        NSString *strVal=[user valueForKey:UD_ACCESS_TOKEN];
        NSString *strValue=[NSString stringWithFormat:@"%@ %@",[user valueForKey:UD_TOKEN_TYPE],[user valueForKey:UD_ACCESS_TOKEN]];
        
        if ([strVal length]!=0)
        {
            [manager.requestSerializer setValue:strValue forHTTPHeaderField:@"Authorization"];
        }
        
        manager.requestSerializer.timeoutInterval=600;
       

       
        [manager POST:url parameters:dictParam
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:imageToUpload name:PICTURE fileName:@"files" mimeType:@"image/png"];
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(self->dataBlock){
                if(responseObject==nil)
                    self->dataBlock(task.response,nil,nil);
                else
                    self->dataBlock(responseObject,nil,nil);
            }
            
        }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"Error %@",error);
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                  NSLog(@"status code: %li", (long)httpResponse.statusCode);
                  
                  NSDictionary *serializedData;
                  
    
                  
                  if (httpResponse.statusCode==0) {
                      self->dataBlock(nil,nil,@"1");
                  }
                  else
                  {
                      NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                      if (errorData != nil)
                      {
                          serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                      }
                      
                  }
                  
                  if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                  {
                      
                     
                      self->dataBlock(nil,serializedData,@"1");
                      //dataBlock(nil,nil,@"1");
                  }
                  else if(httpResponse.statusCode==422)
                  {
                     
                      self->dataBlock(nil,serializedData,@"2");
                  }
                  else if(httpResponse.statusCode==401)
                  {
                     // NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                      //[user setValue:[serializedData valueForKey:@"access_token"] forKey:UD_ACCESS_TOKEN];
                      self->dataBlock(nil,nil,@"3");
                  }

              }];
    }
    
}
-(void)getAddressFromGooglewithParamData:(NSDictionary *)dictParam withBlock:(RequestCompletionBlock)block
{
    if (block) {
        dataBlock=[block copy];
    }
    //[raw urlEncodeUsingEncoding:NSUTF8Encoding]
    NSString *url=[NSString stringWithFormat:@"%@",Address_URL];
         //stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
   // manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@[@"text/html",@"application/json"]];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval=600;
 
    if ([self.strReqMethod isEqualToString:POST_METHOD])
    {
        [manager POST:url parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if(self->dataBlock){
                 
                 if(responseObject==nil)
                     self->dataBlock(task.response,nil,nil);
                 else
                     self->dataBlock(responseObject,nil,nil);
             }
         }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"Error %@",error);
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                  NSLog(@"status code: %li", (long)httpResponse.statusCode);
                  
                  NSDictionary *serializedData;
                  
                  if (httpResponse.statusCode==0) {
                      self->dataBlock(nil,nil,@"1");
                  }
                  else
                  {
                      NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                      if (errorData != nil)
                      {
                          serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                      }
                      
                  }
                  
                  if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                  {
                      
                      self->dataBlock(nil,serializedData,@"1");

                  }
                  else if(httpResponse.statusCode==422)
                  {
                     
                      self->dataBlock(nil,serializedData,@"2");
                  }
                  else if(httpResponse.statusCode==401)
                  {
                      
                      NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                      [user setValue:[serializedData valueForKey:@"access_token"] forKey:UD_ACCESS_TOKEN];
                      self->dataBlock(nil,nil,@"3");
                  }

              }];
        
    }
    else
    {
        [manager GET:url parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if(self->dataBlock){
                 if(responseObject==nil)
                     self->dataBlock(task.response,nil,nil);
                 else
                     self->dataBlock(responseObject,nil,nil);
             }
             
         }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error %@",error);
                
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                 NSLog(@"status code: %li", (long)httpResponse.statusCode);
                 
                 NSDictionary *serializedData;
                 
                 if (httpResponse.statusCode==0) {
                     self->dataBlock(nil,nil,@"1");
                 }
                 else
                 {
                     NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                     if (errorData != nil)
                     {
                         serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                     }
                     
                 }
                 
                 if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                 {
                     self->dataBlock(nil,nil,@"1");
                 }
                 else if(httpResponse.statusCode==422)
                 {
                     
                     self->dataBlock(nil,serializedData,@"2");
                 }
                 else if(httpResponse.statusCode==401)
                 {
                    
            
                     self->dataBlock(nil,nil,@"3");
                 }

             }];
        
    }

}

-(void)getAddressFromGooglewAutoCompletewithParamData:(NSDictionary *)dictParam withBlock:(RequestCompletionBlock)block{
    
    if (block) {
        dataBlock=[block copy];
    }
    NSString *url=[NSString stringWithFormat:@"%@",AutoComplete_URL];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval=600;
    if ([self.strReqMethod isEqualToString:POST_METHOD])
    {
        [manager POST:url parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if(self->dataBlock){
                 
                 if(responseObject==nil)
                     self->dataBlock(task.response,nil,nil);
                 else
                     self->dataBlock(responseObject,nil,nil);
             }
         }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"Error %@",error);
                 
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                  NSLog(@"status code: %li", (long)httpResponse.statusCode);
                  NSDictionary *serializedData;
                  if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                  {
                      self->dataBlock(nil,nil,@"1");
                  }
                  else if(httpResponse.statusCode==422)
                  {
                      NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                      if (errorData != nil)
                      {
                           serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                          self->dataBlock(nil,serializedData,@"2");
                      }
                  }
                  else if(httpResponse.statusCode==401)
                  {
                      
                      NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                      [user setValue:[serializedData valueForKey:@"access_token"] forKey:UD_ACCESS_TOKEN];
                      self->dataBlock(nil,nil,@"3");
                  }

              }];
    }
    else
    {
        [manager GET:url parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if(self->dataBlock){
                 if(responseObject==nil)
                     self->dataBlock(task.response,nil,nil);
                 else
                     self->dataBlock(responseObject,nil,nil);
             }
         }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error %@",error);
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                 NSLog(@"status code: %li", (long)httpResponse.statusCode);
                 NSDictionary *serializedData;
                 if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                 {
                     self->dataBlock(nil,nil,@"1");
                 }
                 else if(httpResponse.statusCode==422)
                 {
                     NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                     if (errorData != nil)
                     {
                        serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                         self->dataBlock(nil,serializedData,@"2");
                     }
                     
                 }
                 else if(httpResponse.statusCode==401)
                 {
                     NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                     [user setValue:[serializedData valueForKey:@"access_token"] forKey:UD_ACCESS_TOKEN];
                     self->dataBlock(nil,nil,@"3");
                 }

             }];
    }
   
}


-(void)getAddressFromGooglePlace:(NSDictionary *)dictParam withBlock:(RequestCompletionBlock)block{
    
    if (block) {
        dataBlock=[block copy];
    }
    //[raw urlEncodeUsingEncoding:NSUTF8Encoding]
    NSString *url=[NSString stringWithFormat:@"%@",placs];
    //stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@[@"text/html",@"application/json"]];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval=600;
    if ([self.strReqMethod isEqualToString:POST_METHOD])
    {
        [manager POST:url parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if(self->dataBlock){
                 
                 if(responseObject==nil)
                     self->dataBlock(task.response,nil,nil);
                 else
                     self->dataBlock(responseObject,nil,nil);
             }
         }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"Error %@",error);
                  
                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                  NSLog(@"status code: %li", (long)httpResponse.statusCode);
                  NSDictionary *serializedData;
                  
                  
                  if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                  {
                      self->dataBlock(nil,nil,@"1");
                  }
                  else if(httpResponse.statusCode==422)
                  {
                      NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                      if (errorData != nil)
                      {
                          serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                          self->dataBlock(nil,serializedData,@"2");
                      }
                  }
                  else if(httpResponse.statusCode==401)
                  {
                      NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                      [user setValue:[serializedData valueForKey:@"access_token"] forKey:UD_ACCESS_TOKEN];
                      self->dataBlock(nil,nil,@"3");
                  }
                  
              }];
    }
    else
    {
        [manager GET:url parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {
            
        }
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             if(self->dataBlock){
                 if(responseObject==nil)
                     self->dataBlock(task.response,nil,nil);
                 else
                     self->dataBlock(responseObject,nil,nil);
             }
         }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error %@",error);
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                 NSLog(@"status code: %li", (long)httpResponse.statusCode);
                 NSDictionary *serializedData;
                 if (httpResponse.statusCode==400||httpResponse.statusCode==405||httpResponse.statusCode==500 )
                 {
                     self->dataBlock(nil,nil,@"1");
                 }
                 else if(httpResponse.statusCode==422)
                 {
                     NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                     if (errorData != nil)
                     {
                        serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                         self->dataBlock(nil,serializedData,@"2");
                     }
                     
                 }
                 else if(httpResponse.statusCode==401)
                 {
                     
                     NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                     [user setValue:[serializedData valueForKey:@"access_token"] forKey:UD_ACCESS_TOKEN];
                     self->dataBlock(nil,nil,@"3");
                 }
                 
             }];
    }
    
}



-(void)sendError:(NSString *)path withParamData:(NSDictionary *)dictParam withBlock:(RequestCompletionBlock)block
{
    if (block) {
        dataBlock=[block copy];
    }

    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    // manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@[@"XMLHttpRequest",@"application/json",@"text/html"]];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    //[manager.requestSerializer setValue:@"Content-Type" forHTTPHeaderField:@"application/json"];

    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];

    NSString *strVal=[user valueForKey:UD_ACCESS_TOKEN];
    NSString *strValue=[NSString stringWithFormat:@"%@ %@",[user valueForKey:UD_TOKEN_TYPE],[user valueForKey:UD_ACCESS_TOKEN]];

    if ([strVal length]!=0)
    {
        [manager.requestSerializer setValue:strValue forHTTPHeaderField:@"Authorization"];
    }

    manager.requestSerializer.timeoutInterval=600;

    NSString *strURL=[NSString stringWithFormat:@"%@%@",SERVICE_URL,path];

    if ([self.strReqMethod isEqualToString:POST_METHOD])
    {
        [manager POST:strURL parameters:dictParam progress:^(NSProgress * _Nonnull uploadProgress) {

        }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
////             if(self->dataBlock){
////
////                 if(responseObject==nil)
////                     self->dataBlock(task.response,nil,nil);
////                 else
////                     self->dataBlock(responseObject,nil,nil);
////             }
         }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"Error %@",error);

              }];

    }

}


@end
