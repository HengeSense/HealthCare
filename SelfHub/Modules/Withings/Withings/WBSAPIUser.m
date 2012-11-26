//
//  WBSAPIUser.m
//  SelfHub
//
//  Created by Elena Trishina on 8/15/12.
//  Copyright (c) 2012 __HintSolutions__. All rights reserved.
//

#import "WBSAPIUser.h"


@implementation WBSAPIUser


@synthesize  user_id;  
@synthesize  firstname, lastname, shortname;
@synthesize  gender, fatmethod, birthdate;
@synthesize  ispublic, publickey;

-(WBSAPIUser *) init
{
	self = [super init];
	if (!self)
		return nil;
    
	return self;
}

-(void) dealloc
{
	self.firstname = nil;
	self.lastname  = nil;
	self.shortname  = nil;
	self.publickey = nil;
	[super dealloc];
}

@end
