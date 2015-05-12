//
//  HomeViewController.h
//  ubercam
//
//  Created by Daniel Sheng Xu on 2/22/2014.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import <Parse/Parse.h>
#import "FollowButton.h"
#import "DetailButton.h"

@interface HomeViewController : PFQueryTableViewController <FollowButtonDelegate>

@end
