//
//  AllAdvicesView.m
//  SelfHub
//
//  Created by Igor Barinov on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllAdvicesView.h"

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
		//mainScroll.contentSize = CGSizeMake(self.view.frame.size.width*2, self.view.frame.size.height);
		mainScroll.pagingEnabled = YES;
		mainScroll.scrollEnabled = YES;
		mainScroll.delegate = self;
		
		pages = [[NSMutableArray alloc] init];
        
        pageIndex = 0;
        newAdviceIndex = 0;
        
        for(int i = 0; i < 2; i++)
        {
            NSLog(@"newAdviceIndex %i", newAdviceIndex);
           // [self makeAdviceView:i withUrlString:@"http://vitaportal.ru/services/iphone/advices?advice_id=127973@&count=2"];
            newAdviceIndex++;
        }
    //[mainScroll setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
    //[mainScroll setContentOffset:CGPointMake([mainScroll contentSize].width - self.view.frame.size.width, 0) animated:YES];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allAdvices = [NSMutableArray array];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self downloadXml:2];
    
}

-(void)downloadXml:(int)number
{
    
    NSURL *signinrUrl = [NSURL URLWithString:@"http://vitaportal.ru/services/iphone/advices?advice_id=127973@&count=2"];
    id	context = nil;
    NSMutableURLRequest *requestSigninMedarhiv = [NSMutableURLRequest requestWithURL:signinrUrl
                                                                         cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                                     timeoutInterval:30.0];
    [requestSigninMedarhiv setHTTPMethod:@"GET"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                         action:@selector(handleResultOrError:withContext:)
                                                        context:context] autorelease];
    
    NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestSigninMedarhiv delegate:network];
    [conn start];
    
}

- (void)handleResultOrError:(id)resultOrError withContext:(id)context
{
    
    NSData* data = [resultOrError objectForKey:@"data"];
    
    self.operations = [[NSOperationQueue alloc] init];
    
    adviceParse *parser = [[adviceParse alloc] initWithData:data delegate:self];
    
    [self.operations addOperation:parser];
    [parser release];
}

- (void)didFinishParsing:(NSArray *)advList
{
    //[self performSelectorOnMainThread:@selector(handleLoadedAdvices:) withObject:advList waitUntilDone:NO];
    //Advice * adv = [advList objectAtIndex:0];
   // NSLog(@"%@", adv.description);

    self.operations = nil;
}

- (void)handleLoadedAdvices:(NSArray *)loadedAdvices
{
    [self.allAdvices addObjectsFromArray:loadedAdvices];
    Advice * adv = [allAdvices objectAtIndex:0];
    NSLog(@"%@", adv.description);
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


- (AdviceView *)makeAdviceView:(Advice *)advice withIndex:(NSNumber *)index
{
    int width = self.view.frame.size.width;
    AdviceView *aview = [[AdviceView alloc] initWithFrame:CGRectMake(5 + width * index.intValue, 6, 310, 424)];
    aview.tag = 0;
    aview.backgroundColor = [UIColor whiteColor];
    
    mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.width + width, mainScroll.contentSize.height);
    [mainScroll addSubview:aview];
    [pages addObject:aview];
    
    [aview autorelease];
    
    return aview;

}

- (void)viewDidUnload
{
    self.delegate = nil;
    self.allAdvices = nil;
    self.pages = nil;
    self.imageDownloadsInProgress = nil;
    self.mainScroll = nil;
    
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
    
    /*
    float bottomEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
    NSLog(@"=== %f ===", bottomEdge);
    if (bottomEdge >= scrollView.contentSize.width)
    {
        NSLog(@"New view %i", newAdviceIndex);
       // [self makeAdviceView:newAdviceIndex withUrlString:@"http://vitaportal.ru/services/iphone/advices?advice_id=127973@&count=2"];
        
       [scrollView setContentOffset:CGPointMake(self.view.frame.size.width * newAdviceIndex, 0) animated:NO];
       // [mainScroll scrollRectToVisible:adv.frame animated:YES];
            newAdviceIndex++;

        
    }*/
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)startImageDownload:(Advice *)advice forIndex:(NSNumber *)index
{
    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:index];
    if (imageDownloader == nil)
    {
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.adviceRecord = advice;
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
    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:index];
    if (imageDownloader != nil)
    {
        NSLog(@"loaded");
       // AdviceView * adv = [pages objec
        
        
    }
}

/*
#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}
*/

@end

