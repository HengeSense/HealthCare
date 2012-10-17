
//
//  WBSAPIUser.h
//  SelfHub
//
//  Created by Elena Trishina on 8/15/12.
//  Copyright (c) 2012 __HintSolutions__. All rights reserved.
//

@interface WBSAPIUser : NSObject {
	int        user_id;
	NSString  *firstname;
	NSString  *lastname;
	NSString  *shortname;
	int        gender;
	int        fatmethod;
	int        birthdate;
	
	// in account / getuserslist
	BOOL      ispublic;
	NSString *publickey;

}

@property (readwrite, nonatomic        ) 	int        user_id;
@property (readwrite, nonatomic, retain) 	NSString  *firstname;
@property (readwrite, nonatomic, retain) 	NSString  *lastname;
@property (readwrite, nonatomic, retain) 	NSString  *shortname;
@property (readwrite, nonatomic        )	int        gender;
@property (readwrite, nonatomic        ) 	int        fatmethod;
@property (readwrite, nonatomic        ) 	int        birthdate;

@property (readwrite, nonatomic        ) 	BOOL       ispublic;
@property (readwrite, nonatomic, retain) 	NSString  *publickey;


@end

