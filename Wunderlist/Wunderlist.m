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
    return @"Dean Thomas";
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
    [sendToInbox setAction:@selector(sendToInbox:)];
    [sendToInbox setTarget:self];
    
    return sendToInbox;
}

-(void)setAPIToken:(NSString *)apiToken
{
    [self.preferences setObject:apiToken forKey:apitoken_key];
}

-(NSString *)getAPIToken
{
    return [self.preferences objectForKey:apitoken_key];
}

-(void)sendToInbox: (NSMenuItem *)item
{
    [[NSSound soundNamed:@"Hero"] play];
    
    AMPMenuAction *action = item.representedObject;
    if(action && [action isKindOfClass:[AMPMenuAction class]])
    {
        for ( int i = 0; i < action.messages.count; i ++ )
        {
            AMPMessage *msg = (AMPMessage *)[action.messages objectAtIndex:i];
           
            NSString *url   = [msg callSelector:@selector(urlformessage)];
            if(!url || url.length == 0) url = @"";
            
            NSString *subject = msg.subject;
            if(!subject || subject.length == 0) subject = @"";

            //NSLog(@"Wunderlist: %@ %@",msg.subject, url);
            [APIHelperWunderlist sendToInboxWithContent:msg.subject note:url andApiToken:[self getAPIToken] andDelegate:self];
        }
    }
    
    return;
}

-(void)finishedCallFor:(NSString *)method withData:(NSDictionary *)dict
{
    
}

@end
