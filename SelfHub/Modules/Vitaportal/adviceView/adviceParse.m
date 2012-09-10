//
//  adviceParse.m
//  SelfHub
//
//  Created by Igor Barinov on 8/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "adviceParse.h"

@implementation adviceParse
    
@synthesize done=m_done;
@synthesize items=m_items;
@synthesize error=m_error;

-(void) dealloc {
    [m_error release];
    [m_items release];
    [super dealloc];
}

// документ начал парситься
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    m_done = NO;
    m_items = [NSMutableArray new];
    current = [[NSMutableString alloc] init];
}
// парсинг окончен
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    m_done = YES;
    [current release];
        
}
// если произошла ошибка парсинга
-(void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    m_done = YES;
    m_error = [parseError retain];
}
// если произошла ошибка валидации
-(void) parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    m_done = YES;
    m_error = [validationError retain];
}
// встретили новый элемент
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // проверяем, нашли ли мы элемент "title"
    
    current = [elementName copy];
    
    if([elementName isEqualToString:@"advice"])
    {
        title = [[NSMutableString alloc] init];
        type = [[NSMutableString alloc] init];
        image = [[NSMutableString alloc] init];
        description = [[NSMutableString alloc] init];
        m_id = [[NSMutableString alloc] init];
    }

}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    // если элемент title закончился - добавим строку в результат
    
    if([elementName isEqualToString:@"advice"])
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              title, @"title",
                              type, @"type",
                              m_id, @"id",
                              description, @"decription",
                              image, @"image", nil];
       
        NSRange range = [title rangeOfString:@"\n"];
        range.length = title.length - range.location;
        [title deleteCharactersInRange:range];
        
        range = [type rangeOfString:@"\n"];
        range.length = type.length - range.location;
        [type deleteCharactersInRange:range];
        
        range = [m_id rangeOfString:@"\n"];
        range.length = m_id.length - range.location;
        [m_id deleteCharactersInRange:range];
        
        range = [image rangeOfString:@"\n"];
        if(range.location != NSNotFound)
        {
            range.length = image.length - range.location;
            [image deleteCharactersInRange:range];
        }
        
        NSLog(@"%@", description);
        while (true) 
        {
            range = [description rangeOfString:@"\n\t"];
            if(range.location == NSNotFound)
                break;
            [description deleteCharactersInRange:range];
        }
        range = [description rangeOfString:@"\n\n" options:NSBackwardsSearch];
        range.length = description.length - range.location;
        [description deleteCharactersInRange:range];
        
        NSLog(@"%@", description);
        
        [m_items addObject:dict];
        [dict release];
        
        [type release];
        [image release];
        [m_id release];
        [title release];
        [description release];
        
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // если сейчас получаем значение элемента title
    // добавим часть его значения к строке
    
    if([current isEqualToString:@"title"])
    {
        [title appendString:string];
    }
    if([current isEqualToString:@"type"])
    {
        [type appendString:string];
    }
    if([current isEqualToString:@"id"])
    {
        [m_id appendString:string];
    }
    if([current isEqualToString:@"image"])
    {
        [image appendString:string];
    }
    if([current isEqualToString:@"p"])
    {
        [description appendString:string];
    }
}

//-(void)parseAdviceRecords:(NSData*)aData{
//    TBXML *tbxml = [TBXML tbxmlWithXMLData:aData];
//    TBXMLElement *root = tbxml.rootXMLElement;
//    if (root) {
//        m_items = [NSMutableArray new];
//        TBXMLElement *advice = [TBXML childElementNamed:@"advice" parentElement:root];
//        if (advice) {
//            while (advice) {
//                TBXMLElement *type = [TBXML childElementNamed:@"type" parentElement:advice];
//                TBXMLElement *id = [TBXML childElementNamed:@"id" parentElement:advice];
//                TBXMLElement *title = [TBXML childElementNamed:@"title" parentElement:advice];
//                TBXMLElement *image = [TBXML childElementNamed:@"image" parentElement:advice];
//                TBXMLElement *description = [TBXML childElementNamed:@"description" parentElement:advice];
//                NSDictionary *newsItem = [NSDictionary dictionaryWithObjectsAndKeys:
//                                          [TBXML textForElement:type], @"type",
//                                          [TBXML textForElement:id], @"id",
//                                          [TBXML textForElement:title], @"title",
//                                          [TBXML textForElement:image], @"image",
//                                          [TBXML textForElement:description], @"desc",
//                                          nil];
//                [m_items addObject:newsItem];
//                advice = [TBXML nextSiblingNamed:@"advice" searchFromElement:advice];
//            }
//        }
//    }
//}

- (void) listOfAdvices:(NSData*)aData{
    TBXML *tbxml = [TBXML tbxmlWithXMLData:aData];
    TBXMLElement *root = tbxml.rootXMLElement;
    if (root) {
       m_items = [self traverseElement:root];
    }
}

- (NSMutableArray *)traverseElement:(TBXMLElement *)element {
    
    NSMutableArray *tmpAdvices = [[NSMutableArray alloc] init];
    
    TBXMLElement *adviciesXmlElement = element->firstChild;
    TBXMLElement *adviceXmlElement;
    
    do {        
        // if the element has child elements, process them
        if ((adviceXmlElement = adviciesXmlElement->firstChild)) {            
            NSMutableDictionary *tmpAdvice = [[NSMutableDictionary alloc] init];            
            do {
                NSLog(@"key %@", [TBXML elementName:adviceXmlElement]);
                NSLog(@"elem %@", [TBXML textForElement:adviceXmlElement]);
               
                [tmpAdvice setValue:[TBXML textForElement:adviceXmlElement] forKey:[TBXML elementName:adviceXmlElement]];
                // Obtain next sibling element
            } while ((adviceXmlElement = adviceXmlElement->nextSibling));
            
            [tmpAdvices addObject:tmpAdvice];
            [tmpAdvice release];
        }
        // Obtain next sibling element
    } while ((adviciesXmlElement = adviciesXmlElement->nextSibling));    
    return tmpAdvices;
}

@end
