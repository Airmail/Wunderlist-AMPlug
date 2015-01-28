//
//  APIHelper.m
//  Wunderlist
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "APIHelper.h"
#import "APIProtocol.h"
@import AppKit;

static NSOperationQueue *operationQueue = nil;

@implementation APIHelper

+(NSOperationQueue *)operationQueue
{
    if (operationQueue == nil)
    {
        operationQueue = [NSOperationQueue new];
        [operationQueue setMaxConcurrentOperationCount:1];
    }
    
    return operationQueue;
}

+ (NSString *) URLEncodedString_ch: (NSString *)input {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[input UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+(void)getUserWithEmail:(NSString *)email andPassword:(NSString *)password andDelegate: (id)delegate
{
    NSString *apiUrl = [NSString stringWithFormat:@"https://api.wunderlist.com/login"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSString *postBody = [NSString stringWithFormat:@"email=%@&password=%@", email, password];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [delegate finishedCallFor:@"GetUser" withData:dict];
    }];
}

+(void)sendToInboxWithContent:(NSString *)content andApiToken:(NSString *)token andDelegate:(id)delegate
{
    NSString *apiUrl = [NSString stringWithFormat:@"https://api.wunderlist.com/me/tasks"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    //Set the Auth header
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    //Set the body data
    NSString *postBody = [NSString stringWithFormat:@"list_id=inbox&title=%@", [self URLEncodedString_ch:content]];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];

    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [delegate finishedCallFor:@"SendToInbox" withData:dict];
    }];
}

@end
