//
//  ProfileViewController.m
//  ubercam
//
//  Created by Daniel Sheng Xu on 2/27/2014.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingNumberLabel;

@end

@implementation ProfileViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUserStatus];
}

- (void)updateUserStatus {
    PFUser *user = [PFUser currentUser];
    self.profileImageView.file = user[@"profilePicture"];
    [self.profileImageView loadInBackground];
    self.userNameLabel.text = user.username;
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:@"fromUser" equalTo:user];
    [followingQuery whereKey:@"type" equalTo:@"follow"];
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *followingActivities, NSError *error) {
        if (!error) {
            self.followingNumberLabel.text = [[NSNumber numberWithInteger:followingActivities.count] stringValue];
        }
    }];
    
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
    [followerQuery whereKey:@"toUser" equalTo:user];
    [followerQuery whereKey:@"type" equalTo:@"follow"];
    [followerQuery findObjectsInBackgroundWithBlock:^(NSArray *followerActivities, NSError *error) {
        if (!error) {
            self.followerNumberLabel.text = [[NSNumber numberWithInteger:followerActivities.count] stringValue];
        }
    }];
}


- (IBAction)logout:(id)sender {
}
















@end
