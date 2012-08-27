//
//  WorkWithWithings.m
//  SelfHub
//
//  Created by Elena Trishina on 8/15/12.
//  Copyright (c) 2012 __Hintsolutions__. All rights reserved.
//
#include <CommonCrypto/CommonDigest.h>
#import "WorkWithWithings.h"
#import <CFNetwork/CFHTTPMessage.h>

# define BASE_HTTP_URL "http://wbsapi.withings.net/"


// TODO : проверка на ошибки

char *md5_hash_to_hex (char *Bin )
{
    unsigned short i;
    unsigned char j;
    static char Hex[33];
    
    for (i = 0; i < 16; i++)
    {
        j = (Bin[i] >> 4) & 0xf;
        if (j <= 9)
            Hex[i * 2] = (j + '0');
        else
            Hex[i * 2] = (j + 'a' - 10);
        j = Bin[i] & 0xf;
        if (j <= 9)
            Hex[i * 2 + 1] = (j + '0');
        else
            Hex[i * 2 + 1] = (j + 'a' - 10);
    };
    Hex[32] = '\0';
    return(Hex);
}


@implementation WorkWithWithings

// not delete
//Your OAuth key is :55096ddc8fcfe873fcd715712fecbd753515822c47f138643bd815c47d737
//Your OAuth secret is :ee9b51dfd165f1fefecc47ee30cde00d1b33f61e152052cfef2752976fc 

@synthesize account_email, account_password;
@synthesize user_id, user_publickey;



-(WorkWithWithings *) init 
{
	self = [super init];
	if (!self)
		return nil;
    
	return self;
}

-(void) dealloc
{
	[super dealloc];
}


-(NSString*) errorsWithingsforHTTP:(int)errorcode
{	 		
    NSString *message;
    switch (errorcode){
        case 2555:
            message = @"An unknown error occured";
            break;
        case 247:
            message = @"The userid is either absent or incorrect";
            break;
        case 250:
            message = @"The provided userid and/or Oauth credentials do not match";
            break;
        case 286:
            message = @"No such subscription was found";
            break;
        case 293:
            message = @"The callback URL is either absent or incorrect"; 
            break;
        case 304:
            message = @"The comment is either absent or incorrect"; 
            break;
        case 305:
            message = @"Too many notifications are already set"; 
            break;
        case 343:
            message = @"No notification matching the criteria was found"; 
            break;
        default:
            message = @"Unknown measure type %d";
    }
    
	return message;
}

// useGzip should be used only when the answer is large and will benefit from compression
// (measures are a good candidate).
-(id)getHTMLForURL:(NSString *)url_req gzip:(BOOL) useGzip error:(NSError **)nserror
{
	NSURL *baseURL = [NSURL URLWithString:@BASE_HTTP_URL];
	NSMutableURLRequest *nsrequest;
	NSURLResponse *nsresponse;
    
	nsrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_req relativeToURL:baseURL]];
	if (useGzip) {
		[nsrequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
		[nsrequest addValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
	} else {
		// gzip-encoding is the default mode of UrlRequest. Have to explicitely disable it.
		[nsrequest setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
	}    
	[nsrequest setTimeoutInterval:30.0f];
    
	
    NSData *data = [NSURLConnection sendSynchronousRequest:nsrequest returningResponse:&nsresponse error:nserror];
	if (data == nil){
		if (nserror)
			NSLog(@"sendSynchronousRequest failed: %@", [*nserror description]);
		else
			NSLog(@"sendSynchronousRequest failed: (NULL error)");
		return nil;
	}    
	    
    NSDictionary *repr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nserror];
	return repr;
	
}


#pragma mark -


-(NSString *) getOnce {
	id repr;
	NSError *nserror = nil;
	NSString *once;
   
	repr = [self getHTMLForURL:@"once?action=get" gzip:NO error:&nserror];
	if ([[repr objectForKey:@"status"] intValue]!=0){
        return nil;
	}
    
    once = (NSString *)[[repr objectForKey:@"body"] objectForKey:@"once"];
    NSLog(@"once ,%@", once);
    
	return once;
}


-(NSArray *) getUsersListFromAccount {
    
	id repr;
	NSString *request;
	NSError *nserror = nil;
    int status;
	char  hashResult[33];    
	char *hashed_pwd;
    
	if (account_email == nil || account_password == nil) {
		NSLog(@"account_email or account_password missing");
		return nil;
	}
    
	const char *pwd_c = [account_password UTF8String];
	if (pwd_c == NULL) {
		NSLog(@"missing password");
		return nil;
	}
     
	NSString *once = [self getOnce];
	if (!once)
		return nil;
    
        
    CC_MD5((unsigned char*)pwd_c, strlen(pwd_c), (unsigned char*)hashResult);
    hashed_pwd = md5_hash_to_hex(hashResult);
    
	NSString *challenge_to_hash = [NSString stringWithFormat:@"%@:%s:%@", account_email, hashed_pwd, once];
	const char *challenge_c = [challenge_to_hash UTF8String];
    
	CC_MD5(challenge_c, strlen(challenge_c), (unsigned char*)hashResult);
	NSString *hashed_challenge = [NSString stringWithFormat:@"%s", md5_hash_to_hex(hashResult) ];
    
	request = [NSString stringWithFormat:@"account?action=getuserslist&email=%@&hash=%@", account_email, hashed_challenge];
	repr = [self getHTMLForURL:request gzip:NO error:&nserror];
  
    // NSLog(@"test list %@", repr);
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[self errorsWithingsforHTTP:status]   delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show]; 
        return nil;
	} 
    
    NSArray *users = (NSArray *)[[repr objectForKey:@"body"] objectForKey:@"users"];
    NSLog(@" %@", users);
    if ([users count] < 1){
        NSLog(@"userslist: 'users' array empty");
        return nil; 
    }
    NSMutableArray *parsed_users = [[[NSMutableArray alloc] init] autorelease];
        
	for (int i=0; i < [users count]; i++){
		id user_i_o = [users objectAtIndex:i];
		if (![user_i_o isKindOfClass:[NSDictionary class]]) {
			NSLog(@"userslist: user #%d not a dict", i);
			return nil;
        }

		WBSAPIUser *singleUser = [[[WBSAPIUser alloc] init] autorelease];
		NSDictionary *user_i = (NSDictionary *)user_i_o;
        
        singleUser.user_id = [[user_i objectForKey:@"id"] intValue];
        singleUser.firstname = [user_i objectForKey:@"firstname"];
        singleUser.lastname = [user_i objectForKey:@"lastname"];
        singleUser.shortname = [user_i objectForKey:@"shortname"];
        singleUser.gender = [[user_i objectForKey:@"gender"] intValue];
        singleUser.fatmethod = [[user_i objectForKey:@"fatmethod"] intValue];  
        singleUser.birthdate = [[user_i objectForKey:@"birthdate"] intValue]; 
        singleUser.ispublic = [[user_i objectForKey:@"ispublic"] boolValue]; 
        singleUser.publickey = [user_i objectForKey:@"publickey"];
      
		[parsed_users addObject:singleUser];
	}
    
	return parsed_users;    
}

-(WBSAPIUser *) getUserInfo {
    
	if (user_id == 0 || user_publickey == nil) {
		NSLog(@"user_id or user_publickey missing");
        return nil;
	}
    
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"user?action=getbyuserid&userid=%d&publickey=%@", user_id, user_publickey];
	repr = [self getHTMLForURL:request gzip:NO error:&nserror];

    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[self errorsWithingsforHTTP:status]   delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show]; 
        return nil;
	} 
        
    NSArray *users = (NSArray *)[[repr objectForKey:@"body"] objectForKey:@"users"];
    NSLog(@" %@", users);
    if ([users count] < 1){
        NSLog(@"userslist: 'users' array empty");
        return nil;
    }

	id user_i_o = [users objectAtIndex:0];
	if (![user_i_o isKindOfClass:[NSDictionary class]]) {
		NSLog(@"getbyuserid: user #0 not a dict");
		return nil;
	}
    
	WBSAPIUser * singleUser = [[[WBSAPIUser alloc] init] autorelease];
	NSDictionary *user_i = (NSDictionary *)user_i_o;
    
    singleUser.user_id = [[user_i objectForKey:@"id"] intValue];
    singleUser.firstname = [user_i objectForKey:@"firstname"];
    singleUser.lastname = [user_i objectForKey:@"lastname"];
    singleUser.shortname = [user_i objectForKey:@"shortname"];
    singleUser.gender = [[user_i objectForKey:@"gender"] intValue];
    singleUser.fatmethod = [[user_i objectForKey:@"fatmethod"] intValue];  
    singleUser.birthdate = [[user_i objectForKey:@"birthdate"] intValue]; 
    singleUser.ispublic = YES;
    singleUser.publickey = user_publickey;
    
    return singleUser;
       
}



#pragma mark -


-(NSDictionary *) createMeasureWeight: (NSDictionary*) body{
    NSArray *msgrp = (NSArray *)[[body objectForKey:@"body"] objectForKey:@"measuregrps"];
    if ([msgrp count] < 1){
        return nil;
    }
    id group_o;
    NSMutableDictionary *weihtDictionary = [[[ NSMutableDictionary alloc] init] autorelease];
    NSMutableArray *arrayWeight = [[[NSMutableArray alloc] init] autorelease];
    
    NSEnumerator * enumerator =  [msgrp reverseObjectEnumerator];  
    while (group_o = [enumerator nextObject]){
        if (![group_o isKindOfClass:[NSDictionary class]])
        			continue;
        NSDictionary *group = (NSDictionary *)group_o;
        
        int category;//, grpid;        
        NSString *date = nil;
        NSString *weight = nil;
        id measure_elt_o;
        NSDictionary *dict;
                
        NSArray *measures = (NSArray *)[group objectForKey:@"measures"];
        if ([measures count] < 1){
            return nil;
        }

        date = (NSString *)[NSDate dateWithTimeIntervalSince1970:[[group objectForKey:@"date"] doubleValue]];
        
        category = [[group objectForKey:@"category"] intValue];
        NSEnumerator *m_enum =  [measures objectEnumerator];
        
        while (measure_elt_o = [m_enum nextObject]) {
            if (![measure_elt_o isKindOfClass:[NSDictionary class]])
                continue;
            NSDictionary *measure_elt = (NSDictionary *)measure_elt_o;
            			
            int type, value, unit;
            type = [[measure_elt objectForKey:@"type"] intValue];
            value = [[measure_elt objectForKey:@"value"] intValue];
            unit = [[measure_elt objectForKey:@"unit"] intValue];
                        
            float fvalue = value * powf (10, unit);
               
            // возможно что-то еще понадобится
            switch (type){
                case WS_TYPE_WEIGHT:
                    if (category == WS_CATEGORY_MEASURE)
                        weight = [NSString stringWithFormat:@"%.2f",fvalue];
                    break;
                default:
                    NSLog(@"Unknown measure type %d", type);
            }
        }
       
        if((date != nil) && (weight != nil)){
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:weight, date, nil] forKeys:[NSArray arrayWithObjects:@"weight", @"date", nil]];
            [arrayWeight addObject:dict];
        }
    }
    
    [weihtDictionary setValue:arrayWeight forKey:@"data"];
     NSLog(@" arrr= %@", weihtDictionary);
    return weihtDictionary;
}

-(NSDictionary *) getUserMeasuresWithCategory:(int)category {

    /// ----- for the test    
    //    user_id = 505228;
    //    user_publickey = @"efbdb30748d1b45d";
    
    if (user_id == 0 || user_publickey == nil) {
		NSLog(@"user_id or user_publickey missing");
		return nil;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"measure?action=getmeas&userid=%d&publickey=%@&category=%d", user_id, user_publickey, category];
    repr = [self getHTMLForURL:request gzip:YES error:&nserror];

    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[self errorsWithingsforHTTP:status]   delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show];
    }
    
    //NSLog(@"resp_mesh %@", repr);
	return [self createMeasureWeight :repr];
}


-(NSDictionary*) getNotificationStatus {
   
/// ----- for the test    
//    user_id = 505228;
//    user_publickey = @"efbdb30748d1b45d";
    
    if (user_id == 0 || user_publickey == nil) {
		NSLog(@"user_id or user_publickey missing");
		return nil;
	}

	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    NSDictionary *dict; 
    NSString *date;
    
	request = [NSString stringWithFormat:@"notify?action=get&userid=%d&publickey=%@&callbackurl=%@", user_id, user_publickey, @"http%3a%2f%2fwww.selfhub.net"];
    repr = [self getHTMLForURL:request gzip:NO error:&nserror];
   
    // NSLog(@"resp_mesh %@", repr);
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[self errorsWithingsforHTTP:status]   delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show];
        return nil;
    } 
    date = (NSString *)[NSDate dateWithTimeIntervalSince1970:[[[repr objectForKey:@"body"] objectForKey:@"expires"] doubleValue]];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"date",[[repr objectForKey:@"body"] objectForKey:@"comment"], @"comment",  nil];
	
    return dict;
}

-(NSMutableArray *) getNotificationList {
    
/// ----- for the test    
//    user_id = 505228;
//    user_publickey = @"efbdb30748d1b45d";
    
    if (user_id == 0 || user_publickey == nil) {
		//NSLog(@"user_id or user_publickey missing");
		return nil;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"notify?action=list&userid=%d&publickey=%@", user_id, user_publickey];
    repr = [self getHTMLForURL:request gzip:NO error:&nserror];
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[self errorsWithingsforHTTP:status]   delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show];
        return nil;
	} 
    NSArray *profiles = (NSArray *)[[repr objectForKey:@"body"] objectForKey:@"profiles"];
    int i;
    NSMutableArray *listOfNot = [[[NSMutableArray alloc] init] autorelease];
    //NSLog(@"resp_mesh %@", repr);
    
    for(i = 0; i < [profiles count]; i++){
        NSDictionary *dict;
        NSString *date;
		
        NSDictionary *prof_elt = (NSDictionary *)[profiles objectAtIndex:i];
        date = (NSString *)[NSDate dateWithTimeIntervalSince1970:[[prof_elt objectForKey:@"expires"] doubleValue]];
        dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:date, [[repr objectForKey:@"body"] objectForKey:@"comment"], nil] forKeys:[NSArray arrayWithObjects:@"date", @"comment", nil]];
        [listOfNot addObject:dict];
	}
    
    return listOfNot;
    
}


// appli = 0	User related (for the moment, only height and weight)
// appli = 1	Body scale
// appli = 4	Blood pressure monitor
-(BOOL) getNotificationSibscribeWithComment: (NSString*)comment andAppli:(int) appli {
    
/// ----- for the test    
//    user_id = 505228;
//    user_publickey = @"efbdb30748d1b45d";
    
    
    if (user_id == 0 || user_publickey == nil) {
		NSLog(@"user_id or user_publickey missing");
		return NO;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"notify?action=subscribe&userid=%d&publickey=%@&callbackurl=%@&comment=%@&appli=%d", user_id, user_publickey, @"http%3a%2f%2fwww.selfhub.net", comment, appli];
    repr = [self getHTMLForURL:request gzip:NO error:&nserror];
   // NSLog(@"resp_mesh %@", repr);
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[self errorsWithingsforHTTP:status]   delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show]; 
        return NO;
	} else {
        return YES;
    }
}

// appli = 0	User related (for the moment, only height and weight)
// appli = 1	Body scale
// appli = 4	Blood pressure monitor
- (BOOL) getNotificationRevoke: (int) appli {
   
/// ----- for the test    
//    user_id = 505228;
//    user_publickey = @"efbdb30748d1b45d";
    
    
    if (user_id == 0 || user_publickey == nil) {
		NSLog(@"user_id or user_publickey missing");
		return NO;
	}
    
	id repr;
	NSString *request;
	NSError *nserror = nil;
    int status;
    
	request = [NSString stringWithFormat:@"notify?action=revoke&userid=%d&publickey=%@&callbackurl=%@&appli=%d", user_id, user_publickey, @"http%3a%2f%2fwww.selfhub.net", appli];
    repr = [self getHTMLForURL:request gzip:NO error:&nserror];
  
    //NSLog(@"resp_mesh %@", repr);
    
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:[self errorsWithingsforHTTP:status]   delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil] autorelease] show]; 
        return NO;
	} else{
        return YES;
    }    
}

@end

//-(NSMutableArray *) allMeasures:(NSDictionary *)body {
//    
//    NSArray *msgrp = (NSArray *)[[body objectForKey:@"body"] objectForKey:@"measuregrps"];
//	
//    //    self.date = [NSDate dateWithTimeIntervalSince1970:
//    //                   [[[body objectForKey:@"body"] objectForKey:@"updatetime"] doubleValue]];
//    
//    id group_o;
//	NSEnumerator * enumerator =  [msgrp reverseObjectEnumerator];  // reverse because the webservice order is most recent first.
//    
//	while ( (group_o = [enumerator nextObject]) ){
//		if (![group_o isKindOfClass:[NSDictionary class]])
//			continue;
//		NSDictionary *group = (NSDictionary *)group_o;
//        
//        
//		int category;        
//        grpid = [[group objectForKey:@"grpid"] intValue]; // check if not old
//        
//        NSArray *measures = (NSArray *)[group objectForKey:@"measures"];
//        
//        self.date = [NSDate dateWithTimeIntervalSince1970:
//                     [[group objectForKey:@"date"] doubleValue]];
//        category = [[group objectForKey:@"category"] intValue];
//        
//		NSEnumerator *m_enum =  [measures objectEnumerator];
//		id measure_elt_o;
//		measure_weight = 0.0f;
//		measure_height = 0.0f;
//		measure_fatMassWeight = 0.0f;
//		measure_fatFreeMass = 0.0f;
//		measure_fatRatio = 0.0f;
//        measure_diastolicBloodPressure = 0.0f;
//        measure_systolicBloodPressure = 0.0f;
//        measure_heartPulse = 0.0f;
//        
//		while ( (measure_elt_o = [m_enum nextObject]) ){
//			if (![measure_elt_o isKindOfClass:[NSDictionary class]])
//				continue;
//			NSDictionary *measure_elt = (NSDictionary *)measure_elt_o;
//			
//            int type, value, unit;
//            type = [[measure_elt objectForKey:@"type"] intValue];
//            value = [[measure_elt objectForKey:@"value"] intValue];
//            unit = [[measure_elt objectForKey:@"unit"] intValue];
//            
//			float fvalue = value * powf (10, unit);
//            
//			switch (type){
//                case WS_TYPE_WEIGHT:
//                    if (category == WS_CATEGORY_MEASURE)
//                        self.measure_weight = fvalue;
//                    else if (category == WS_CATEGORY_TARGET)
//                        self.target_weight = fvalue;
//                    break;
//                case WS_TYPE_HEIGHT:
//                    if (category == WS_CATEGORY_MEASURE)
//                        self.measure_height = fvalue;
//                    break;
//                case WS_TYPE_FATFREE_MASS:
//                    self.measure_fatFreeMass=fvalue;
//                    break;
//                case WS_TYPE_FAT_MASS_WEIGHT:
//                    if (category == WS_CATEGORY_MEASURE)
//                        self.measure_fatMassWeight = fvalue;
//                    else if (category == WS_CATEGORY_TARGET)
//                        self.target_fat = fvalue;
//                    break;
//                case WS_TYPE_FAT_RATIO:
//                    if (category == WS_CATEGORY_MEASURE)
//                        self.measure_fatRatio = fvalue;
//                    break;
//                case WS_TYPE_DIASTOLIC_BLOOD_PRESSURE:
//                    if (category == WS_CATEGORY_MEASURE)
//                        self.measure_diastolicBloodPressure = fvalue;
//                    break;
//                case WS_TYPE_SYSTOLIC_BLOOD_PRESSURE:
//                    if (category == WS_CATEGORY_MEASURE)
//                        self.measure_systolicBloodPressure = fvalue;
//                    break;
//                case WS_TYPE_HEART_PULSE:
//                    if (category == WS_CATEGORY_MEASURE)
//                        self.measure_heartPulse = fvalue;
//                    break;
//                default:
//                    NSLog(@"Unknown measure type %d", type);
//			}
//		}
//        //
//        /*
//         Log all measure in console...
//         
//         NSLog(@"  #%d [%@] : %@ = { W = %.02f kg, H = %.02f m, fat mass = %.02f kg  = %.02f%% , fatfree = %.02f kg }",
//         grpid,
//         [macdate description],
//         (category == WS_CATEGORY_MEASURE ? @"Measure" : @"Target"),
//         weight, height, fat, fatpct, fatfree);
//         */
//        //
//	}
//    
//	
//    return YES;
//}

