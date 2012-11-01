//
//  AgrmAndAuthViewController.m
//  SelfHub
//
//  Created by Igor Barinov on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AuthView.h"

@interface AuthView ()

@end

@implementation AuthView

@synthesize activity;
@synthesize delegate;
@synthesize registrView, registrLabel, emailField, sendButton;
@synthesize mainauthView, authView;
@synthesize authLabel, loginField, passwordField;
@synthesize signinButton, registrButton, exitButton, exitAuthButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fillAllFieldsLocalized];
    authView.layer.cornerRadius = 10.0;
   
    registrView.layer.cornerRadius = 10.0;
    [mainauthView addSubview:registrView];
    [registrView setFrame:CGRectMake(5.0, 6.0, 310.0, 404.0)];
    [authView setHidden:false];
    [registrView setHidden:true];
}

- (void)viewDidUnload
{
    delegate = nil;
    [self setAuthView:nil];
    [self setAuthLabel:nil];
    [self setLoginField:nil];
    [self setPasswordField:nil];
    [self setSigninButton:nil];
    [self setRegistrButton:nil];
    [self setExitButton:nil];
    [self setRegistrView:nil];
    [self setEmailField:nil];
    [self setSendButton:nil];
    [self setRegistrLabel:nil];
    [self setMainauthView:nil];
    [self setActivity:nil];
    [super viewDidUnload];
}

- (void) fillAllFieldsLocalized {
    [activity setHidden: true];
    authLabel.text = NSLocalizedString(@"Auth", @"");
    loginField.placeholder = NSLocalizedString(@"Login", @"");
    passwordField.placeholder =  NSLocalizedString(@"Password", @"");
    registrLabel.text = NSLocalizedString(@"Registration", @"");
    
}

- (IBAction)hideKeyboard:(id)sender{
    [sender resignFirstResponder]; 
}

- (IBAction)backgroundTouched:(id)sender
{
    [self.loginField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
}

- (IBAction)forgotPassPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.vitaportal.ru"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [authView release];
    [authLabel release];
    [loginField release];
    [passwordField release];
    [signinButton release];
    [registrButton release];
    [exitButton release];
    [registrView release];
    [emailField release];
    [sendButton release];
    [registrLabel release];
    [mainauthView release];
    [activity release];
    [super dealloc];
}

- (IBAction)registrButtonClick:(id)sender {
    //[registrView setHidden:NO];
   // [authView setHidden:YES];
    UIButton *button = [[[UIButton alloc] init]autorelease];
    button.tag = 1;
    [delegate selectScreenFromMenu:(id)button];
    delegate.agreement = @"1";
}

- (IBAction)backToAuthButtonClick:(id)sender {
    [registrView setHidden:YES];
    [authView setHidden:NO];
    
}

- (IBAction)exitButtonClick:(id)sender
{
    UIButton *button = [[[UIButton alloc] init]autorelease];
    button.tag = 2;
    [delegate selectScreenFromMenu:(id)button];
    delegate.agreement = @"1";
    
}

- (BOOL) checkCorrFillField:(NSString *)str : (NSString *)regExpr {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExpr
                                                                           options:NSRegularExpressionSearch 
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:str options:NSRegularExpressionCaseInsensitive 
                                        range:NSMakeRange(0, str.length)]; 
    
    NSLog(@"match loc: %d", matches.count);
    
    if (error) {
        NSLog(@"%@", error);
        return NO;
    } else {    
        return (matches.count==0)? YES : NO;
    }    
}

- (IBAction)signinButtonClick:(id)sender {
    [self hideKeyboard:passwordField];
    [self hideKeyboard:loginField];
    if (![loginField.text isEqualToString:@""] && ![passwordField.text isEqualToString:@""]/* &&![self checkCorrFillField:emailField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"]*/){//TODO: раскоментировать
        
        [activity setHidden: false];
        [activity startAnimating];
        
    
    // Считаем кеш MDM5 от пароля // start////
        const char *cstr = [passwordField.text UTF8String];
        unsigned char result[16];
        CC_MD5(cstr, strlen(cstr), result);
        
        NSString *passMD5 = [NSString stringWithFormat:
                            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                            result[0], result[1], result[2], result[3],
                            result[4], result[5], result[6], result[7],
                            result[8], result[9], result[10], result[11],
                            result[12], result[13], result[14], result[15]
                            ];
    //////// end /////////
        
        NSString *urlReg =[NSString stringWithFormat:@"http://vitaportal.ru/services/iphone/login?mail=%@&pass=%@",loginField.text,passMD5];
        NSLog(urlReg);
        
        ///////////////////////////
        
        NSURL *signinrUrl = [NSURL URLWithString: urlReg /*@"http://vitaportal.ru/services/iphone/login?"*/];
        id	context = nil;
        NSMutableURLRequest *requestSigninMedarhiv = [NSMutableURLRequest requestWithURL:signinrUrl  cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        
       // TODO: change request
        [requestSigninMedarhiv setHTTPMethod:@"POST"];
        //[requestSigninMedarhiv setHTTPBody:[[NSString stringWithFormat:@"mail=%@&pass=%@", loginField.text,passMD5] dataUsingEncoding: NSWindowsCP1251StringEncoding]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                             action:@selector(handleResultOrError:withContext:)
                                                            context:context] autorelease];
        
        NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestSigninMedarhiv delegate:network];
        
        [conn start]; 
    }
    else
    {
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];   
    }        
}

- (IBAction)regsendButtonClick:(id)sender
{
    /*
    UIButton *button = [[[UIButton alloc] init]autorelease];
    button.tag = 1;
    [delegate selectScreenFromMenu:(id)button];
    delegate.agreement = @"0";*/
    [self regEmailSend];
}


- (void)handleResultOrError:(id)resultOrError withContext:(id)context
{
    NSLog(@"resultOrError");
    if ([resultOrError isKindOfClass:[NSError class]])
	{    
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
        [activity stopAnimating]; 
        [activity setHidden:true];
		return; 
	}

    NSLog(@"+");
   
    NSMutableData *data = [resultOrError objectForKey:@"data"  ];
    
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",content );
    
    
    TBXML *xmlRes = [[TBXML alloc] initWithXMLData:data];
    TBXMLElement *rootE = [xmlRes rootXMLElement];
    if (rootE) {
        TBXMLElement *title = [TBXML childElementNamed:@"status" parentElement:rootE];
        
        NSLog(@"Статус ответа : %@",[TBXML textForElement:title] );
        
        if([[TBXML textForElement:title] isEqualToString : @"ok" ] == true){
           TBXMLElement *user_string = [TBXML childElementNamed:@"user_string" parentElement:rootE];
             NSLog(@"user_string = %@",[TBXML textForElement:user_string] );
            if([[TBXML textForElement:user_string]isEqualToString: @""] == true){
            //user_string необходима для начисления балов полльзователлю
            //TODO: дописать открытие следующего окна
            }else{
                //TODO: дописать обработку ошибки
                /* произошла ошибка не пришло user_string пользователя. вероятнее всего сайт глючит попробовать чуть позже */
                [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Wrong username or password. Check the entered data.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];   
            }
        }
        
        if([[TBXML textForElement:title] isEqualToString : @"error" ] == true){
            TBXMLElement *description = [TBXML childElementNamed:@"description" parentElement:rootE];
            NSLog(@"Ошибка --> %@",[TBXML textForElement:description] );
            
             //TODO: дописать обработку ошибки
            
            [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Wrong username or password. Check the entered data.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
            
        }

    }else{
        // ошибка связи
       [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Wrong username or password. Check the entered data.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];   
    }

     NSLog(@"++");

    [activity stopAnimating]; 
    [activity setHidden:true];
}

- (void)regHandleResultOrError:(id)resultOrError withContext:(id)context
{
    if ([resultOrError isKindOfClass:[NSError class]])
	{
        [[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"") message: NSLocalizedString(@"didFailWithError",@"")  delegate:nil cancelButtonTitle: @"Ok" otherButtonTitles: nil]autorelease]show];
        [activity stopAnimating];
        [activity setHidden:true];
		return;
	}
	//NSURLResponse* response = [resultOrError objectForKey:@"response"];
	NSData* data = [resultOrError objectForKey:@"data"];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);
    [str release];
    
    
    // NSError *myError = nil;
    // NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
     //NSLog(@"key: %@", res);
    
        /*
     // TODO: доделать парсинг
     if ([[res objectForKey:@"result"] intValue]==1){
     // TODO: add alert Welcome
         
         delegate.user_fio = [res objectForKey:@"fio"];
     delegate.user_id = [res objectForKey:@"userID"] ;
     delegate.auth = (NSString*)[[res objectForKey:@"result"] stringValue];
     delegate.user_login = loginField.text;
     delegate.user_pass = passwordField.text;
     delegate.agreement = @"0";
     [delegate saveModuleData];
     
     
     // TODO: open AdviceView
     
     }
     else
     {
     [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Wrong username or password. Check the entered data.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
     }
     */
    VitaParse *parser = [[[VitaParse alloc] initWithData:data delegate:self parseElements:[NSArray arrayWithObjects:@"status", @"user_string", @"description", nil] headElement:@"result"] autorelease];
    
    [parser start];
    
    [activity stopAnimating];
    [activity setHidden:true];
}

- (void)regEmailSend
{
    [self hideKeyboard:emailField];
    
    if (![emailField.text isEqualToString:@""] && ![self checkCorrFillField:emailField.text :@"^[-\\w.]+@([A-z0-9][-A-z0-9]+\\.)+[A-z]{2,4}$"] )
    {
        [activity setHidden: false];
        [activity startAnimating];
        
        NSURL *signinrUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://vitaportal.ru/services/iphone/register?mail=%@", emailField.text]];
        id	context = nil;
        NSMutableURLRequest *requestSigninMedarhiv = [NSMutableURLRequest requestWithURL:signinrUrl
                                                                             cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                                         timeoutInterval:30.0];
        
        // TODO: change request
        // [requestSigninMedarhiv setHTTPMethod:@"POST"];
        // [requestSigninMedarhiv setHTTPBody:[[NSString stringWithFormat:@"cmd=srv&action=auth&email=%@&pass=%@", usernameField.text, passwordField.text] dataUsingEncoding:NSWindowsCP1251StringEncoding]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        Htppnetwork *network = [[[Htppnetwork alloc] initWithTarget:self
                                                             action:@selector(regHandleResultOrError:withContext:)
                                                            context:context] autorelease];
        
        NSURLConnection* conn = [NSURLConnection connectionWithRequest:requestSigninMedarhiv delegate:network];
        [conn start];
    } else{
        
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information",@"") message:NSLocalizedString(@"Make sure you fill out all of the information.", @"") delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease] show];
    }

}

- (void)didFinishParsing:(NSMutableDictionary *)appList
{
    NSLog(@"%@", appList);
    if([[appList  objectForKey:@"status"] isEqualToString:@"error"] )
    {
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error",@"") message:NSLocalizedString([appList objectForKey:@"description"], @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
    }
    if([[appList objectForKey:@"status"] isEqualToString:@"ok"])
    {
        delegate.user_string = [appList objectForKey:@"user_string"];
        [[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information",@"") message:NSLocalizedString(@"The password for the Vitaportal sent to the email", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
        [self exitButtonClick:self];
        
    }
}

- (void)parseErrorOccurred:(NSError *)error
{
    NSLog(@"ERROR VITAPARSE");
}
@end
