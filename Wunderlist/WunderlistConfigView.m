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
#import "WUWebView.h"
#import "WUURLParser.h"
#import <WebKit/WebKit.h>


@interface WunderlistConfigView ()
{
    NSButton *loginButton;
}
@property (strong) NSString *accessToken;
@property (strong) NSWindow *win;
@property (strong) NSOperationQueue *queue;

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
            
            loginButton = [[NSButton alloc] initWithFrame:CGRectMake(20, 20, 120.0f, 25.0f)];
            [loginButton setTitle:@"Login"];
            [loginButton setButtonType:NSMomentaryPushInButton];
            [loginButton setBezelStyle:NSRoundedBezelStyle];
            [loginButton setTarget:self];
            [loginButton setAction:@selector(Login:)];
            [self addSubview:loginButton];
            
            [self LoadToken];
            [self manageLoginBtn];
            

        }
        @catch (NSException *exception) {
            NSLog(@"Wunderlist Exception %@",exception);
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

- (void) LoadToken
{
    self.accessToken = @"";
    if(self.plugin.preferences[wu_accessToken])
        self.accessToken = self.plugin.preferences[wu_accessToken];
    //NSLog(@"LoadToken %@",self.accessToken);
    [self wuList:self.accessToken block:^(NSDictionary *dict, NSError *err) {
        
    }];

}

- (void) LoadView
{
    if([self authenticated])
    {
        [self wuList:self.accessToken block:^(NSDictionary *dict, NSError *err) {
                
        }];
    }

}

- (void) RenderView
{
    
}


- (BOOL) authenticated
{
    if(self.accessToken && self.accessToken.length > 0)
        return YES;
    return NO;
}

- (void) manageLoginBtn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([self authenticated])
        {
            [loginButton setTitle:@"Logout"];
            [loginButton setAction:@selector(Logout:)];
        }
        else
        {
            [loginButton setTitle:@"Login"];
            [loginButton setAction:@selector(Login:)];
        }

    });
}

- (void) Logout:(id)sender
{
    self.accessToken = @"";
    [self saveAccessToken];
    [self manageLoginBtn];
}

- (void) saveAccessToken
{
    self.plugin.preferences[wu_accessToken] = self.accessToken;
    [self.plugin SavePreferences];
}

- (void) Login:(id)sender
{
    if([self authenticated])
        return;

    NSRect myr          = NSMakeRect(0, 0, 600, 550);
    NSScreen *screen    = [NSScreen mainScreen];
    NSRect screenRect   = [screen visibleFrame];
    NSRect r            = NSMakeRect(screenRect.size.width/2 - myr.size.width/2 , screenRect.size.height/2 -  myr.size.height/2, myr.size.width, myr.size.height);
    
    self.win            = [[NSWindow alloc] initWithContentRect:r
                                                      styleMask:NSTitledWindowMask | NSClosableWindowMask
                                                        backing:NSBackingStoreBuffered
                                                          defer:YES];
    
    WUWebView *webView = [[WUWebView alloc] initWithFrame:r];
    [webView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [self.win setContentView:webView];
    [self.win setReleasedWhenClosed:NO];
    [self.win setTitle:@"Wunderlist"];
    
    [webView setPolicyForNavigationBlock:^(WUWebView *wv, NSDictionary *actionInformation, NSURLRequest *request, WebFrame *frame, id<WebPolicyDecisionListener> listener) {
        
        //NSLog(@"%@",request);
        if([request.URL.absoluteString isEqualToString:@"https://www.wunderlist.com/login"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.win makeKeyAndOrderFront:self];
            });
        }
        if([request.URL.host isEqualToString:@"airmailapp.com"])
        {
            WUURLParser *wup = [[WUURLParser alloc] initWithURL:request.URL];
            NSString *code   = [wup valueForVariable:@"code"];
            //NSLog(@"code %@",code);
            if(code && code.length > 0)
            {
                [APIHelperWunderlist accessToken:code block:^(NSDictionary *dict, NSError *err) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.win close];
                        self.win = nil;
                    });

                    if(err)
                    {
                        [(Wunderlist*)self.plugin PostError:err];
                    }
                    else
                    {
                        self.accessToken = dict[@"access_token"];
                        [self saveAccessToken];
                    }
                    [self manageLoginBtn];

                }];
            }
            [listener ignore];
        }
        [listener use];
        
    }];
    
    NSString *u = [NSString stringWithFormat:@"https://www.wunderlist.com/oauth/authorize?client_id=%@&redirect_uri=%@",wu_oauth_kClientID,@"http://airmailapp.com"];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:u]]];
}

- (void) wuList:(NSString*)accessToken block:(void (^)(NSDictionary *dict, NSError*err))block
{
    [APIHelperWunderlist wuApiList:self.accessToken block:^(NSDictionary *dict, NSError *err) {
        
        //NSLog(@"APIHelperWunderlist %@",dict);
        if(!err)
        {
            self.plugin.preferences[wu_list] = dict;
            [self.plugin SavePreferences];
        }
        block(dict,err);
    }];
}







@end
