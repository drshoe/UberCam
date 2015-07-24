//
//  HomeViewController.m
//  ubercam
//
//  Created by Daniel Sheng Xu on 2/22/2014.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import "HomeViewController.h"
#import "DetailViewController.h"
#import "CommentsViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *followingArray;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This table displays items in the Todo class
        self.parseClassName = @"Photo";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 3;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewDataSource and Delegates
- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"follow"];
    [query includeKey:@"toUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            self.followingArray = [NSMutableArray array];
            if (objects.count >0) {
                for (PFObject *activity in objects) {
                    PFUser *user = activity[@"toUser"];
                    [self.followingArray addObject:user.objectId];
                }
            }
            [self.tableView reloadData];
        }
    }];
    
}

// return objects in a different indexpath order. in this case we return object based on the section, not row, the default is row

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }
    else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return nil;
    }
    static NSString *CellIdentifier = @"SectionHeaderCell";
    UITableViewCell *sectionHeaderView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFImageView *profileImageView = (PFImageView *)[sectionHeaderView viewWithTag:1];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2;
    profileImageView.layer.masksToBounds = YES;
    
    UILabel *userNameLabel = (UILabel *)[sectionHeaderView viewWithTag:2];
    UILabel *titleLabel = (UILabel *)[sectionHeaderView viewWithTag:3];
    
    PFObject *photo = [self.objects objectAtIndex:section];
    PFUser *user = [photo objectForKey:@"whoTook"];
    PFFile *profilePicture = [user objectForKey:@"profilePicture"];
    NSString *title = photo[@"title"];
    
    userNameLabel.text = user.username;
    titleLabel.text = title;
    
    profileImageView.file = profilePicture;
    [profileImageView loadInBackground];
    
    //follow button
    FollowButton *followButton = (FollowButton *)[sectionHeaderView viewWithTag:4];
    followButton.delegate = self;
    followButton.sectionIndex = section;
    
    //detail button
    DetailButton *detailButton = (DetailButton *)[sectionHeaderView viewWithTag:5];
    detailButton.sectionIndex = section;
    
    if (!self.followingArray || [user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        followButton.hidden = YES;
    }
    else {
        followButton.hidden = NO;
        NSInteger indexOfMatchedObject = [self.followingArray indexOfObject:user.objectId];
        if (indexOfMatchedObject == NSNotFound) {
            followButton.selected = NO;
        }
        else {
            followButton.selected = YES;
        }
    }
    
    return sectionHeaderView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && sections >0) {
        sections++;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    if (indexPath.section == self.objects.count) {
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    static NSString *CellIdentifier = @"PhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PFImageView *photo = (PFImageView *)[cell viewWithTag:1];
    photo.file = object[@"image"];
    [photo loadInBackground];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        return 0.0f;
    }
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.objects.count) {
        return 50.0f;
    }
    return 350.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LoadMoreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        [self loadNextPage];
    }
}

//http://stackoverflow.com/questions/24992261/pfquerytableviewcontroller-error
// fix bug :Assertion failure in -[UITableView _endCellAnimationsWithContext:], /SourceCache/UIKit_Sim/UIKit-2935.137/UITableView.m:1114 2014-07-28 01:50:37.368 SampleCamApp[25686:60b] Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'attempt to delete row 3 from section 0 which only contains 1 rows before the update'
- (NSIndexPath *)_indexPathForPaginationCell {
    return [NSIndexPath indexPathForRow:0 inSection:[self.objects count]];
}

- (PFQuery *)queryForTable {
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        return nil;
    }
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query includeKey:@"whoTook"];
    
    [query orderByDescending:@"createdAt"];
    return query;
}

- (void)followButton:(FollowButton *)button didTapWithSectionIndex:(NSInteger)index {
    PFObject *photo = [self.objects objectAtIndex:index];
    PFUser *user = photo[@"whoTook"];
    
    if (!button.selected) {
        [self followUser:user];
    }
    else {
        [self unfollowUser:user];
    }
    [self.tableView reloadData];
}

- (void)followUser:(PFUser *)user {
    if (![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        [self.followingArray addObject:user.objectId];
        PFObject *followActivity = [PFObject objectWithClassName:@"Activity"];
        followActivity[@"fromUser"] = [PFUser currentUser];
        followActivity[@"toUser"] = user;
        followActivity[@"type"] = @"follow";
        if (user[@"isPrivate"]) {
            followActivity[@"isApproved"] = [NSNumber numberWithBool:NO];
        }
        else {
            // the user is not private, so we don't need approval, set isApproved to YES
            followActivity[@"isApproved"] = [NSNumber numberWithBool:YES];
        }
        [followActivity saveEventually];
    }
}

- (void)unfollowUser:(PFUser *)user {
    [self.followingArray removeObject:user.objectId];
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser" equalTo:user];
    [query whereKey:@"type" equalTo:@"follow"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"DetailSegue"]) {
        DetailViewController *vc = segue.destinationViewController;
        NSInteger sectionIndex = [(DetailButton *)sender sectionIndex];
        vc.sectionIndex = sectionIndex;
        PFObject *photo = [self.objects objectAtIndex:sectionIndex];
        vc.titleLabelText = photo[@"title"];
        vc.imageFile = photo[@"image"];
    }
    else if ([segue.identifier isEqualToString:@"CommentSegue"]) {
        CommentsViewController *vc = segue.destinationViewController;
        NSInteger sectionIndex = [(DetailButton *)sender sectionIndex];
        PFObject *photo = [self.objects objectAtIndex:sectionIndex];
        vc.photo = photo;
    }
}

@end
