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
#import "AdviceView.h"
#import "Advice.h"
#import "ImageDownloader.h"

@class Vitaportal;
@class AdviceView;
@interface AllAdvicesView : UIViewController  <UIScrollViewDelegate, ParseDelegate>
{
	int pageIndex;
    //int newAdviceIndex;
}

@property (retain, nonatomic) UIScrollView *mainScroll;
@property (retain, nonatomic) UIScrollView *favoritesScroll;
@property (nonatomic, assign) Vitaportal *delegate;
@property (retain, nonatomic) NSMutableArray *allAdvices;
@property (retain, nonatomic) NSMutableArray *favoriteAdvices;
@property (retain, nonatomic) NSMutableArray *pages;
@property (retain, nonatomic) NSMutableArray *favoritePages;
@property (retain, nonatomic) NSMutableArray *favoriteData;
@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSOperationQueue *operations;
@property (retain, nonatomic) UIActivityIndicatorView *loading; //переделать

- (void) downloadFirstAdvices;
- (AdviceView *) makeAdviceView: (Advice *) advice withIndex:(NSNumber *)index Scroll:(UIScrollView *)scroll;
- (void) downloadXml: (int) number;
- (void) loadAdvices;
- (void) addToFavoritesArray:(AdviceView *)advice;

- (NSString *)getBaseDir;
- (void)convertAdviceToSavedData;
- (void)loadFavoriteAdvicesFromFile;
- (void)saveFavoriteAdvicesToFile;

@end
