//
//  UrlParser.h
//  urltest
//
//  Created by Joe  on 21/11/13.
//  Copyright (c) 2013 Boop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUURLParser : NSObject {
    NSArray *variables;
}

@property (nonatomic, retain) NSArray *variables;


- (id) initWithURL:(NSURL *)url;
- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end
