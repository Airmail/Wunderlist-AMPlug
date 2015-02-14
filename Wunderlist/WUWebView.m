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
@property (strong) BLWebViewResourceLoadBlock     resourceLoadBlockx;


//WebResourceLoadDelegate


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

- (void) setResourceLoadBlock:(BLWebViewResourceLoadBlock)resourceLoadBlock
{
    self.resourceLoadBlockx = resourceLoadBlock;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.customValues = [NSMutableDictionary dictionary];
        [self setPolicyDelegate:self];
        [self setFrameLoadDelegate:self];
        [self setResourceLoadDelegate:self];

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

- (NSURLRequest *)webView:(WebView *)sender
                 resource:(id)identifier
          willSendRequest:(NSURLRequest *)request
         redirectResponse:(NSURLResponse *)redirectResponse
           fromDataSource:(WebDataSource *)dataSource {
    
    if(self.resourceLoadBlockx)
        return self.resourceLoadBlockx((WUWebView*)sender,identifier,request,redirectResponse,dataSource);
    else
        return request;
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
