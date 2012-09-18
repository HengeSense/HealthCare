//
//  AllAdvicesView.h
//  SelfHub
//
//  Created by Igor Barinov on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "Vitaportal.h"
#import "AdviceParse.h"
#import "ImageDownloader.h"
#import "AdviceView.h"
#import "Advice.h"

@class Vitaportal;

@interface AllAdvicesView : UIViewController  <UIScrollViewDelegate, ImageDownloaderDelegate, ParseDelegate>
{
	int pageIndex;
    int newAdviceIndex;
}

@property (retain, nonatomic) UIScrollView *mainScroll;
@property (nonatomic, assign) Vitaportal *delegate;
@property (retain, nonatomic) NSMutableArray *allAdvices;
@property (retain, nonatomic) NSMutableArray *pages;
@property (retain, nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSOperationQueue *operations;

-(void) makeAdviceView: (Advice *) advice withIndex:(NSNumber *)index;
- (void)downloadXml: (int) number;
- (void)reloadAdvices;
- (void)startImageDownload:(AdviceView *)adviceView forIndex:(NSNumber *)index;

@end
