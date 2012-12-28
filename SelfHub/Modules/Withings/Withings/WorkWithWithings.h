//
//  WorkWithWithings.h
//  SelfHub
//
//  Created by Elena Trishina on 8/15/12.
//  Copyright (c) 2012 __Hintsolutions__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBSAPIUser.h"
#import "UAPush.h"
#import "UAirship.h"

#define WS_CATEGORY_MEASURE 1
#define WS_TYPE_WEIGHT 1


char *md5_hash_to_hex (char *Bin );

@interface WorkWithWithings : NSObject{
	
    NSString *account_email;
	NSString *account_password;
	int       user_id;
	NSString *user_publickey;
}


@property (nonatomic, readwrite, retain) NSString *account_email;
@property (nonatomic, readwrite, retain) NSString *account_password;
@property (nonatomic, readwrite        ) int       user_id;
@property (nonatomic, readwrite, retain) NSString *user_publickey;


-(NSString *) getOnce;
-(NSArray *) getUsersListFromAccount;
-(WBSAPIUser *) getUserInfo;
-(NSDictionary *) getUserMeasuresWithCategory:(int)category;
-(NSDictionary*) getNotificationStatus;
-(NSMutableArray *) getNotificationList;
-(BOOL) getNotificationSibscribeWithComment: (NSString*)comment andAppli: (int)appli;
-(BOOL) getNotificationRevoke: (int) appli;
-(NSDictionary *) getUserMeasuresWithCategory:(int)category StartDate:(int) startDate AndEndDate:(int) endDate;
-(NSMutableURLRequest*) getUsersListFromAccountAsynch;
@end

