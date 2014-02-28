//
//  AppDelegate.h
//  ubercam
//
//  Created by Daniel Sheng Xu on 2/10/2014.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseLoginViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableData *profilePictureData;

- (void)presentLoginControllerAnimated:(BOOL)animated;
@end
