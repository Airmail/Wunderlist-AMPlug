//
//  BLWebView.h
//  Lab
//
//  Created by Giovanni Simonicca on 26/04/14.
//  Copyright (c) 2014 Bloop. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WUWebView : WebView
{
    
}
@property (strong) NSMutableDictionary *customValues;
typedef void (^BLWebViewFrameLoadedBlock)(WUWebView *wv, WebFrame *wf, BOOL main);
typedef void (^BLWebViewDataSourceLoadedBlock)(WUWebView *wv, WebDataSource *dataSource);
typedef void (^BLWebViewPolicyForNavigation)(WUWebView *wv, NSDictionary *actionInformation, NSURLRequest *request, WebFrame *frame, id <WebPolicyDecisionListener >listener);
typedef NSURLRequest* (^BLWebViewResourceLoadBlock)(WUWebView *wv, id identifier, NSURLRequest *request, NSURLResponse *redirectResponse, WebDataSource *dataSource);

@property (strong) NSString* viewId;
- (void) setFrameLoadedBlock:(BLWebViewFrameLoadedBlock)loadedBlock;
- (void) setDataSourceLoadedBlock:(BLWebViewDataSourceLoadedBlock)loadedBlock;
- (void) setPolicyForNavigationBlock:(BLWebViewPolicyForNavigation)loadedBlock;
- (void) setResourceLoadBlock:(BLWebViewResourceLoadBlock)resourceLoadBlock;

@end
