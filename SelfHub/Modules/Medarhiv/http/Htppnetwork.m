//
//  Htppnetwork.m
//  SelfHub
//
//  Created by Elena Trishina on 7/11/12.
//  Copyright (c) 2012 __HintSolutions__. All rights reserved.
//

#import "Htppnetwork.h"

@interface Htppnetwork()
    @property (nonatomic, retain) NSURLResponse* response;
    @property (nonatomic, retain) NSMutableData* receivedData;

@end

@implementation Htppnetwork

@synthesize receivedData;
@synthesize response;

//

- (id)init
{
	return [self initWithTarget:nil action:(SEL)0 context:nil];
}

- (id)initWithTarget:(id)a_target action:(SEL)a_action context:(id)a_context
{
	if (self = [super init])
	{
		target	= [a_target retain];
		action	= a_action;
		context	= [a_context retain];
	}
	return self;
}


#pragma mark NSURLConnection methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aresponse{
    [self.receivedData setLength:0]; 
    self.response = aresponse;
	self.receivedData = [NSMutableData data];
}



-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
   [self.receivedData appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	
    [target performSelector:action withObject:error withObject:context];
    
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
 
    [target performSelector:action
				 withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.response,@"response",self.receivedData,@"data",nil]
				 withObject:context];
}

- (void)dealloc
{
	[response release];
	[receivedData release];
    [target release];
	[context release];
	[super dealloc];
}

@end
