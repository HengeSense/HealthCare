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
#import "Htppnetwork.h"

# define BASE_HTTP_URL "http://wbsapi.withings.net/"


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
    if(user_publickey) [user_publickey release];
    if(account_password) [account_password release];
    if(account_email) [account_email release];
    [super dealloc];
}

/*
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
            message = @"Unknown error";
    }

	return message;
}
*/

// useGzip should be used only when the answer is large and will benefit from compression
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
		return nil;
	}    
    
    NSDictionary *repr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nserror];
	return repr;
}


#pragma mark -


-(NSString *) getOnce
{
	id repr;
	NSError *nserror = nil;
	NSString *once;
    
	repr = [self getHTMLForURL:@"once?action=get" gzip:NO error:&nserror];
    
    if(repr==nil) return nil;    
	if ([[repr objectForKey:@"status"] intValue]!=0) return nil;
	
    once = (NSString *)[[repr objectForKey:@"body"] objectForKey:@"once"];
	return once;
}


-(NSArray *) getUsersListFromAccount
{    
	id repr;
	NSString *request;
	NSError *nserror = nil;
    int status;
	char  hashResult[33];    
	char *hashed_pwd;
    
	if (account_email == nil || account_password == nil) return nil;
	
	const char *pwd_c = [account_password UTF8String];
	if (pwd_c == NULL) return nil;
    
	NSString *once = [self getOnce];
	if (!once) return nil;
    
    
    CC_MD5((unsigned char*)pwd_c, strlen(pwd_c), (unsigned char*)hashResult);
    hashed_pwd = md5_hash_to_hex(hashResult);
    
	NSString *challenge_to_hash = [NSString stringWithFormat:@"%@:%s:%@", account_email, hashed_pwd, once];
	const char *challenge_c = [challenge_to_hash UTF8String];
    
	CC_MD5(challenge_c, strlen(challenge_c), (unsigned char*)hashResult);
	NSString *hashed_challenge = [NSString stringWithFormat:@"%s", md5_hash_to_hex(hashResult) ];
    
	request = [NSString stringWithFormat:@"account?action=getuserslist&email=%@&hash=%@", account_email, hashed_challenge];
	repr = [self getHTMLForURL:request gzip:NO error:&nserror];
    if(repr==nil){
        return nil; 
    }
    
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){        
        return nil;
	} 
    
    NSArray *users = (NSArray *)[[repr objectForKey:@"body"] objectForKey:@"users"];
    
    if ([users count] < 1){
        return nil; 
    }
    NSMutableArray *parsed_users = [[[NSMutableArray alloc] init] autorelease];
    
	for (int i=0; i < [users count]; i++)
    {
		id user_i_o = [users objectAtIndex:i];
		if (![user_i_o isKindOfClass:[NSDictionary class]]) {
			return nil;
        }
        
		WBSAPIUser *singleUser = [[WBSAPIUser alloc] init];
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
        [singleUser release];
	}
    
	return parsed_users;    
}

-(NSMutableURLRequest*) getUsersListFromAccountAsynch {
    
	NSString *request;
	char  hashResult[33];    
	char *hashed_pwd;
    
	if (account_email == nil || account_password == nil) {
		return nil;
	}
    
	const char *pwd_c = [account_password UTF8String];
	if (pwd_c == NULL) {
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
    
    
    
    request = [NSString stringWithFormat:@"http://wbsapi.withings.net/account?action=getuserslist&email=%@&hash=%@", account_email, hashed_challenge];
    NSURL *signinrUrl = [NSURL URLWithString:request];
    NSMutableURLRequest *requestSignin = [NSMutableURLRequest requestWithURL:signinrUrl
                                                                 cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                             timeoutInterval:30.0];
    return requestSignin;
}


-(WBSAPIUser *) getUserInfo {
    
	if (user_id == 0 || user_publickey == nil) {
        return nil;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"user?action=getbyuserid&userid=%d&publickey=%@", user_id, user_publickey];
	repr = [self getHTMLForURL:request gzip:NO error:&nserror];
    if(repr==nil){
        return nil; 
    }
    
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){        
        return nil;
	} 
    
    NSArray *users = (NSArray *)[[repr objectForKey:@"body"] objectForKey:@"users"];
    if ([users count] < 1){
        return nil;
    }
    
	id user_i_o = [users objectAtIndex:0];
	if (![user_i_o isKindOfClass:[NSDictionary class]]) {
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


-(NSDictionary *) createMeasureWeight: (NSDictionary*) body
{
    NSArray *msgrp = (NSArray *)[[body objectForKey:@"body"] objectForKey:@"measuregrps"];
    if ([msgrp count] < 1){
        return nil;
    }
    id group_o;
    NSMutableDictionary *weihtDictionary = [[[ NSMutableDictionary alloc] init] autorelease];
    NSMutableArray *arrayWeight = [[[NSMutableArray alloc] init] autorelease];
    
    NSEnumerator * enumerator =  [msgrp reverseObjectEnumerator];  
    while (group_o = [enumerator nextObject])
    {
        if (![group_o isKindOfClass:[NSDictionary class]])
            continue;
        NSDictionary *group = (NSDictionary *)group_o;
        
        int category;      
        NSDate *date = nil;
        NSNumber *weight = nil;
        id measure_elt_o;
        NSDictionary *dict;
        
        NSArray *measures = (NSArray *)[group objectForKey:@"measures"];
        if ([measures count] < 1){
            return nil;
        }
        
            
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd 00:00:00 +0000"];
        NSDate *dateForFormater = [NSDate dateWithTimeIntervalSince1970:[[group objectForKey:@"date"] doubleValue]];
       // NSDate *newDateTime = [formatter dateFromString:[formatter stringFromDate:dateForFormater]];
        [formatter release];
        NSTimeInterval time = floor([dateForFormater timeIntervalSinceReferenceDate] / 86400.0) * 86400.0;
        date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
                       
        category = [[group objectForKey:@"category"] intValue];
        NSEnumerator *m_enum =  [measures objectEnumerator];
        
        while (measure_elt_o = [m_enum nextObject])
        {
            if (![measure_elt_o isKindOfClass:[NSDictionary class]])
                continue;
            NSDictionary *measure_elt = (NSDictionary *)measure_elt_o;
            
            int type, value, unit;
            type = [[measure_elt objectForKey:@"type"] intValue];
            value = [[measure_elt objectForKey:@"value"] intValue];
            unit = [[measure_elt objectForKey:@"unit"] intValue];
            
            float fvalue = value * powf (10, unit);
            
            if (type == WS_TYPE_WEIGHT && category == WS_CATEGORY_MEASURE){
                weight = [NSNumber numberWithFloat: [[NSString stringWithFormat:@"%.2f",fvalue] floatValue]];
            }
        }
        
        if((date != nil) && (weight != nil)){
            dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:weight, date, nil] forKeys:[NSArray arrayWithObjects:@"weight", @"date", nil]];
            [arrayWeight addObject:dict];
        }
    }
    
    [weihtDictionary setValue:arrayWeight forKey:@"data"];
    return weihtDictionary;
}

-(NSDictionary *) getUserMeasuresWithCategory:(int)category
{    
    if (user_id == 0 || user_publickey == nil) {
		return nil;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"measure?action=getmeas&userid=%d&publickey=%@&category=%d", user_id, user_publickey, category];
    repr = [self getHTMLForURL:request gzip:YES error:&nserror];
    if(repr==nil){
        return nil; 
    }
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        return nil;
    }    
	return [self createMeasureWeight :repr];
}


-(NSDictionary *) getUserMeasuresWithCategory:(int)category StartDate:(int) startDate AndEndDate:(int) endDate
{    
    if (user_id == 0 || user_publickey == nil) {
		return nil;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"measure?action=getmeas&userid=%d&publickey=%@&category=%d&startdate=%d&enddate=%d", user_id, user_publickey, category, startDate, endDate];
    repr = [self getHTMLForURL:request gzip:YES error:&nserror];
    if(repr==nil){
        return nil; 
    }
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        return nil;
    }
    
	return [self createMeasureWeight :repr];
}

-(NSDictionary*) getNotificationStatus {
    
    if (user_id == 0 || user_publickey == nil) {
		return nil;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    NSDictionary *dict; 
    
    
	request = [NSString stringWithFormat:@"notify?action=get&userid=%d&callbackurl=%@&publickey=%@", user_id, @"http%3A%2F%2Fhealthcare-push.herokuapp.com%2Fpushnotify.php", user_publickey];
    repr = [self getHTMLForURL:request gzip:NO error:&nserror];
    if(repr==nil){
        return nil; 
    }
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){ // && status != 343
        return nil;
    } 
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys: [repr objectForKey:@"status"], @"status", [[repr objectForKey:@"body"] objectForKey:@"expires"], @"date",[[repr objectForKey:@"body"] objectForKey:@"comment"], @"comment",  nil];
	
    return dict;
}

-(NSMutableArray *) getNotificationList
{    
    if (user_id == 0 || user_publickey == nil) {
		return nil;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"notify?action=list&userid=%d&publickey=%@", user_id, user_publickey];
    repr = [self getHTMLForURL:request gzip:NO error:&nserror];
    if(repr==nil){
        return nil; 
    }
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        return nil;
	} 
    NSArray *profiles = (NSArray *)[[repr objectForKey:@"body"] objectForKey:@"profiles"];
    int i;
    NSMutableArray *listOfNot = [[[NSMutableArray alloc] init] autorelease];
    
    for(i = 0; i < [profiles count]; i++)
    {
        NSDictionary *dict;
        NSString *date;

        NSDictionary *prof_elt = (NSDictionary *) [profiles objectAtIndex: i];
        date = (NSString *)[NSDate dateWithTimeIntervalSince1970:[[prof_elt objectForKey:@"expires"] doubleValue]];
        dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:date, [[repr objectForKey:@"body"] objectForKey:@"comment"], nil] forKeys:[NSArray arrayWithObjects:@"date", @"comment", nil]];
        [listOfNot addObject:dict];
	}
    
    return listOfNot;
}


// appli = 0	User related (for the moment, only height and weight)
// appli = 1	Body scale
// appli = 4	Blood pressure monitor
-(BOOL) getNotificationSibscribeWithComment: (NSString*)comment andAppli:(int) appli
{    
    if (user_id == 0 || user_publickey == nil) {
		return NO;
	}
    
	id repr;
    int status;
	NSString *request;
	NSError *nserror = nil;
    
	request = [NSString stringWithFormat:@"notify?action=subscribe&userid=%d&publickey=%@&callbackurl=%@&comment=%@&appli=%d", user_id, user_publickey, @"http%3A%2F%2Fhealthcare-push.herokuapp.com%2Fpushnotify.php", comment, appli];
    repr = [self getHTMLForURL:request gzip:NO error:&nserror];
    if(repr==nil){
        return NO; 
    }
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){
        return NO;
	} else {
        return YES;
    }
}

// appli = 0	User related (for the moment, only height and weight)
// appli = 1	Body scale
// appli = 4	Blood pressure monitor
- (BOOL) getNotificationRevoke: (int) appli
{    
    if (user_id == 0 || user_publickey == nil) {
		return NO;
	}
    
	id repr;
	NSString *request;
	NSError *nserror = nil;
    int status;
    
	request = [NSString stringWithFormat:@"notify?action=revoke&userid=%d&publickey=%@&callbackurl=%@&appli=%d", user_id, user_publickey, @"http%3A%2F%2Fhealthcare-push.herokuapp.com%2Fpushnotify.php", appli];
    repr = [self getHTMLForURL:request gzip:NO error:&nserror];
    if(repr==nil){
        return NO; 
    }
    status = [[repr objectForKey:@"status"] intValue];
    if (status != 0){       
        return NO;
    } else{
        return YES;
    }  
}

@end
