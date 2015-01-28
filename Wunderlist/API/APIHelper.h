//
//  APIHelper.h
//  Wunderlist
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIHelper : NSObject

+(void)getUserWithEmail: (NSString *)email andPassword: (NSString *)password andDelegate: (id)delegate;
+(void)sendToInboxWithContent: (NSString *)content andApiToken: (NSString *)token andDelegate: (id)delegate;

@end
