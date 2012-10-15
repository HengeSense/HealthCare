//
//  WorkWithWithings.h
//  SelfHub
//
//  Created by Elena Trishina on 8/15/12.
//  Copyright (c) 2012 __Hintsolutions__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Htppnetwork.h"
#import "WBSAPIUser.h"

#define WS_CATEGORY_MEASURE 1
#define WS_CATEGORY_TARGET  2

#define WS_TYPE_WEIGHT 1
#define WS_TYPE_HEIGHT   4 
#define WS_TYPE_FATFREE_MASS 5
#define WS_TYPE_FAT_RATIO  6
#define WS_TYPE_FAT_MASS_WEIGHT 8
#define WS_TYPE_DIASTOLIC_BLOOD_PRESSURE 9
#define WS_TYPE_SYSTOLIC_BLOOD_PRESSURE 10
#define WS_TYPE_HEART_PULSE 11


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
-(NSDictionary *) getUserMeasuresWithCategory:(int)category StartDate:(NSTimeInterval) startDate AndEndDate:(NSTimeInterval) endDate;

@end

