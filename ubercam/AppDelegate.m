//
//  AppDelegate.m
//  ubercam
//
//  Created by Daniel Sheng Xu on 2/10/2014.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"RnBJMkZZRYIi5F9RR3xincVjhc8mYaGr9nMksi5a"
                  clientKey:@"00A6wNGLZcD50t7rGShCiqxXW41yEFeSop3Qifpa"];
    //[Parse setApplicationId:@"PSnnHwMJUVf6Eb7SWANLTzr9zrtXDA6Gfrw5izf9"
      //            clientKey:@"ERTMEnoldJGyrCA6nHU8IUmzpD9zWR5KXIratHzo"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    
    PFObject *supermarket = [PFObject objectWithClassName:@"Supermarket"];
    [supermarket setObject:@"apple" forKey:@"fruitItem1"];
    supermarket[@"fruitItem2"] = @"orange";
    [supermarket saveInBackground];
    [self.window makeKeyAndVisible];
    
    [PFFacebookUtils initializeFacebook];
    if (![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self presentLoginControllerAnimated:NO];
    }
    return YES;
}

- (void)presentLoginControllerAnimated:(BOOL)animated {
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
    //[self.window.rootViewController presentViewController:loginNavigationController animated:animated completion:nil];
    ParseLoginViewController *loginViewController = [[ParseLoginViewController alloc] init];
    loginViewController.delegate = self;
    [loginViewController setFields:PFLogInFieldsFacebook];
    [self.window.rootViewController presentViewController:loginViewController animated:animated completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error) {
            // handle result
            [self facebookRequestDidLoad:result];
        }
        else {
            [self showErrorAndLogout];
        }
    }];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    // show error and log out
    [self showErrorAndLogout];
}

- (void)showErrorAndLogout {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login failed" message:@"Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [PFUser logOut];
}

- (void)facebookRequestDidLoad:(id)result {
    PFUser *user = [PFUser currentUser];
    if (user) {
        // update current user with facebook name and id
        NSString *facebookName = result[@"name"];
        user.username = facebookName;
        NSString *facebookId = result[@"id"];
        user[@"facebookId"]=facebookId;
        
        // download user profile picture from facebook
        NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square",facebookId]];
        NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL];
        [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self showErrorAndLogout];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _profilePictureData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.profilePictureData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.profilePictureData.length == 0 || !self.profilePictureData) {
        [self showErrorAndLogout];
    }
    else {
        PFFile *profilePictureFile = [PFFile fileWithData:self.profilePictureData];
        [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!succeeded) {
                [self showErrorAndLogout];
            }
            else {
                PFUser *user = [PFUser currentUser];
                user[@"profilePicture"] = profilePictureFile;
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!succeeded) {
                        [self showErrorAndLogout];
                    }
                    else {
                        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }
        }];
    }
}





























@end
