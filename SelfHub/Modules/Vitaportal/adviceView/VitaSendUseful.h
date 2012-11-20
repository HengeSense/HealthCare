//
//  VitaSendUseful.h
//  SelfHub
//
//  Created by Bubnov I on 15.11.12.
//
//

#import <Foundation/Foundation.h>
#import "Htppnetwork.h"
#import "TBXML.h"

@interface VitaSendUseful : NSObject

@property (nonatomic, retain) NSString * advice_id;
@property (nonatomic, retain) NSString * user_string;

- (id)initWithAdvice_id:(NSString *)advice User_string:(NSString *)user;
- (void)sendToVitaportalUsefulMessage;
@end
