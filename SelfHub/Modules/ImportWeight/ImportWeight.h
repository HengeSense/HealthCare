//
//  ImportWeight.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 13.11.12.
//
//

#import <UIKit/UIKit.h>

#import "ModuleHelper.h"

@protocol ModuleProtocol;

@interface ImportWeight : UIViewController <ModuleProtocol>{
    
    
}

@property (nonatomic, assign) id <ServerProtocol> delegate;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIView *hostView;

- (IBAction)loadDataFromCVS:(id)sender;

@end
