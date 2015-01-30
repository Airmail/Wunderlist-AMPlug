//
//  APIHelper.h
//  Wunderlist
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIHelperWunderlist : NSObject

+(void)getUserWithEmail: (NSString *)email andPassword: (NSString *)password andDelegate: (id)delegate;
+(void)sendToInboxWithContent: (NSString *)content note:(NSString*)note andApiToken: (NSString *)token andDelegate: (id)delegate;

@end
