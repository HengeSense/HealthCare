//
//  adviceParse.m
//  SelfHub
//
//  Created by Igor Barinov on 8/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "adviceParse.h"

@implementation adviceParse
    
@synthesize delegate; 
@synthesize dataToParse;
@synthesize workingArray;
@synthesize workingEntry;
@synthesize workingPropertyString;
@synthesize elementsToParse;
@synthesize storingData;

- (id)initWithData:(NSData *)data delegate:(id <ParseDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.elementsToParse = [NSArray arrayWithObjects:@"title", @"type", @"id", @"description", @"image", nil];
    }
    return self;
}

- (void)dealloc
{
    [dataToParse release];
    [workingEntry release];
    [workingPropertyString release];
    [workingArray release];
    
    [super dealloc];
}

- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];
    
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        [self.delegate didFinishParsing:self.workingArray];
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
    
    [parser release];
    
	[pool release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"advice"])
	{
        self.workingEntry = [[[Advice alloc] init] autorelease];
    }
    storingData = [elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if (self.workingEntry)
	{
        if (storingData)
        {
            NSString *trimmedString = [workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [workingPropertyString setString:@""];
            if ([elementName isEqualToString:@"id"])
            {
                self.workingEntry.m_id = trimmedString;
            }
            else if ([elementName isEqualToString:@"title"])
            {
                self.workingEntry.title = trimmedString;
            }
            else if ([elementName isEqualToString:@"image"])
            {
                self.workingEntry.imageURLString = trimmedString;
            }
            else if ([elementName isEqualToString:@"description"])
            {
                self.workingEntry.description = trimmedString;
            }
            else if ([elementName isEqualToString:@"type"])
            {
                self.workingEntry.type = trimmedString;
            }
        }
        else if ([elementName isEqualToString:@"advice"])
        {
            NSLog(@"inside");
            [self.workingArray addObject:self.workingEntry];
            
            Advice *adv = [workingArray objectAtIndex:0];
            NSLog(@"%@",adv.title);
            
            self.workingEntry = nil;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (storingData)
    {
        [workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}


//- (void) listOfAdvices:(NSData*)aData{
//    TBXML *tbxml = [TBXML tbxmlWithXMLData:aData];
//    TBXMLElement *root = tbxml.rootXMLElement;
//    if (root) {
//       m_items = [self traverseElement:root];
//    }
//}

//- (NSMutableArray *)traverseElement:(TBXMLElement *)element {
//    
//    NSMutableArray *tmpAdvices = [[NSMutableArray alloc] init];
//    
//    TBXMLElement *adviciesXmlElement = element->firstChild;
//    TBXMLElement *adviceXmlElement;
//    
//    do {        
//        // if the element has child elements, process them
//        if ((adviceXmlElement = adviciesXmlElement->firstChild)) {            
//            NSMutableDictionary *tmpAdvice = [[NSMutableDictionary alloc] init];            
//            do {
//                NSLog(@"key %@", [TBXML elementName:adviceXmlElement]);
//                NSLog(@"elem %@", [TBXML textForElement:adviceXmlElement]);
//               
//                [tmpAdvice setValue:[TBXML textForElement:adviceXmlElement] forKey:[TBXML elementName:adviceXmlElement]];
//                // Obtain next sibling element
//            } while ((adviceXmlElement = adviceXmlElement->nextSibling));
//            
//            [tmpAdvices addObject:tmpAdvice];
//            [tmpAdvice release];
//        }
//        // Obtain next sibling element
//    } while ((adviciesXmlElement = adviciesXmlElement->nextSibling));    
//    return tmpAdvices;
//}

@end
