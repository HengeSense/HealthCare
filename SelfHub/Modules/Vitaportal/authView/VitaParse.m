//
//  VitaParse.m
//  SelfHub
//
//  Created by Anton on 27.09.12.
//
//

#import "VitaParse.h"

@implementation VitaParse

@synthesize delegate;
@synthesize dataToParse;
@synthesize workingEntry;
@synthesize workingPropertyString;
@synthesize elementsToParse;
@synthesize storingData;
@synthesize headElement;

- (id)initWithData:(NSData *)data delegate:(id<VitaParseDelegate>)theDelegate parseElements:(NSArray *)elements headElement:(NSString *)head
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.elementsToParse = elements;
        self.headElement = head;
    }
    return self;
}

- (void)dealloc
{
    [dataToParse release];
    [workingEntry release];
    [workingPropertyString release];
    [elementsToParse release];
    [headElement release];
    [super dealloc];
}

- (void)start
{	
    self.workingPropertyString = [NSMutableString string];
    
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
    [parser parse];
	
    [parser release];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:headElement])
	{
        self.workingEntry = [[[NSMutableDictionary alloc] init] autorelease];
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
            
            if([elementsToParse containsObject:elementName])
            {
                [self.workingEntry setObject:trimmedString forKey:elementName];
            }
        }
        //else if ([elementName isEqualToString:headElement])
        //{
         //   [self.workingArray addObject:self.workingEntry];
          //  self.workingEntry = nil;
        //}

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


 - (void)parserDidEndDocument:(NSXMLParser *)parser
 {
     NSLog(@"Did End Document xml");
     [self.delegate didFinishParsing:self.workingEntry];
 
 }
 
@end