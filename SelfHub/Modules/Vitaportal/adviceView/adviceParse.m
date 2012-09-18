
#import "AdviceParse.h"
#import "Advice.h"

@implementation AdviceParse

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
        self.elementsToParse = [NSArray arrayWithObjects:@"title", @"type", @"id", @"p", @"image", nil];
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
            NSString *trimmedString;
            
            if (![elementName isEqualToString:@"p"])
            {
                trimmedString = [workingPropertyString stringByTrimmingCharactersInSet:
                                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [workingPropertyString setString:@""];
            }
            
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
            else if ([elementName isEqualToString:@"p"])
            {
                if(self.workingEntry.description == nil)
                {
                    self.workingEntry.description = [[NSMutableString alloc] init];
                }
                
                NSMutableString *tmp = [workingPropertyString mutableCopy];
                [self.workingEntry.description appendString:tmp];
                [workingPropertyString setString:@""];
                [tmp release];
            }
            else if ([elementName isEqualToString:@"type"])
            {
                self.workingEntry.type = trimmedString;
            }
        }
        if ([elementName isEqualToString:@"advice"])
        {
            self.workingEntry.description =[[self.workingEntry.description stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
            while (true)
            {
                NSRange range = [self.workingEntry.description rangeOfString:@"\n\t"];
                if(range.location == NSNotFound)
                    break;
                [self.workingEntry.description deleteCharactersInRange:range];
            }

            [self.workingArray addObject:self.workingEntry];
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
/*
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"Did End Document xml");
    [self.delegate didFinishParsing:self.workingArray];
    NSLog(@"%@", workingArray);
    
}
*/
@end
