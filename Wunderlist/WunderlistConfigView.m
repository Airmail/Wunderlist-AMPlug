//
//  WunderlistConfigView.m
//  Wunderlist
//
//  Created by Dean Thomas on 15/12/2014.
//  Copyright (c) 2014 SpikedSoftware. All rights reserved.
//

#import "WunderlistConfigView.h"
#import "Wunderlist.h"
#import "APIProtocol.h"
#import "APIHelperWunderlist.h"

@interface WunderlistConfigView ()

@property (strong, nonatomic) NSTextField *apiKey;
@property (strong, nonatomic) NSArray *listsAvailable;
@property (strong, nonatomic) NSTextField *emailAddress;
@property (strong, nonatomic) NSTextField *password;

@end

@implementation WunderlistConfigView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(id)initWithFrame:(NSRect)frame plugin:(AMPlugin *)pluginIn
{
    self = [super initWithFrame:frame plugin:pluginIn];
    if (self)
    {
        @try {
            
            float x = 0, y = 0;
            
            NSTextView *emailLabel = [[NSTextView alloc] initWithFrame:CGRectMake(x, y, 100.0f, 22.0f)];
            [emailLabel setString:@"Email Address"];
            [emailLabel setEditable:false];
            [emailLabel setSelectable:false];
            [emailLabel setDrawsBackground:false];
            x += emailLabel.frame.size.width + 10.0f;
            
            self.emailAddress = [[NSTextField alloc] initWithFrame:CGRectMake(x, y, 180.0f, 22.0f)];
            [self.emailAddress setEditable:YES];
            
            x = 0;
            y += self.emailAddress.frame.size.height + 5.0f;
            
            NSTextView *passwordLabel = [[NSTextView alloc] initWithFrame:CGRectMake(x, y, 100.0f, 22.0f)];
            [passwordLabel setString:@"Password"];
            [passwordLabel setEditable:false];
            [passwordLabel setSelectable:false];
            [passwordLabel setDrawsBackground:false];
            x += passwordLabel.frame.size.width + 10.0f;
            
            self.password = [[NSSecureTextField alloc] initWithFrame:CGRectMake(x, y, 120.f, 22.0f)];
            [self.password setEditable:YES];
            
            x += self.password.frame.size.width + 10.0f;
            
            NSButton *getApiToken = [[NSButton alloc] initWithFrame:CGRectMake(x, y, 100.0f, 25.0f)];
            [getApiToken setTitle:@"Get Token"];
            [getApiToken setButtonType:NSMomentaryPushInButton];
            [getApiToken setBezelStyle:NSRoundedBezelStyle];
            [getApiToken setTarget:self];
            [getApiToken setAction:@selector(getApiToken_clicked)];

            x = 0;
            y += self.password.frame.size.height + 5.0f;
            
            NSTextView *apiKeyLabel = [[NSTextView alloc] initWithFrame:CGRectMake(x, y, 100.0f, 22.0f)];
            [apiKeyLabel setString:@"API Key"];
            [apiKeyLabel setEditable:false];
            [apiKeyLabel setSelectable:false];
            [apiKeyLabel setDrawsBackground:false];
            x += apiKeyLabel.frame.size.width + 10.0f;
            
            self.apiKey = [[NSTextField alloc] initWithFrame:CGRectMake(x, y, 250.0f, 22.0f)];
            [self.apiKey setEditable: NO];
            [self.apiKey setPlaceholderString:@"API Key from your account"];
            
            NSString *apiKey = [[self myPlugin] getAPIToken];
            if (apiKey != nil)
                [self.apiKey setStringValue:apiKey];
            
            x = 0;
            y += self.apiKey.frame.size.height + 5.0;
            
            NSButton *saveButton = [[NSButton alloc] initWithFrame:CGRectMake(0, y, 120.0f, 25.0f)];
            [saveButton setTitle:@"Save Changes"];
            [saveButton setButtonType:NSMomentaryPushInButton];
            [saveButton setBezelStyle:NSRoundedBezelStyle];
            [saveButton setTarget:self];
            [saveButton setAction:@selector(saveChangesAction:)];
            
            [self addSubview:emailLabel];
            [self addSubview:self.emailAddress];
            [self addSubview:passwordLabel];
            [self addSubview:self.password];
            [self addSubview:getApiToken];
            [self addSubview:apiKeyLabel];
            [self addSubview:self.apiKey];
            [self addSubview:saveButton];
            
        }
        @catch (NSException *exception) {
            NSAlert *alertView = [NSAlert new];
            [alertView setMessageText:@"Error when creating view"];
            [alertView runModal];
        }
        @finally {
            
        }
    }
    return self;
}

- (Wunderlist*) myPlugin
{
    return (Wunderlist*)self.plugin;
}

- (void) ReloadView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self LoadView];
    });
}

- (void) LoadView
{
    
}

#pragma mark 'Functionality behind UI Elements'
-(void)getApiToken_clicked
{
    NSString *errorMessage = nil;
    
    if (self.emailAddress.stringValue.length == 0)
        errorMessage = @"Email Address is required";
    else if (self.password.stringValue.length == 0)
        errorMessage = @"Password is required";
    
    if (errorMessage != nil)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:errorMessage];
        [alert runModal];
    }
    else
    {
        [APIHelperWunderlist getUserWithEmail:self.emailAddress.stringValue andPassword:self.password.stringValue andDelegate:self];
    }
}

-(void)popUpAction:(id)sender
{
}

-(void)saveChangesAction: (id)sender
{
    //Get the Selected List and the API Key, then save them
    Wunderlist *plugin = (Wunderlist *)[self plugin];
    NSString *message;
    BOOL shouldSave = YES;
    
    //Save the API Key
    if ([self.apiKey stringValue].length == 40)
    {
        [plugin setAPIToken:[self.apiKey stringValue]];
    }
    else
    {
        shouldSave = NO;
        message = @"API Key not quite correct. Should be 40 characters.";
    }
    
    if (shouldSave)
    {
        [plugin SavePreferences];
        message = @"Preferences have been saved.";
    }
    
    NSAlert *al = [[NSAlert alloc] init];
    [al setMessageText:message];
    [al runModal];
}

-(void)finishedCallFor:(NSString *)method withData:(NSDictionary *)dict
{
    if ([method isEqualToString:@"GetUser"])
    {
        if (dict == nil)
        {
            NSAlert *al = [[NSAlert alloc] init];
            [al setMessageText:@"Login Error"];
            [al runModal];
        }
        else
        {
            //Great news, we have the API key.
            [self.apiKey setStringValue:[dict objectForKey:@"token"]];
        }
    }
}


@end
