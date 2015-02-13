//
//  ToDoIst.h
//  ToDoIst
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMPluginFramework/AMPluginFramework.h>
#import "APIProtocol.h"
#import "APIHelperWunderlist.h"

@interface Wunderlist : AMPlugin<APIProtocolWunderlist>
{
    
}
- (void) PostError:(NSError*)error;
@end
