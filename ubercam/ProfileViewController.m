//
//  ProfileViewController.m
//  ubercam
//
//  Created by Daniel Sheng Xu on 2/27/2014.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingNumberLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privacySwitch;
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
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    [self.privacySwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    BOOL isPrivate = [[PFUser currentUser][@"isPrivate"] boolValue];
    [self.privacySwitch setOn:isPrivate animated:NO];
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

- (PFQuery *)queryForTable {
    //NSArray *result;
    
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        return nil;
    }
    // this query is for backward compatibility purpose since we did not have isApproved key before.
    PFQuery *noApprovedStatefollowingQuery = [PFQuery queryWithClassName:@"Activity"];
    [noApprovedStatefollowingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [noApprovedStatefollowingQuery whereKey:@"type" equalTo:@"follow"];
    [noApprovedStatefollowingQuery whereKeyDoesNotExist:@"isApproved"];

    PFQuery *approvedFollowingQuery = [PFQuery queryWithClassName:@"Activity"];
    [approvedFollowingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [approvedFollowingQuery whereKey:@"type" equalTo:@"follow"];
    [approvedFollowingQuery whereKey:@"isApproved" equalTo:[NSNumber numberWithBool:YES]];
    
    // the following query is for getting the list of people you are following who have not approved your request BUT whose account is set to public which means you can view their photos anyway
    // we fist get a list of following activities that are not approved
    PFQuery *notApprovedFollowingQuery = [PFQuery queryWithClassName:@"Activity"];
    [notApprovedFollowingQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [notApprovedFollowingQuery whereKey:@"type" equalTo:@"follow"];
    [notApprovedFollowingQuery whereKey:@"isApproved" equalTo:[NSNumber numberWithBool:NO]];
    //result = [notApprovedFollowingQuery findObjects];
    // then we get a list of users whose profile is set to public
    PFQuery *nonPrivateUserQuery = [PFUser query];
    [nonPrivateUserQuery whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    //result = [nonPrivateUserQuery findObjects];
    // then we get the list of people we are following who have not approved our request but the their accounts are set to public
    [notApprovedFollowingQuery whereKey:@"toUser" matchesQuery:nonPrivateUserQuery];
    
    //result = [notApprovedFollowingQuery findObjects];

    PFQuery *followingQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:approvedFollowingQuery,noApprovedStatefollowingQuery,notApprovedFollowingQuery, nil]];

    //result = [followingQuery findObjects];
    
    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:@"Photo"];
    [photosFromFollowedUsersQuery whereKey:@"whoTook" matchesKey:@"toUser" inQuery:followingQuery];
    
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"Photo"];
    [photosFromCurrentUserQuery whereKey:@"whoTook" equalTo:[PFUser currentUser]];
    
    PFQuery *superQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromCurrentUserQuery,photosFromFollowedUsersQuery, nil]];
    [superQuery includeKey:@"whoTook"];
    [superQuery orderByDescending:@"createdAt"];
    
    return superQuery;
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate presentLoginControllerAnimated:YES];
}

- (void)setState:(id)sender
{
    BOOL state = [sender isOn];
    PFUser *user = [PFUser currentUser];
    user[@"isPrivate"] = [NSNumber numberWithBool:state];
    // save it immediately
    [user saveInBackground];
}
@end
