//
//  APIHelper.h
//  Wunderlist
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const wu_oauth_kClientID              = @"";
static NSString *const wu_oauth_kClientSecret          = @"";



@interface APIHelperWunderlist : NSObject

+ (void) accessToken:(NSString*)code block:(void (^)(NSDictionary*dict, NSError*err))block;
+ (void) wuApiList:(NSString*)accessToken block:(void (^)(NSArray *arrx, NSError*err))block;
+ (void) wuApiTask:(NSString*)accessToken title:(NSString*)title comment:(NSString*)comment listid:(NSNumber*)listId block:(void (^)(NSDictionary*dict, NSError*err))block;
+ (void) wuApiUser:(NSString*)accessToken block:(void (^)(NSDictionary*dict, NSError*err))block;

@end
