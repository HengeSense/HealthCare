//
//  VitaSendUseful.m
//  SelfHub
//
//  Created by Bubnov I on 15.11.12.
//
//

#import "VitaSendUseful.h"

@implementation VitaSendUseful

@synthesize advice_id;
@synthesize user_string;

- (id)initWithAdvice_id:(NSString *)advice User_string:(NSString *)user
{
    self = [super init];
    if (self != nil)
    {
        self.advice_id = advice;
        self.user_string = user;
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clickedButtonAtIndex");
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            NSLog(@"закрытие");
            //http://vitaportal.ru/myprofile/vitaindex http://vitaportal.ru/myprofile/vitaindex/form
           // NSString *str = [@"http://vitaportal.ru/myprofile/vitaindex/form" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: str ]];
        }
        if (buttonIndex == 1) {
            //http://vitaportal.ru/myprofile/vitaindex http://vitaportal.ru/myprofile/vitaindex/form
            NSString *str = [@"http://vitaportal.ru/myprofile/vitaindex/form" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: str ]];
        }
    }
}

- (void)sendToVitaportalUsefulMessage{// //Отправляет запрос ВОЗМОЖНО ЛИ пополнить балы для этого пользователя, если можно то потом отправится и запрос о пополнении балов.
    
    NSLog(@"advice_id = %@",self.advice_id);
    NSLog(@"delegate.user_string = %@",self.user_string);
    if(![self.user_string isEqualToString: @""] || true){ //TODO//убрать true
        
        NSURL *signinrUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://vitaportal.ru/services/iphone/advices/index/check?advice_id=%@&user_string=%@",self.advice_id,self.user_string]]; // Посылаем запрос проверки, а можно ли начислить балы
        id	context = nil;
        NSMutableURLRequest *requestVitaPortal = [NSMutableURLRequest requestWithURL:signinrUrl cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                             action:@selector(VitaSendregUsefulResultOrError:withContext:)
                                                            context:context] autorelease];
        
        NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestVitaPortal delegate:network];
        [conn start];
        
        
    }else{
        
        NSLog(@"Упс произошло невозможное");
    }
}

- (void)VitaSendregUsefulResultOrError:(id)resultOrError withContext:(id)context {//обработка ответа запрос возможности пополнить балы для этого пользователя,
    
    NSLog(@"VitaSendregUsefulResultOrError");
    if ([resultOrError isKindOfClass:[NSError class]])
	{
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];

	}
    
    NSMutableData *data = [resultOrError objectForKey:@"data"  ];
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",content );
    
    
    TBXML *xmlRes = [[TBXML alloc] initWithXMLData:data];
    TBXMLElement *rootE = [xmlRes rootXMLElement];
    if (rootE) {
        TBXMLElement *title = [TBXML childElementNamed:@"status" parentElement:rootE];
        
        //NSLog(@"Статус ответа : %@",[TBXML textForElement:title] );
        
        if([[TBXML textForElement:title] isEqualToString : @"complete" ] == true){
            TBXMLElement *description = [TBXML childElementNamed:@"description" parentElement:rootE];
           // NSLog(@"status: complete - %@",[TBXML textForElement:description] );
        }

        if([[TBXML textForElement:title] isEqualToString : @"error" ] == true){
            TBXMLElement *description = [TBXML childElementNamed:@"description" parentElement:rootE];
            NSLog(@"status: error - %@",[TBXML textForElement:description] );
            
            if([[TBXML textForElement:description] isEqualToString:@"User isn't using VitaIndex"]){
                
                UIAlertView *complexAlert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Для  получения баллов необходимо заполнить анкету участника программы ВитаИндекс на сайте."delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"На сайт",nil];
                complexAlert.tag = 1;
                [complexAlert show];
                [complexAlert autorelease];
                
            }
        }
        
        if([[TBXML textForElement:title] isEqualToString : @"ok" ] == true){
            [self sendToVitaportalUsefulMessageFinal];
        }
        
    }else{
        
    }
    
}

- (void)sendToVitaportalUsefulMessageFinal{// //Отправляет запрос о пополнении балов.
    NSLog(@"sendToVitaportalUsefulMessageFinal");
    NSLog(@"advice_id = %@",self.advice_id);
    NSLog(@"delegate.user_string = %@",self.user_string);
    if(![self.user_string isEqualToString: @""] || true){ //TODO//убрать true
        
        NSURL *signinrUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://vitaportal.ru/services/iphone/advices/index?advice_id=%@user_string=%@",self.advice_id,self.user_string]]; // Посылаем запрос начисления балов
        id	context = nil;
        NSMutableURLRequest *requestVitaPortal = [NSMutableURLRequest requestWithURL:signinrUrl cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self action:@selector(VitaSendregFinalUsefulResultOrError:withContext:) context:context] autorelease];
        
        NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestVitaPortal delegate:network];
        [conn start];
        
        
    }else{
        
        NSLog(@"Упс произошло невозможное");
    }
}

- (void)VitaSendregFinalUsefulResultOrError:(id)resultOrError withContext:(id)context {//обработка ответа запрос возможности пополнить балы для этого пользователя,
    
    NSLog(@"VitaSendregFinalUsefulResultOrError");
    if ([resultOrError isKindOfClass:[NSError class]])
	{
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
		
	}
	//NSURLResponse* response = [resultOrError objectForKey:@"response"];
	
    NSMutableData *data = [resultOrError objectForKey:@"data"  ];
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",content );
    
    
    TBXML *xmlRes = [[TBXML alloc] initWithXMLData:data];
    TBXMLElement *rootE = [xmlRes rootXMLElement];
    if (rootE) {
        TBXMLElement *title = [TBXML childElementNamed:@"status" parentElement:rootE];
        
        NSLog(@"Статус ответа : %@",[TBXML textForElement:title] );
        
        if([[TBXML textForElement:title] isEqualToString : @"error" ] == true){
            TBXMLElement *description = [TBXML childElementNamed:@"description" parentElement:rootE];
            NSLog(@"status: error - %@",[TBXML textForElement:description] );
            
            if([[TBXML textForElement:description] isEqualToString:@"User isn't using VitaIndex"]){
                
                UIAlertView *complexAlert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Для  баллов необходимо заполнить анкету участника программы ВитаИндекс на сайте."delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"На сайт",nil];
                complexAlert.tag = 1;
                [complexAlert show];
                [complexAlert release];
                
            }
            
        }
        
        if([[TBXML textForElement:title] isEqualToString : @"ok" ] == true){
            // балы начислены
            NSLog(@"была начислены все хорошо");
        }
        
    }else{
        
    }
    

}


@end
