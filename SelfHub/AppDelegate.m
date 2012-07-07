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
    [PFTwitterUtils initializeWithConsumerKey:@"your_twitter_consumer_key" consumerSecret:@"your_twitter_consumer_secret"];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
  if (![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] && ![[PFFacebookUtils facebook] isSessionValid]) { // No user logged in
        // Override point for customization after application launch.
        
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
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
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
    [PFPush handlePush:userInfo];
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
//    (BOOL)extendAccessTokenIfNeededForUser:(PFUser *)user target:(id)target selector:(SEL)selector
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)updateMenuSliderImage{
    CGSize viewSize = self.activeModuleViewController.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
    [self.activeModuleViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.desktopViewController.slidingImageView.image = image;
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

- (void)performLogout{
    NSLog(@"Insert logout code here. ;) Rollback to login screen.");
    [PFUser logOut];
    self.loginViewController.applicationDelegate = self;
    self.activeModuleViewController = self.loginViewController;
    self.loginViewController.logInView.passwordField.text = @"";
    self.window.rootViewController = self.loginViewController;
    //[self.window.rootViewController presentViewController:self.loginViewController animated:YES completion:^(void){}];
    [self.window makeKeyAndVisible];
};

@end
