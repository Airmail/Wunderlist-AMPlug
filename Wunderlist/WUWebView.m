//
//  BLWebView.m
//  Lab
//
//  Created by Giovanni Simonicca on 26/04/14.
//  Copyright (c) 2014 Bloop. All rights reserved.
//

#import "WUWebView.h"

@interface WUWebView()
{
    
}
@property (strong) BLWebViewFrameLoadedBlock      frameLoadedBlockx;
@property (strong) BLWebViewDataSourceLoadedBlock dataSourceLoadedBlockx;
@property (strong) BLWebViewPolicyForNavigation   plociyForNavigationBlockx;

@end

@implementation WUWebView

- (void) setFrameLoadedBlock:(BLWebViewFrameLoadedBlock)loadedBlock
{
    self.frameLoadedBlockx = loadedBlock;
}

- (void) setDataSourceLoadedBlock:(BLWebViewDataSourceLoadedBlock)loadedBlock
{
    self.dataSourceLoadedBlockx = loadedBlock;
}

- (void) setPolicyForNavigationBlock:(BLWebViewPolicyForNavigation)loadedBlock
{
    self.plociyForNavigationBlockx = loadedBlock;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.customValues = [NSMutableDictionary dictionary];
        [self setPolicyDelegate:self];
        [self setFrameLoadDelegate:self];
        //[self setCustomUserAgent:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14"];

    }
    return self;
}

- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame *)webFrame
{
    if([[self mainFrame] isEqualTo:webFrame])
    {
        if(self.frameLoadedBlockx)
            self.frameLoadedBlockx(self,webFrame,YES);
    }
    else
    {
        if(self.frameLoadedBlockx)
            self.frameLoadedBlockx(self,webFrame,NO);
    }
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    if(self.dataSourceLoadedBlockx)
        self.dataSourceLoadedBlockx(self,dataSource);
}

- (void) webView:(WebView *)webView  decidePolicyForNavigationAction:(NSDictionary *)actionInformation
		 request:(NSURLRequest *)request
		   frame:(WebFrame *)frame
decisionListener:(id <WebPolicyDecisionListener >)listener
{
    if(self.plociyForNavigationBlockx)
        self.plociyForNavigationBlockx((WUWebView*)webView,actionInformation,request,frame,listener);
    else
        [listener use];
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSString*) jslistener
{
    NSString *js =
    @"var s_ajaxListener = new Object();\r\n"
    "s_ajaxListener.tempOpen = XMLHttpRequest.prototype.open;\r\n"
    "s_ajaxListener.tempSend = XMLHttpRequest.prototype.send;\r\n"
    "s_ajaxListener.callback = function () {\r\n"
    "    window.location='mpAjaxHandler://' + this.url;\r\n"
    "};\r\n"
    "\r\n"
    "XMLHttpRequest.prototype.open = function(a,b) {\r\n"
    "    if (!a) var a='';\r\n"
    "    if (!b) var b='';\r\n"
    "    s_ajaxListener.tempOpen.apply(this, arguments);\r\n"
    "    s_ajaxListener.method = a;\r\n"
    "    s_ajaxListener.url = b;\r\n"
    "    if (a.toLowerCase() == 'get') {\r\n"
    "        s_ajaxListener.data = b.split('?');\r\n"
    "        s_ajaxListener.data = s_ajaxListener.data[1];\r\n"
    "    }\r\n"
    "}\r\n"
    "\r\n"
    "XMLHttpRequest.prototype.send = function(a,b) {\r\n"
    "    if (!a) var a='';\r\n"
    "    if (!b) var b='';\r\n"
    "    s_ajaxListener.tempSend.apply(this, arguments);\r\n"
    "    if(s_ajaxListener.method.toLowerCase() == 'post')s_ajaxListener.data = a;\r\n"
    "    s_ajaxListener.callback();\r\n"
    "}\r\n"
    ;
    return js;
}
@end
