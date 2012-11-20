//
//  VitaParse.h
//  SelfHub
//
//  Created by Anton on 27.09.12.
//
//

#import <Foundation/Foundation.h>

@protocol VitaParseDelegate;

@interface VitaParse : NSObject <NSXMLParserDelegate>

@property (nonatomic, assign) id <VitaParseDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableDictionary *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, retain) NSString *headElement;
@property (nonatomic, assign) BOOL storingData;
@property (nonatomic, retain) NSString *nameParse;
- (id)initWithData:(NSData *)data delegate:(id <VitaParseDelegate>)theDelegate parseElements:(NSArray *)elements headElement:(NSString *)head nameParseData:(NSString *) nameParseData;
- (void)start;

@end

@protocol VitaParseDelegate
- (void)didFinishParsing:(NSMutableDictionary *)appList;
- (void)parseErrorOccurred:(NSError *)error;
@end
