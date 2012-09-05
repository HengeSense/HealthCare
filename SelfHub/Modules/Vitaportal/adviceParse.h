//
//  adviceParse.h
//  SelfHub
//
//  Created by Igor Barinov on 8/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Htppnetwork.h"
#import "TBXML.h"

@interface adviceParse : NSObject <NSXMLParserDelegate>{
    BOOL m_done;
    BOOL m_isItem;
    NSError* m_error;
    NSMutableArray* m_items;
    NSMutableString* m_item;

}

@property (readonly) BOOL done;
@property (readonly) NSError* error;
@property (readonly) NSArray* items;

//-(void)parseAdviceRecords:(NSData*)aData;
//-(void)traverseElement:(TBXMLElement *)element;
- (void) listOfAdvices:(NSData*)aData;
@end
