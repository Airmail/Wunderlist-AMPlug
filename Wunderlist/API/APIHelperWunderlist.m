//
//  APIHelper.m
//  Wunderlist
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "APIHelperWunderlist.h"
#import "APIProtocol.h"
@import AppKit;

static NSOperationQueue *operationQueue = nil;

@implementation APIHelperWunderlist

+(NSOperationQueue *)operationQueue
{
    if (operationQueue == nil)
    {
        operationQueue = [NSOperationQueue new];
        [operationQueue setMaxConcurrentOperationCount:1];
    }
    
    return operationQueue;
}

+ (void) accessToken:(NSString*)code block:(void (^)(NSDictionary*dict, NSError*err))block
{
    NSString *apiURL                = [NSString stringWithFormat:@"https://www.wunderlist.com/oauth/access_token"];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0];
    [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dict      = @{
                                @"client_id"    : wu_oauth_kClientID,
                                @"client_secret": wu_oauth_kClientSecret,
                                @"code"         : code
                                };
    NSData *jsonData        = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString    = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableData *postData = [NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setHTTPBody:postData];
    [theRequest setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:theRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError)
        {
            NSLog(@"accessToken connectionError %@",connectionError);
            block(nil,connectionError);
            return;
        }
        
        NSError *err = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if(err)
        {
            NSLog(@"accessToken JSONObjectWithData %@",err);
            block(nil,err);
            return;
        }
        block(dict,nil);
        
    }];
    
}

+ (void) wuApiUser:(NSString*)accessToken block:(void (^)(NSDictionary*dict, NSError*err))block;
{
    NSString *apiURL                = [NSString stringWithFormat:@"https://a.wunderlist.com/api/v1/user"];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0];
    [theRequest setValue:accessToken                forHTTPHeaderField:@"X-Access-Token"];
    [theRequest setValue:wu_oauth_kClientID         forHTTPHeaderField:@"X-Client-ID"];
    [theRequest setValue:@"application/json"        forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:theRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError)
        {
            NSLog(@"wuApiUser connectionError %@",connectionError);
            block(nil,connectionError);
            return;
        }
        
        NSError *err        = nil;
        NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if(err)
        {
            NSLog(@"wuApiUser NSJSONSerialization %@",err);
            block(nil,err);
            return;
        }
        
//        {
//            "id": 6234958,
//            "name": "BENCHMARK",
//            "email": "benchmark@example.com",
//            "created_at": "2013-08-30T08:25:58.000Z",
//            "revision": 1
//        }

        block(dict,nil);
    }];

}

+ (void) wuApiList:(NSString*)accessToken block:(void (^)(NSArray *arrx, NSError*err))block
{
    NSString *apiURL                = [NSString stringWithFormat:@"https://a.wunderlist.com/api/v1/lists"];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0];
    [theRequest setValue:accessToken                forHTTPHeaderField:@"X-Access-Token"];
    [theRequest setValue:wu_oauth_kClientID         forHTTPHeaderField:@"X-Client-ID"];
    [theRequest setValue:@"application/json"        forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:theRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if(connectionError)
        {
            NSLog(@"wuApiList connectionError %@",connectionError);
            block(nil,connectionError);
            return;
        }
        
        NSError *err        = nil;
        NSArray *arr  = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if(err)
        {
            NSLog(@"wuApiList NSJSONSerialization %@",err);
            block(nil,err);
            return;
        }
        block(arr,nil);
    }];
}

+ (void) wuApiTask:(NSString*)accessToken title:(NSString*)title comment:(NSString*)comment listid:(NSNumber*)listId block:(void (^)(NSDictionary*dict, NSError*err))block
{
    NSString *apiURL                = [NSString stringWithFormat:@"https://a.wunderlist.com/api/v1/tasks"];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0];
    [theRequest setValue:accessToken                forHTTPHeaderField:@"X-Access-Token"];
    [theRequest setValue:wu_oauth_kClientID         forHTTPHeaderField:@"X-Client-ID"];
    [theRequest setValue:@"application/json"        forHTTPHeaderField:@"Content-Type"];
    //    {
    //        "list_id": -12345,
    //        "title": "Hallo",
    //        "assignee_id": 123,
    //        "completed": true,
    //        "due_date": "2013-08-30",
    //        "starred": false
    //    }
    NSString *jsonString = [NSString stringWithFormat:@"{\"list_id\" : %@, \"title\" : \"%@\", \"starred\" : false, \"note\" : \"note\"}",listId,title];
    NSMutableData *postData = [NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setHTTPBody:postData];
    [theRequest setHTTPMethod:@"POST"];

    [NSURLConnection sendAsynchronousRequest:theRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if(connectionError)
        {
            NSLog(@"wuApiTask connectionError %@",connectionError);
            block(nil,connectionError);
            return;
        }

        NSError *err = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if(err)
        {
            NSLog(@"wuApiTask JSONObjectWithData %@",err);
            block(nil,err);
            return;
        }

        NSString *taskId                = dict[@"id"];
        NSString *apiURL                = [NSString stringWithFormat:@"https://a.wunderlist.com/api/v1/task_comments"];
        NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0];
        [theRequest setValue:accessToken                forHTTPHeaderField:@"X-Access-Token"];
        [theRequest setValue:wu_oauth_kClientID         forHTTPHeaderField:@"X-Client-ID"];
        [theRequest setValue:@"application/json"        forHTTPHeaderField:@"Content-Type"];
        //        {
        //            "task_id": 1234,
        //            "text": "Hey there"
        //        }
        NSString *jsonString    = [NSString stringWithFormat:@"{\"task_id\" : %@, \"text\" : \"%@\"}",taskId,comment];
        NSMutableData *postData = [NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        [theRequest setHTTPBody:postData];
        [theRequest setHTTPMethod:@"POST"];
        [NSURLConnection sendAsynchronousRequest:theRequest queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

            if(connectionError)
            {
                NSLog(@"task_comments connectionError %@",connectionError);
                block(nil,connectionError);
                return;
            }

            NSError *err = nil;
            NSDictionary *dict2 = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            if(err)
            {
                NSLog(@"task_comments JSONObjectWithData %@",err);
                block(nil,err);
                return;
            }
            block(dict2,nil);
        }];

    }];

}


//+ (NSString *) URLEncodedString_wu: (NSString *)input {
//        CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                      (__bridge CFStringRef)input,
//                                                                      NULL,
//                                                                      CFSTR("!*'\"();:@&=+$,/?%#[]% "),
//                                                                      kCFStringEncodingUTF8);
//        return CFBridgingRelease(encoded);
//}
//
//+ (NSString *) URLEncodedString_ch: (NSString *)input {
//    NSMutableString * output = [NSMutableString string];
//    const unsigned char * source = (const unsigned char *)[input UTF8String];
//    int sourceLen = (int)strlen((const char *)source);
//    for (int i = 0; i < sourceLen; ++i) {
//        const unsigned char thisChar = source[i];
//        if (thisChar == ' '){
//            [output appendString:@"+"];
//        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
//                   (thisChar >= 'a' && thisChar <= 'z') ||
//                   (thisChar >= 'A' && thisChar <= 'Z') ||
//                   (thisChar >= '0' && thisChar <= '9')) {
//            [output appendFormat:@"%c", thisChar];
//        } else {
//            [output appendFormat:@"%%%02X", thisChar];
//        }
//    }
//    return output;
//}
//
//+(void)getUserWithEmail:(NSString *)email andPassword:(NSString *)password andDelegate: (id)delegate
//{
//    NSString *apiUrl = [NSString stringWithFormat:@"https://api.wunderlist.com/login"];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
//    [request setHTTPMethod:@"POST"];
//    
//    NSString *postBody = [NSString stringWithFormat:@"email=%@&password=%@", email, password];
//    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSLog(@"Wunderlist getUserWithEmail %@",postBody);
//    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
//
//        if(connectionError)
//            NSLog(@"Wunderlist getUserWithEmail %@",connectionError);
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"Wunderlist getUserWithEmail dict %@",dict);
//        NSLog(@"Wunderlist getUserWithEmail data %@",data);
//        NSLog(@"Wunderlist getUserWithEmail data %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        NSLog(@"Wunderlist getUserWithEmail connectionError %@",connectionError);
//        NSLog(@"Wunderlist getUserWithEmail response %@",response);
//
//        [delegate finishedCallFor:@"GetUser" withData:dict];
//    }];
//}
//
//+(void)sendToInboxWithContent: (NSString *)content note:(NSString*)note andApiToken: (NSString *)token andDelegate:(id)delegate;
//{
//    NSString *apiUrl = [NSString stringWithFormat:@"https://api.wunderlist.com/me/tasks"];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
//    [request setHTTPMethod:@"POST"];
//    
//    //Set the Auth header
//    [request setValue:token forHTTPHeaderField:@"Authorization"];
//    
//    //Set the body data
//    NSString *postBody = [NSString stringWithFormat:@"list_id=inbox&title=%@&note=%@", [self URLEncodedString_ch:content],[self URLEncodedString_wu:note]];
//    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
//
//    //NSLog(@"Wunderlist request %@",postBody);
//    [NSURLConnection sendAsynchronousRequest:request queue:[self operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        //NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        //NSLog(@"Wunderlist return data %@",data);
//        NSDictionary *dict = [NSDictionary dictionary];
//        if(data)
//        {
//            dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            //NSLog(@"Wunderlist return dict %@",dict);
//            [delegate finishedCallFor:@"SendToInbox" withData:dict];
//        }
//    }];
//}

@end
