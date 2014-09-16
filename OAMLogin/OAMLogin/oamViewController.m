//
//  oamViewController.m
//  OAMLogin
//
//  Created by Chandra Shirashyad on 9/12/14.
//  Copyright (c) 2014 Chandra. All rights reserved.
//

#import "oamViewController.h"
#import "constants.h"

@interface oamViewController ()

@end

@implementation oamViewController

@synthesize isAuthenticated;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self connectToOICServerAndSetup];
    if(!isAuthenticated)
    {
        self.navigationItem.prompt = nil;
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Login"
                                        style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(doLogin:)];
        [self.navigationItem setRightBarButtonItem:rightButton
                                          animated:YES];
        self.authenticatedSegue.hidden = YES;
    }
    else
    {
        self.navigationItem.prompt = nil;
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Logout"
                                        style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(doLogout:)];
        [self.navigationItem setRightBarButtonItem:rightButton
                                          animated:YES];
        self.authenticatedSegue.hidden = NO;
    }
}

- (IBAction)doLogin:(id)object
{
    [self doLogin];
}

- (void) doLogin
{
    if (self.mobileServices.applicationProfile == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"OAM server settings is not available."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSError *error = nil;
    error = [self.mobileServices startAuthenticationProcess:nil
                                    presenterViewController:self];

}

- (IBAction)doLogout:(id)object
{
    OMAuthenticationContext *ac = [self.mobileServices authenticationContext:TRUE];
    if (ac != nil)
    {
        [self.mobileServices logout:FALSE];
    }
    
    [self didFinishLogout];
}

- (void)didFinishLogout
{
	isAuthenticated = NO;
	self.navigationItem.prompt = nil;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Login"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(doLogin:)];
	[self.navigationItem setRightBarButtonItem:rightButton
                                      animated:YES];
    [self.welcomeLabel setText:[NSString stringWithFormat:@"Welcome Guest"]];
    self.authenticatedSegue.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//OAM Related Stuff
- (void)connectToOICServerAndSetup
{
    self.mobileServices = nil;
    
    NSMutableDictionary *sdkProps = [[NSMutableDictionary alloc] init];
    [sdkProps setObject:OM_PROP_AUTHSERVER_OAMMS forKey:OM_PROP_AUTHSERVER_TYPE];
    [sdkProps setObject:OIC_URL forKey:OM_PROP_OAMMS_URL];
    [sdkProps setObject:OIC_APP_NAME forKey:OM_PROP_APPNAME];
    [sdkProps setObject:OIC_SERVICE_DOMAIN forKey:OM_PROP_OAMMS_SERVICE_DOMAIN];
    
    OMMobileSecurityService *mss = [[OMMobileSecurityService alloc]
                                    initWithProperties:sdkProps
                                    delegate:self];
    self.mobileServices = mss;
    
    UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc]
                                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:av];
    [self.navigationItem setRightBarButtonItem:rightButton];
    [av startAnimating];
    [self.mobileServices setup];
}

- (void)didReceiveApplicationProfile:(NSDictionary *)applicationProfile
                               error:(NSError *)error
{
    NSLog(@"Downloaded application profile: %@", applicationProfile);
    if (error)
    {
        NSString *msg = [[NSString alloc] initWithFormat:@"%@-%d: %@",
                         [error domain], [error code],
                         [error localizedDescription]];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Application Initialization Failed"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Login"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(doLogin:)];
	[self.navigationItem setRightBarButtonItem:rightButton
                                      animated:YES];
}

- (void)didFinishAuthentication:(OMAuthenticationContext *)context
                          error:(NSError *)error
{
    NSLog(@"Got Authenticated: %d: %@",error.code, error.description);
    if (context == nil || error != nil)
    {
        NSString *msg = [[NSString alloc] initWithFormat:@"%@-%d: %@", [error domain],
                         [error code], [error localizedDescription]];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Authentication Status"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    username = context.userName;
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Successfully Authenticated!"
                                                        message:[NSString stringWithFormat:@"Username: %@", username]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    isAuthenticated =YES;
    self.navigationItem.prompt = nil;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Logout"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(doLogout:)];
    [self.navigationItem setRightBarButtonItem:rightButton
                                      animated:YES];
    self.authenticatedSegue.hidden = NO;
    [self.welcomeLabel setText:[NSString stringWithFormat:@"Welcome %@", username]];
    
}

@end
