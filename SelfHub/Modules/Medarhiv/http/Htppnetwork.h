//
//  Htppnetwork.h
//  SelfHub
//
//  Created by Elena Trishina on 7/11/12.
//  Copyright (c) 2012 __HintSolutions__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Htppnetwork : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
 {
     NSURLResponse*	response;
     NSMutableData*	responseData;
     
     id		target;
     SEL    action;
     id		context;
};

- (id)initWithTarget:(id)target action:(SEL)action context:(id)context;

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aresponse;
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;


@end
