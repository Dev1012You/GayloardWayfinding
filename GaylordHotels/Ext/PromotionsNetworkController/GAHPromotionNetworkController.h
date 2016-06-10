//
//  GAHPromotionNetworkController.h
//  GaylordHotels
//
//  Created by John Pacheco on 9/15/15.
//  Copyright (c) 2015 John Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAHPromotionNetworkController : NSObject

- (void)fetchPromotion:(NSString *)promotionID
        successHandler:(void(^)(id promotionDetails))successHandler
        failureHandler:(void(^)(NSURLResponse *response,NSError *networkError))failureHandler;

- (void)fetchPromotionsSuccessHandler:(void(^)(id promotions))successHandler
                       failureHandler:(void(^)(NSURLResponse *response,NSError *networkError))failureHandler;

- (void)fetchFeaturedSuccessHandler:(void (^)(id featuredPromotions))successHandler
                     failureHandler:(void (^)(NSURLResponse *, NSError *))failureHandler;

@end
