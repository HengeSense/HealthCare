//
//  AllAdvicesView.m
//  SelfHub
//
//  Created by Igor Barinov on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllAdvicesView.h"

#define kFirstAdvices 2
#define kMaxVisiblePages 3

@implementation AllAdvicesView

@synthesize delegate;
@synthesize allAdvices;
@synthesize pages;
@synthesize mainScroll;
@synthesize favoriteAdvices;
@synthesize loading;
@synthesize favoritesScroll;
@synthesize favoritePages;
@synthesize favoriteData, connection, operations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:mainScroll];
		mainScroll.backgroundColor = [UIColor clearColor];
		mainScroll.pagingEnabled = YES;
		mainScroll.scrollEnabled = YES;
		mainScroll.delegate = self;
        
        favoritesScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        favoritesScroll.backgroundColor = [UIColor clearColor];
        [self.view addSubview:favoritesScroll];
        favoritesScroll.hidden = YES;
        favoritesScroll.pagingEnabled = YES;
        favoritesScroll.scrollEnabled = YES;
        favoritesScroll.delegate = self;
		//favoritesScroll.contentSize = CGSizeMake(self.view.frame.size.width, favoritesScroll.contentSize.height);
        pageIndex = 0;
        //newAdviceIndex = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allAdvices = [NSMutableArray array];
    self.pages = [[NSMutableArray alloc] init];
    self.favoriteAdvices = [[NSMutableArray alloc] init];
    self.favoritePages = [[NSMutableArray alloc] init];
    
    /*
    if (kFirstAdvices > 2) {
        for (int i = 0 ; i < kFirstAdvices; i++) {
            [self downloadXml:1];
        }
    } else
    {
        [self downloadXml:kFirstAdvices];

    }
    */
    //[self downloadXml:1];
    
}

- (void)downloadFirstAdvices
{
    if([self.pages count] == 0)
    {
        self.loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.loading setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
        [self.view addSubview:loading];
        
        [loading startAnimating];

        if (kFirstAdvices > 2) {
            for (int i = 0 ; i < kFirstAdvices; i++) {
                [self downloadXml:1];
            }
        } else
        {
            [self downloadXml:kFirstAdvices];
        
        }
    }
}

- (void)downloadXml:(int)number
{
    NSURL *url;
    if(number > 1)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://vitaportal.ru/services/iphone/advices?advice_id=127973@&count=%i",number]];
    else url = [NSURL URLWithString:@"http://vitaportal.ru/services/iphone/advices?advice_id=127972"];
    id	context = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                         cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                                     timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                         action:@selector(handleResultOrError:withContext:)
                                                        context:context] autorelease];
    
    NSURLConnection* conn = [NSURLConnection connectionWithRequest:request delegate:network];
    [conn start];
    
}

- (void)handleResultOrError:(id)resultOrError withContext:(id)context
{
    if([resultOrError isKindOfClass:[NSError class]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"The Internet connection appears to be offline." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else
    {
        NSData* data = [resultOrError objectForKey:@"data"];
    
   /* NSLog(@"%@", data);
    NSString *str = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    NSLog(@"%@", str);
    [str release];
    */
    
        self.operations = [[NSOperationQueue alloc] init];
        AdviceParse *parser = [[AdviceParse alloc] initWithData:data delegate:self] ;
    
        [self.operations addOperation:parser];
        [parser release];
    }
}

- (void)didFinishParsing:(NSArray *)advList
{
    //NSLog(@"didFinishParsing");
    [self performSelectorOnMainThread:@selector(handleLoadedAdvices:) withObject:advList waitUntilDone:NO];
    //self.operations = nil;
}

- (void)handleLoadedAdvices:(NSArray *)loadedAdvices
{
    [self.allAdvices addObjectsFromArray:loadedAdvices];
    [self loadAdvices];
}

- (void)handleError:(NSError *)error
{
    NSLog(@"ERROR");
    NSLog(@"%@", error);
}

- (void)parseErrorOccurred:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadAdvices
{
    int pagesNumber = [pages count];
    int advicesNumber = [allAdvices count];
    for (int i = pagesNumber; i < advicesNumber; i++)
    {
        //newAdviceIndex++;
        if(i == 0)
        {
            [self.loading stopAnimating];
            self.loading = nil;
        }
        [pages addObject:[self makeAdviceView:[allAdvices objectAtIndex:i] withIndex:[NSNumber numberWithInt:i] Scroll:mainScroll]];
    }
}

- (AdviceView *)makeAdviceView:(Advice *)advice withIndex:(NSNumber *)index Scroll:(UIScrollView *)scroll
{    
    int width = self.view.frame.size.width;
    CGPoint point;
    AdviceView *aview;
    
    if(index.intValue == 0)
        aview = [[AdviceView alloc] initWithFrame:CGRectMake(5, 6, 310, 424)];
    else
    {
        point.x = [index intValue] * 320 + 5;
        point.y = 6;
        aview = [[AdviceView alloc] initWithFrame:CGRectMake(point.x, point.y, 310, 424)];
    }
    aview.tag = [index intValue];
    aview.backgroundColor = [UIColor whiteColor];
    aview.advice = advice;
    
    if([scroll isEqual: mainScroll])
        advice.main = aview;
    else advice.favorite = aview;
    
    scroll.contentSize = CGSizeMake(scroll.contentSize.width + width, scroll.contentSize.height);
    
    CALayer *l = [aview layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10];
    aview.delegate = self;
    
    [scroll addSubview:aview];
    
    if(index.intValue >= kFirstAdvices &&
       [mainScroll isEqual:scroll])
    {
        point.x -= 5;
        point.y -= 6;
        [scroll setContentOffset:point animated:YES];
    }
   
    if(aview.advice.imageURLString != nil
       && index.intValue == 0
       && [scroll isEqual:mainScroll])
    {
        [aview.advice startDownloadImage];
    }
    
    if(advice.downloader.isLoading
       && advice.favorite != nil)
        [advice startAnimationDownloadImage];
    return [aview autorelease];
}
 
- (void)viewDidUnload
{
    self.delegate = nil;
    self.allAdvices = nil;
    self.pages = nil;
    self.mainScroll = nil;
    self.favoriteAdvices = nil;
    self.operations = nil;
    self.loading = nil;
    self.favoritesScroll = nil;
    self.favoritePages = nil;
    self.favoriteData = nil;
    self.connection = nil;
    self.operations = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    if(allAdvices) [allAdvices release];     
    if(pages) [pages release];
    [loading release];
    [mainScroll release];
    if(favoriteAdvices)[favoriteAdvices release];
    [loading release];
    [favoritesScroll release];
    if(favoritePages) [favoritePages release];
    if(favoriteData)[favoriteData release];
    if(connection)[connection release];    
    if(operations)[operations release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(page < 0)
    {
        return;
    }
    
    
    if(page != 0 && [scrollView isEqual:mainScroll])
    {
        [[allAdvices objectAtIndex:page-1] stopDownloadImage];
        if(page + 1 != [allAdvices count])
            [[allAdvices objectAtIndex:page+1] stopDownloadImage];
    }
    
    //UIScrollView *tmp;
    //tmp = [scrollView isEqual:mainScroll] ? [mainScroll retain] : [favoritesScroll retain];
    Advice *adv;
    
    if([scrollView isEqual:mainScroll])
    {
        adv = [allAdvices objectAtIndex:page];
    }
    else adv = [favoriteAdvices objectAtIndex:page];
    
    if(adv.imageURLString != nil
       && adv.image == nil
       && adv.downloader.isLoading == NO)
        [adv startDownloadImage];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([scrollView isEqual:mainScroll])
    {
        float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
        if (rightEdge >= scrollView.contentSize.width + 10)
        {
            [self downloadXml:1];
            return;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)addToFavoritesArray:(AdviceView *)adviceView
{
    
    if(![favoriteAdvices containsObject:adviceView.advice])
    {
        AdviceView *adv = [self makeAdviceView:adviceView.advice
                                     withIndex:[NSNumber numberWithInt:[favoritePages count]]
                                        Scroll:favoritesScroll];
        [favoritePages addObject:adv];
        [favoriteAdvices addObject:adviceView.advice];
       // adviceView.advice.favorite = adv;
        //self.mainScroll.hidden = YES;
        //self.favoritesScroll.hidden = NO;
        //NSLog(@"%f %f %f %f", adv.frame.origin.x, adv.frame.origin.y, adv.frame.size.width, adv.frame.size.height);
    }
    //NSLog(@"fav count %i",[favoriteAdvices count]);
    //NSLog(@"%f", [(AdviceView *)[favoritePages lastObject] frame].origin.x);
    //NSLog(@"%i", [adviceView.advice retainCount]);
    /*
    if(aview.advice.imageURLString != nil
       && index.intValue == 0)
    {
        [self startImageDownload:aview forIndex:index];
        
    }
    */

}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"APPEAR");
    /*
    if(favoriteData==nil){
        [self loadFavoriteAdvicesFromFile];
    }
    else
    {
        [self convertSavedDataToAdvice];
    };*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"DISAPPEAR");
    //[self saveFavoriteAdvicesToFile];
}

- (NSString *)getBaseDir{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
};

- (void)convertAdviceToSavedData
{
    NSMutableArray *exportArray = [[NSMutableArray alloc] init];
    NSLog(@"Convert advice to");
    for(Advice *adv in self.favoriteAdvices)
    {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:adv.title forKey:@"title"];
        [dict setObject:adv.description forKey:@"description"];
        [dict setObject:adv.m_id forKey:@"id"];
        [dict setObject:adv.type forKey:@"type"];
        if(adv.imageURLString)
            [dict setObject:adv.imageURLString forKey:@"imageUrl"];
        //if(adv.image)
        //    [dict setObject:UIImageJPEGRepresentation(adv.image, 1.0) forKey:@"image"];
        //NSLog(@"%@", dict);
        [exportArray addObject:dict];
        [dict release];
    }
    
    if(favoriteData) [favoriteData release];
    favoriteData = [[NSMutableArray alloc] initWithArray:exportArray];

    [exportArray release];
}

- (void)convertSavedDataToAdvice
{
    NSLog(@"=================================%@", self.favoriteData);
    
    if([favoriteData count] == 0)
    {
        NSLog(@"=========");
        NSLog(@"=NO data=");
        NSLog(@"=========");
    }
    else if([favoriteData count] == [favoriteAdvices count])
    {
        NSLog(@"=============");
        NSLog(@"=NO new data=");
        NSLog(@"=============");
    }
    else
    {
        for(NSMutableDictionary *dict in self.favoriteData)
        {
            Advice *advice = [[[Advice alloc] init] autorelease];
            advice.title = [dict objectForKey:@"title"];
            advice.description = [dict objectForKey:@"description"];
            advice.type = [dict objectForKey:@"type"];
            advice.m_id = [dict objectForKey:@"id"];
            advice.imageURLString = [dict objectForKey:@"imageUrl"];
            AdviceView *adv = [self makeAdviceView:advice
                                     withIndex:[NSNumber numberWithInt:[favoritePages count]]
                                        Scroll:favoritesScroll];
            [favoritePages addObject:adv];
            [favoriteAdvices addObject:advice];
        }
        
    }
    
}

- (void)loadFavoriteAdvicesFromFile
{
    
    NSLog(@"loadFavoriteAdvicesToFile");
    
    NSString *listFilePath = [[self getBaseDir] stringByAppendingPathComponent:@"favoriteAdvices.dat"];
    NSArray *loadedParams = [NSArray arrayWithContentsOfFile:listFilePath];
    NSLog(@"%@", loadedParams);
    if(loadedParams)
    {
        if(favoriteData) [favoriteData release];
        favoriteData = [[NSMutableArray alloc] initWithArray:loadedParams];
    };
    
    if([self isViewLoaded])
    {
        [self convertSavedDataToAdvice];
    }
};

- (void)saveFavoriteAdvicesToFile
{
    NSLog(@"saveFavoriteAdvicesToFile");
    if([self isViewLoaded]){
        [self convertAdviceToSavedData];
    };
    
    if(favoriteData==nil){
        return;
    };
    NSLog(@"%@", self.favoriteData);
    BOOL succ = [favoriteData writeToFile:[[self getBaseDir] stringByAppendingPathComponent:@"favoriteAdvices.dat"] atomically:YES];
    if(succ == NO)
    {
        NSLog(@"Favorite Advices: Error during save data");
    };
}

@end

