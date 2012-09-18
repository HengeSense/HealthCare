//
//  ImageDownloader.m
//  SelfHub
//

#import "ImageDownloader.h"
#import "AdviceView.h"

@implementation ImageDownloader

@synthesize adviceView;
@synthesize adviceIndex;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

- (void)dealloc
{
    [adviceView release];
    [adviceIndex release];
    
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString: adviceView.advice.imageURLString]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
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
    NSLog(@"%@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    self.adviceView.iview.image = image;
    self.adviceView.iview.backgroundColor = [UIColor clearColor];
    self.activeDownload = nil;
    self.adviceView.advice.image = image;
    
    [image release];
    self.imageConnection = nil;
    
    //[delegate adviceImageDidLoad:adviceIndex];
}

@end

