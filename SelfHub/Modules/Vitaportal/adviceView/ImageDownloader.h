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

//@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject

@property (nonatomic, retain) Advice *delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
//@property (nonatomic, retain) NSNumber *adviceIndex;
@property (nonatomic) BOOL isLoading;

- (void)startDownload;
- (void)cancelDownload;

@end

/*
@protocol ImageDownloaderDelegate

//- (void)adviceImageDidLoad:(NSNumber *)index;

@end
*/