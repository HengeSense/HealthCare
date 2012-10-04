//
//  ImageDownloader.m
//  SelfHub
//

#import "ImageDownloader.h"
#import "AdviceView.h"

@implementation ImageDownloader

//@synthesize adviceIndex;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize delegate;
@synthesize isLoading;

#pragma mark

- (void)dealloc
{
    //[adviceView release];
    //[adviceIndex release];
    [activeDownload release];
    //[imageConnection cancel];
    [imageConnection release];
    [delegate release];
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString: delegate.imageURLString]] delegate:self];
    self.imageConnection = conn;
    self.isLoading = YES;
    [conn release];
}

- (void)cancelDownload
{
    //NSLog(@"stop download");
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
    self.isLoading = NO;
    //[self.delegate stopAnimationDownloadImage];
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.activeDownload = nil;
    self.imageConnection = nil;
    self.isLoading = NO;
    NSLog(@"%@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connection did finish loading");
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    [self.delegate adviceImageDidLoad:image];
    [image release];
    self.isLoading = NO;
    self.imageConnection  = nil;
    self.activeDownload = nil;
}

@end

