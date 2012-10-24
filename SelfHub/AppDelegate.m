//
//  AppDelegate.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "Parse/Parse.h"

#import "AppDelegate.h"
#import "DesktopViewController.h"



@implementation AppDelegate

@synthesize window = _window;
@synthesize loginViewController = _loginViewController;
@synthesize desktopViewController = _desktopViewController;
@synthesize activeModuleViewController = _activeModuleViewController;

- (void)dealloc
{
    [_window release];
    [_desktopViewController release];
    [_activeModuleViewController release];
    [_loginViewController release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    //[PFUser logOut];
    //[[PFFacebookUtils facebook] logout];
    // for Parse auth and work
    [Parse setApplicationId:@"yFh0bR03c6FU0BeMXCnvYV9VBqnNdtXnJHYCqaBf"
                  clientKey:@"NQH36DWJbeEkLsD4pR34i4E41zkSZIEUZbpzWk5h"];
    [PFFacebookUtils initializeWithApplicationId:@"194719267323461"];
    [PFTwitterUtils initializeWithConsumerKey:@"TPiDSjG6apnCobDwWyzc6g" consumerSecret:@"2Ojl1ZlREr72MUGncV2hVrOGlLsLvKkgpPv4w2qw440"];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    
  if (![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] && ![[PFFacebookUtils facebook] isSessionValid] && ![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) { // No user logged in
        self.loginViewController.applicationDelegate = self;
        self.window.rootViewController = self.loginViewController;
        [self.window makeKeyAndVisible];
  } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.desktopViewController = [[[DesktopViewController alloc] initWithNibName:@"DesktopViewController_iPhone" bundle:nil] autorelease];
        } else {
            self.desktopViewController = [[[DesktopViewController alloc] initWithNibName:@"DesktopViewController_iPad" bundle:nil] autorelease];
        }
        self.desktopViewController.applicationDelegate = self;
        [self.desktopViewController initialize];
        self.activeModuleViewController =[self.desktopViewController getMainModuleViewController];
        self.window.rootViewController = self.activeModuleViewController;
        [self.window makeKeyAndVisible];
   }
    
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    [UAirship takeOff:takeOffOptions];
    
    [[UAPush shared] resetBadge];
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |    UIRemoteNotificationTypeAlert)];
    return YES;
}


// start ---------- func for work with Parse framework
//Facebook oauth callback
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
} 
// pre 4.2
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    //  [PFPush storeDeviceToken:newDeviceToken];                                                             //  раcкоментить если нужна будет нотификация в PARSE
    //  [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)]; //  раcкоментить если нужна будет нотификация в PARSE
    
    [[UAPush shared] registerDeviceToken:newDeviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	if ([error code] != 3010) // 3010 is for the iPhone Simulator
    {
        NSLog(@"Error connect FB"); // show some alert or otherwise handle the failure to register.
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // [PFPush handlePush:userInfo]; //  раcкоментить если нужна будет нотификация в PARSE
    
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    [[UAPush shared] handleNotification:userInfo applicationState:appState];
    [[UAPush shared] resetBadge];
}

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}
// end----------- Parse framework


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    */
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    // Although the SDK attempts to refresh its access tokens when it makes API calls,
    // it's a good practice to refresh the access token also when the app becomes active.
    // This gives apps that seldom make api calls a higher chance of having a non expired
    // access token.
    [[PFFacebookUtils facebook] extendAccessTokenIfNeeded];
     [[UAPush shared] resetBadge];
//    (BOOL)extendAccessTokenIfNeededForUser:(PFUser *)user target:(id)target selector:(SEL)selector
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [UAirship land];
}

- (void)updateMenuSliderImage{
    CGSize viewSize = self.activeModuleViewController.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 2.0);
    [self.activeModuleViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // correcting current screenshot (if supported by current module)
    // it's neccessary when module uses OpenGL-subviews (for example)
    if([self.activeModuleViewController canPerformAction:@selector(correctScreenshot:) withSender:self.activeModuleViewController]){
        image = [self.activeModuleViewController performSelector:@selector(correctScreenshot:) withObject:image];
    };
    
    
    self.desktopViewController.screenshotImage.image = image;
};

- (void)showSlideMenu{
    [self updateMenuSliderImage];
    
    self.window.rootViewController = self.desktopViewController;
};

- (void)hideSlideMenu{
    self.window.rootViewController = self.activeModuleViewController;
};

- (void)performSuccessLogin{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.desktopViewController = [[[DesktopViewController alloc] initWithNibName:@"DesktopViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.desktopViewController = [[[DesktopViewController alloc] initWithNibName:@"DesktopViewController_iPad" bundle:nil] autorelease];
    }
    self.desktopViewController.applicationDelegate = self;
    [self.desktopViewController initialize];
    self.activeModuleViewController = [self.desktopViewController getMainModuleViewController];
   // [self.window.rootViewController presentViewController:self.activeModuleViewController animated:YES completion:^(void){}];
    self.window.rootViewController = self.activeModuleViewController;
};

- (void)performLogoutTwitter{
   // TODO: error handling
    NSURL *logoutTwitterUrl = [NSURL URLWithString:@"https://api.twitter.com/1/account/end_session.json"];
    NSMutableURLRequest *requestLogoutTwitter = [NSMutableURLRequest requestWithURL:logoutTwitterUrl];

    
    [requestLogoutTwitter setHTTPMethod:@"POST"];
    [[PFTwitterUtils twitter] signRequest:requestLogoutTwitter];
    NSURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:requestLogoutTwitter
                                         returningResponse:&response
                                                     error:&error];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"twitter"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    } 
}


- (void)performLogout{
    [[PFFacebookUtils facebook] logout];
    [self performLogoutTwitter];
    [PFUser logOut];
    self.loginViewController.applicationDelegate = self;
    self.activeModuleViewController = self.loginViewController;
    self.loginViewController.logInView.passwordField.text = @"";
    self.window.rootViewController = self.loginViewController;
    [self.window makeKeyAndVisible];
};

@end
