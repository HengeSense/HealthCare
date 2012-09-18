//
//  AdviceParse.h
//  SelfHub
//
//  Created by Anton on 14.09.12.
//
//

#import <Foundation/Foundation.h>

@class Advice;

@protocol ParseDelegate;

@interface AdviceParse : NSOperation <NSXMLParserDelegate>
{
@private
    id <ParseDelegate> delegate;
    
    NSData          *dataToParse;
    
    NSMutableArray  *workingArray;
    Advice          *workingEntry;
    NSMutableString *workingPropertyString;
    NSArray         *elementsToParse;
    BOOL            storingData;
}

- (id)initWithData:(NSData *)data delegate:(id <ParseDelegate>)theDelegate;

@property (nonatomic, assign) id <ParseDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) Advice *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingData;

@end

@protocol ParseDelegate
- (void)didFinishParsing:(NSArray *)appList;
- (void)parseErrorOccurred:(NSError *)error;
@end
