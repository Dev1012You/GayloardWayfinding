//
//  GAHPromotionNetworkController.m
//  GaylordHotels
//
//  Created by John Pacheco on 9/15/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import "GAHPromotionNetworkController.h"
#import "NSMutableURLRequest+MTPCategory.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSURLSession+MTPCategory.h"

@implementation GAHPromotionNetworkController

- (void)fetchPromotion:(NSString *)promotionID successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSURLResponse *, NSError *))failureHandler
{
    NSMutableURLRequest *promotion = [NSMutableURLRequest defaultRequestMethod:@"GET" URL:[NSString promotionWithID:promotionID] parameters:nil];
    
    [self sendRequest:promotion successHandler:successHandler failureHandler:failureHandler];
}

- (void)fetchPromotionsSuccessHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSURLResponse *, NSError *))failureHandler
{
    NSMutableURLRequest *promotions = [NSMutableURLRequest defaultRequestMethod:@"GET" URL:[NSString promotions] parameters:nil];
    
    [self sendRequest:promotions successHandler:successHandler failureHandler:failureHandler];
}

- (void)fetchFeaturedSuccessHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSURLResponse *, NSError *))failureHandler
{
    NSMutableURLRequest *featured = [NSMutableURLRequest defaultRequestMethod:@"GET" URL:[NSString promotionsFeatured] parameters:nil];
    
    [self sendRequest:featured successHandler:successHandler failureHandler:failureHandler];
}


- (void)sendRequest:(NSMutableURLRequest *)urlRequest successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSURLResponse *, NSError *))failureHandler
{
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
     {
         if (error)
         {
             if (failureHandler)
             {
                 failureHandler(response,error);
             }
         }
         
         if (data)
         {
             id dataObject = [NSURLSession serializeJSONData:data response:response error:error];
             if (dataObject)
             {
                 if (successHandler)
                 {
                     successHandler(dataObject);
                 }
             }
         }
     }] resume];
}

@end
