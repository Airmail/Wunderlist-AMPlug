//
//  ToDoIst.m
//  ToDoIst
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "Wunderlist.h"
#import "WunderlistConfigView.h"

const NSString *apitoken_key = @"apitoken";

@implementation Wunderlist

-(id)initWithbundle:(NSBundle *)bundleIn path:(NSString *)pathIn
{
    self = [super initWithbundle:bundleIn path:pathIn];
    if (self)
    {
        
    }
    return self;
}

-(BOOL)Load
{
    if (![super Load])
        return NO;
    
    return YES;
}

-(void)Enable
{
    
}

-(void)Disable
{
    
}

-(void)Invalid
{
    
}

-(void)Reload
{
    [self.myView ReloadView];
}

-(AMPView *)pluginview
{
    if (self.myView == nil)
        self.myView = [[WunderlistConfigView alloc] initWithFrame:NSZeroRect plugin:self];
    
    return self.myView;
}

-(NSString *)nametext
{
    return @"Wunderlist";
}

-(NSString *)description
{
    return self.nametext;
}

-(NSString *)descriptiontext
{
    return @"Integrate Wunderlist and AirMail, for easy management of your task list!";
}

-(NSString *)authortext
{
    return @"Dean Thomas, Bloop";
}

-(NSString *)supportlink
{
    return @"http://www.spikedsoftware.com";
}

- (NSImage*) icon
{
    return [self.bundle imageForResource:@"plugins-Wunderlist"];
}

-(id)ampMenuActionItem:(NSArray *)messages
{
    NSMenuItem *sendToInbox = [[NSMenuItem alloc] initWithTitle:@"Send to Wunderlist Inbox" action:nil keyEquivalent:@""];
    [sendToInbox setRepresentedObject:@""];
    @try
    {
        NSString *accessToken = self.preferences[wu_accessToken];
        if(accessToken && accessToken.length > 0)
        {
            //        {
            //            "created_at" = "2014-03-27T08:49:10.301Z";
            //            id = 99828927;
            //            "list_type" = inbox;
            //            public = 0;
            //            revision = 20;
            //            title = inbox;
            //            type = list;
            //        },

            NSMenu *menu    = [[NSMenu alloc] initWithTitle:@"wu"];
            NSArray *lists = self.preferences[wu_list];
            for(NSDictionary *list in lists)
            {
                NSMenuItem *listItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Send to %@",list[@"title"]] action:nil keyEquivalent:@""];
                [listItem setRepresentedObject:list];
                [listItem setAction:@selector(sendToList:)];
                [listItem setTarget:self];
                [menu addItem:listItem];
                
            }
            [sendToInbox setSubmenu:menu];
            
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Exception ampMenuActionItem %@",exception);
    }
    @finally {
        
    }
    return sendToInbox;
}


-(void) sendToList:(NSMenuItem *)item
{
    @try
    {
        NSString *accessToken = self.preferences[wu_accessToken];
        if(accessToken.length == 0)
            return;
        
        AMPMenuAction *action = item.representedObject;
        NSDictionary *list    = (NSDictionary*)action.representedObject;
        
        if(action && [action isKindOfClass:[AMPMenuAction class]])
        {
            for ( int i = 0; i < action.messages.count; i ++ )
            {
                AMPMessage *msg = (AMPMessage *)[action.messages objectAtIndex:i];
                NSString *url   = [msg callSelector:@selector(urlformessage)];
                if(!url || url.length == 0)
                    url = @"";

                NSString *subject = msg.subject;
                if(!subject || subject.length == 0)
                    subject = @"";

                [APIHelperWunderlist wuApiTask:accessToken title:subject comment:url listid:list[@"id"] block:^(NSDictionary *dict, NSError *err) {
                   
                    if(err)
                    {
                        [self PostError:err];
                        return;
                    }
                    [[NSSound soundNamed:@"Hero"] play];

                }];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception sendToList %@",exception);
    }
    @finally {
        
    }

}

- (void) PostError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *anAlert = [NSAlert alertWithError:error];
        [anAlert runModal];
    });
}



//-(void)sendToInbox: (NSMenuItem *)item
//{
//    [[NSSound soundNamed:@"Hero"] play];
//    
//    AMPMenuAction *action = item.representedObject;
//    if(action && [action isKindOfClass:[AMPMenuAction class]])
//    {
//        for ( int i = 0; i < action.messages.count; i ++ )
//        {
//            AMPMessage *msg = (AMPMessage *)[action.messages objectAtIndex:i];
//           
//            NSString *url   = [msg callSelector:@selector(urlformessage)];
//            if(!url || url.length == 0) url = @"";
//            
//            NSString *subject = msg.subject;
//            if(!subject || subject.length == 0) subject = @"";
//
//            //NSLog(@"Wunderlist: %@ %@",msg.subject, url);
//            //[APIHelperWunderlist sendToInboxWithContent:msg.subject note:url andApiToken:[self getAPIToken] andDelegate:self];
//        }
//    }
//    
//    return;
//}

-(void)finishedCallFor:(NSString *)method withData:(NSDictionary *)dict
{
    
}

@end
