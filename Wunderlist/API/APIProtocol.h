//
//  APIProtocol.h
//  Wunderlist
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APIProtocol <NSObject>

-(void)finishedCallFor: (NSString *)method withData: (NSDictionary*)dict;

@end
