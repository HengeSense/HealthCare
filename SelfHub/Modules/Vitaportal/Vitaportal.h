//
//  VitaportalViewController.h
//  SelfHub
//
//  Created by Igor Barinov on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleHelper.h"
#import "Htppnetwork.h"
#import "adviceParse.h"
#import <QuartzCore/QuartzCore.h>

@interface Vitaportal : UIViewController <ModuleProtocol>{
   
    NSArray *viewControllers;
    NSString *user_fio;
    NSString *user_id;
    NSString *auth;
    NSString *user_login;
    NSString *user_pass;
    NSMutableDictionary *moduleData;
}

@property (nonatomic, assign) id <ServerProtocol> delegate;
@property (retain, nonatomic) IBOutlet UIView *moduleView;
@property (retain, nonatomic) IBOutlet UIView *mainView;

@property (nonatomic, retain) NSString *user_fio;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *auth;
@property (nonatomic, retain) NSString *user_login;
@property (nonatomic, retain) NSString *user_pass;


@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property (retain, nonatomic) IBOutlet UIView *slideView;
@property (retain, nonatomic) IBOutlet UIImageView *slideImageView;


@end
