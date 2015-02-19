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
    NSTextField *nameField;
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
            
            loginButton = [[NSButton alloc] initWithFrame:CGRectMake(20, 20, 120.0f, 30.0f)];
            [loginButton setTitle:@"Login"];
            [loginButton setButtonType:NSMomentaryPushInButton];
            [loginButton setBezelStyle:NSRoundedBezelStyle];
            [loginButton setTarget:self];
            [loginButton setAction:@selector(Login:)];
            [self addSubview:loginButton];
            
            nameField = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 60, 360, 25)];
//            NSLog(@"nameField1 %@",NSStringFromRect(nameField1.frame));
            [nameField setStringValue:@"User:"];
            [nameField setBordered:NO];
            [nameField setFont:[NSFont systemFontOfSize:11]];
            [nameField setBezeled:NO];
            [nameField setDrawsBackground:NO];//deprecated
            [nameField setEditable:NO];
            [nameField setSelectable:NO];
            [nameField setFont:[NSFont systemFontOfSize:13]];
            [[nameField cell] setBackgroundStyle:NSBackgroundStyleRaised];
            [self addSubview:nameField];

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
    
    //NSLog(@"self.plugin.preferences %@",self.plugin.preferences);
    [self BasicWu];
}

- (void) LoadView
{
    if([self authenticated])
    {
        [self BasicWu];
    }

}

- (void) BasicWu
{
    [self wuUser:self.accessToken block:^(NSDictionary *dict, NSError *err) {
        
        //NSLog(@"wuUser %@",dict);
        [self manageLoginBtn];
        
        [self wuList:self.accessToken block:^(NSArray *arr, NSError *err) {
            //NSLog(@"wuList %@",dict);
        }];
        
    }];
    
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
        
        nameField.stringValue = [NSString stringWithFormat:@"User:"];
        NSDictionary *user    = self.plugin.preferences[wu_user];
        if(user)
        {
            NSString *email = user[@"email"];
            if(email.length > 0)
                nameField.stringValue = [NSString stringWithFormat:@"User: %@",email];
        }

    });
}

- (void) Logout:(id)sender
{
    self.plugin.preferences[wu_user] = @{};
    self.plugin.preferences[wu_list] = @[];
    self.accessToken                 = @"";
    [self saveAccessToken];
    [self manageLoginBtn];
    //NSLog(@"Logout self.plugin.preferences %@",self.plugin.preferences);

//    [APIHelperWunderlist revoke_accessToken:self.accessToken block:^(BOOL ok, NSError *err) {
//        
//        self.plugin.preferences[wu_user] = @{};
//        self.plugin.preferences[wu_list] = @[];
//        self.accessToken                 = @"";
//        [self saveAccessToken];
//        [self manageLoginBtn];
//        NSLog(@"Logout self.plugin.preferences %@",self.plugin.preferences);
//
//    }];
    
}

- (void) saveAccessToken
{
    self.plugin.preferences[wu_accessToken] = self.accessToken;
    [self.plugin SavePreferences];
}

- (void) Login:(id)sender
{
    if([self authenticated])
    {
        NSLog(@"Wunderlist already authenticated");
        return;
    }

    NSRect myr          = NSMakeRect(0, 0, 600, 550);
    NSScreen *screen    = [NSScreen mainScreen];
    NSRect screenRect   = [screen visibleFrame];
    NSRect r            = NSMakeRect(screenRect.size.width/2 - myr.size.width/2 , screenRect.size.height/2 -  myr.size.height/2, myr.size.width, myr.size.height);
    
    self.win            = [[NSWindow alloc] initWithContentRect:r
                                                      styleMask:NSTitledWindowMask | NSClosableWindowMask
                                                        backing:NSBackingStoreBuffered
                                                          defer:YES];
    
    WUWebView *webView = [[WUWebView alloc] initWithFrame:r];
    
//    CFUUIDRef uuid = CFUUIDCreate(nil);
//    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuid));
//    CFRelease(uuid);
//    [webView setIdentifier:uuidString];
    
    [webView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [self.win setContentView:webView];
    [self.win setReleasedWhenClosed:NO];
    [self.win setTitle:@"Wunderlist"];
    
//    WebPreferences *pref = [[WebPreferences alloc] initWithIdentifier:@"_wu_cache_"];
//    [pref setLoadsImagesAutomatically:YES];
//    [pref setJavaScriptCanOpenWindowsAutomatically:YES];
//    [pref setJavaScriptEnabled:YES];
//    [pref setCacheModel:WebCacheModelDocumentViewer];
//    [pref setPlugInsEnabled:YES];
//    [pref setUsesPageCache:NO];
//    [webView setPreferences:pref];
//    [webView setResourceLoadBlock:^NSURLRequest *(WUWebView *wv, id identifier, NSURLRequest *request, NSURLResponse *redirectResponse, WebDataSource *dataSource) {
//        
//        NSURLRequest *requestBack = [NSURLRequest requestWithURL:[request URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[request timeoutInterval]];
//        return requestBack;
//    }];

    [webView setPolicyForNavigationBlock:^(WUWebView *wv, NSDictionary *actionInformation, NSURLRequest *request, WebFrame *frame, id<WebPolicyDecisionListener> listener) {
        
        //NSLog(@"setPolicyForNavigationBlock %@",request);
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
                        [self BasicWu];
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



- (void) wuList:(NSString*)accessToken block:(void (^)(NSArray *arrx, NSError*err))block
{
    [APIHelperWunderlist wuApiList:self.accessToken block:^(NSArray *arrx, NSError *err) {
        
        //NSLog(@"APIHelperWunderlist %@",dict);
        if(!err)
        {
            self.plugin.preferences[wu_list] = arrx;
            [self.plugin SavePreferences];
        }
        block(arrx,err);
    }];
}

- (void) wuUser:(NSString*)accessToken block:(void (^)(NSDictionary *dict, NSError*err))block
{
    [APIHelperWunderlist wuApiUser:self.accessToken block:^(NSDictionary *dict, NSError *err) {
        
        //NSLog(@"APIHelperWunderlist %@",dict);
        if(!err)
        {
            self.plugin.preferences[wu_user] = dict;
            [self.plugin SavePreferences];
            
            //        {
            //            "id": 6234958,
            //            "name": "BENCHMARK",
            //            "email": "benchmark@example.com",
            //            "created_at": "2013-08-30T08:25:58.000Z",
            //            "revision": 1
            //        }
            
            

        }
        block(dict,err);
    }];
}







@end
