//
//  oamViewController.h
//  OAMLogin
//
//  Created by Chandra Shirashyad on 9/12/14.
//  Copyright (c) 2014 Chandra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDMMobileSDK.h"

@interface oamViewController : UIViewController <OMMobileServiceDelegate>
{
	bool isAuthenticated;
    OMMobileSecurityService *_mobileServices;
    NSString *username;
}

@property (strong, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UIButton *authenticatedSegue;
@property (nonatomic,assign) bool isAuthenticated;
@property (nonatomic,retain) OMMobileSecurityService *mobileServices;

@end
