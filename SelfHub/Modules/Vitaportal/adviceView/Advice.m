//
//  Advice.m
//  SelfHub
//
//  Created by Anton on 14.09.12.
//
//


#import "Advice.h"

@implementation Advice

@synthesize title;
@synthesize image;
@synthesize imageURLString;
@synthesize description;
@synthesize adviceURLString;
@synthesize main, favorite;
@synthesize downloader, m_id, type;

- (void)dealloc
{
    main = nil;
    favorite = nil;
    [title release];
    [image release];
    [imageURLString release];
    [description release];
    [adviceURLString release];
    [downloader release];
    if(downloader) [downloader release];
    [m_id release];
    [type release];
    
    [super dealloc];
}

- (void)startDownloadImage
{
    downloader = [[ImageDownloader alloc] init];
    downloader.delegate = self;
    [downloader startDownload];
    [self startAnimationDownloadImage];
}

- (void)stopDownloadImage
{
    [downloader cancelDownload];
    [self.main.loading stopAnimating];
    self.main.loading = nil;
    
    [self.favorite.loading stopAnimating];
    self.favorite.loading = nil;
}

- (void)adviceImageDidLoad:(UIImage *)img
{
    self.image = img;
    self.main.iview.backgroundColor = [UIColor clearColor];
    self.main.iview.image = img;
    [self.main.loading stopAnimating];
    [self.main.loading removeFromSuperview];
    self.main.loading = nil;
    if(self.favorite != nil)
    {
        self.favorite.iview.backgroundColor = [UIColor clearColor];
        self.favorite.iview.image = img;
        [self.favorite.loading stopAnimating];
        [self.favorite.loading removeFromSuperview];
        self.favorite.loading = nil;
    }
    
}

- (void)startAnimationDownloadImage
{
    if(main.loading == nil)
        [main startLoadingAnimation];
    if(favorite != nil)
        [favorite startLoadingAnimation];
}

- (void)stopAnimationDownloadImage
{    
    [self.main.loading stopAnimating];
    [self.main.loading removeFromSuperview];
    self.main.loading = nil;
    if(self.favorite != nil)
    {
        [self.favorite.loading stopAnimating];
        [self.favorite.loading removeFromSuperview];
        self.favorite.loading = nil;
    }
}
@end
