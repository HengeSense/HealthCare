//
//  AllAdvicesView.m
//  SelfHub
//
//  Created by Igor Barinov on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllAdvicesView.h"

#define kFirstAdvices 2

@interface AllAdvicesView ()

- (void)startIconDownload:(Advice *)adviceRecord forIndex:(NSNumber *)index;

@end

@implementation AllAdvicesView

@synthesize delegate;
@synthesize allAdvices;
@synthesize pages;
@synthesize imageDownloadsInProgress;
@synthesize mainScroll;

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
		
		pages = [[NSMutableArray alloc] init];
        
        pageIndex = 0;
        newAdviceIndex = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allAdvices = [NSMutableArray array];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self downloadXml:kFirstAdvices];
    [self downloadXml:1];
    
}

-(void)downloadXml:(int)number
{
    NSURL *url;
    if(number > 1)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://vitaportal.ru/services/iphone/advices?advice_id=127973@&count=%i",number]];
    else url = [NSURL URLWithString:@"http://vitaportal.ru/services/iphone/advices?advice_id=127973"];
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
    
    NSData* data = [resultOrError objectForKey:@"data"];
    
    self.operations = [[NSOperationQueue alloc] init];
    
    AdviceParse *parser = [[AdviceParse alloc] initWithData:data delegate:self];
    
    [self.operations addOperation:parser];
    [parser release];
}

- (void)didFinishParsing:(NSArray *)advList
{
    [self performSelectorOnMainThread:@selector(handleLoadedAdvices:) withObject:advList waitUntilDone:NO];
    self.operations = nil;
}

- (void)handleLoadedAdvices:(NSArray *)loadedAdvices
{
    [self.allAdvices addObjectsFromArray:loadedAdvices];
    [self reloadAdvices];
}

- (void)handleError:(NSError *)error
{
    NSLog(@"ERROR");
}

- (void)parseErrorOccurred:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}

- (void)dealloc
{
    [allAdvices release];
	[imageDownloadsInProgress release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}


- (void)reloadAdvices
{
    int pagesNumber = [pages count];
    int advicesNumber = [allAdvices count];
    for (int i = pagesNumber; i < advicesNumber; i++)
    {
        NSLog(@"NUMBER %i", i);
        newAdviceIndex++;
        [self makeAdviceView:[allAdvices objectAtIndex:i] withIndex:[NSNumber numberWithInt:i]];
    }
}

- (void)makeAdviceView:(Advice *)advice withIndex:(NSNumber *)index
{
    int width = self.view.frame.size.width;
    AdviceView *aview = [[AdviceView alloc] initWithFrame:CGRectMake(5 + width * index.intValue, 6, 310, 424)];
    aview.tag = [index intValue];
    aview.backgroundColor = [UIColor whiteColor];
    aview.advice = advice;
    
    CALayer *l = [aview layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10];
    
    mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width + width, mainScroll.contentSize.height);
    [mainScroll addSubview:aview];
    [pages addObject:aview];
    if(aview.advice.imageURLString != nil)
    {
        NSLog(@"not nil");
       [self startImageDownload:aview forIndex:index];
    }
    if(index.intValue >= kFirstAdvices)
    {
        [mainScroll setContentOffset:CGPointMake(self.view.frame.size.width * aview.tag, 0) animated:YES];
    }
    [aview release];

}

- (void)viewDidUnload
{
    self.delegate = nil;
    self.allAdvices = nil;
    self.pages = nil;
    self.imageDownloadsInProgress = nil;
    self.mainScroll = nil;
    NSLog(@"view did unload");
    [super viewDidUnload];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    float rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
    //NSLog(@"=== %f ===", rightEdge);
    if (rightEdge >= scrollView.contentSize.width)
    {
        [self downloadXml:1];
        newAdviceIndex++;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)startImageDownload:(AdviceView *)adviceView forIndex:(NSNumber *)index
{
    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:index];
    if (imageDownloader == nil)
    {
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.adviceView = adviceView;
        imageDownloader.adviceIndex = index;
        imageDownloader.delegate = self;
        [imageDownloadsInProgress setObject:imageDownloader forKey:index];
        [imageDownloader startDownload];
        [imageDownloader release];
    }
}

/*
- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
            
            if (!appRecord.appIcon) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}
*/

- (void)adviceImageDidLoad:(NSNumber *)index
{

}

@end

