//
//  ImageDownloader.h
//  SelfHub
//
//  Created by Anton on 14.09.12.
//
//

#import <Foundation/Foundation.h>
#import "Advice.h"

@class Advice;
@class AdviceView;

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject

@property (nonatomic, retain) AdviceView *adviceView;
@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSNumber *adviceIndex;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol ImageDownloaderDelegate

- (void)adviceImageDidLoad:(NSNumber *)index;

@end