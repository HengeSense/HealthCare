//
//  ImageDownloader.m
//  SelfHub
//

#import "ImageDownloader.h"


@implementation ImageDownloader

@synthesize adviceRecord;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize adviceIndex;

#pragma mark

- (void)dealloc
{
    [adviceRecord release];
    [indexPathInTableView release];
    
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
                              [NSURL URLWithString: adviceRecord.imageURLString]] delegate:self];
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
    
    adviceRecord.image = image;
    
    self.activeDownload = nil;
    [image release];
    self.imageConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    
    [delegate adviceImageDidLoad:adviceIndex];
}

@end

