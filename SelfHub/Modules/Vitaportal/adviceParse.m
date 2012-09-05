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
}
// парсинг окончен
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    m_done = YES;
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
    m_isItem = [[elementName lowercaseString] isEqualToString:@"description"];
    
    if ( m_isItem ) {
        // если да - создаем строку в которую запишем его значение
        m_item = [NSMutableString new];
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    // если элемент title закончился - добавим строку в результат
    if ( m_isItem ) {
        [m_items addObject:m_item];
        [m_item release];
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // если сейчас получаем значение элемента title
    // добавим часть его значения к строке
    if ( m_isItem ) {
        [m_item appendString:string];
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
