//
//  Advice.h
//  SelfHub
//
//  Created by Anton on 14.09.12.
//
//

#import <Foundation/Foundation.h>
#import "AdviceView.h"
#import "ImageDownloader.h"

@class AdviceView;
@class ImageDownloader;
@interface Advice : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSMutableString *description;
@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, retain) NSString *adviceURLString;
@property (nonatomic, retain) NSString *m_id;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) ImageDownloader *downloader;

@property (assign) AdviceView *main;
@property (assign) AdviceView *favorite;

- (void)startDownloadImage;
- (void)adviceImageDidLoad:(UIImage *)image;
- (void)startAnimationDownloadImage;
- (void)stopAnimationDownloadImage;
- (void)stopDownloadImage;

@end
