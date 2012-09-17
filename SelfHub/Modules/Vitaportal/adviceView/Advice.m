//
//  Advice.m
//  SelfHub
//
//  Created by Anton on 14.09.12.
//
//


#import "Advice.h"

@implementation Advice
@synthesize title;
@synthesize image;
@synthesize imageURLString;
@synthesize description;
@synthesize adviceURLString;

- (void)dealloc
{
    [title release];
    [image release];
    [imageURLString release];
    [description release];
    [adviceURLString release];
    
    [super dealloc];
}
@end
