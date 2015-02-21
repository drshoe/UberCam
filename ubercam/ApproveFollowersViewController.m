//
//  ApproveFollowersViewController.m
//  ubercam
//
//  Created by Daniel Sheng Xu on 2015-02-20.
//  Copyright (c) 2015 danielxu. All rights reserved.
//

#import "ApproveFollowersViewController.h"

@interface ApproveFollowersViewController ()

@end

@implementation ApproveFollowersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)allowButton:(AllowButton *)button didTapWithSectionIndex:(NSInteger)index {

    PFObject *followActivity = self.objects[index];
    followActivity[@"isApproved"] = @YES;
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            [self loadObjects];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"AllowCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    AllowButton *button = (AllowButton *)[cell viewWithTag:2];
    button.sectionIndex = indexPath.row;
    button.delegate = self;
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:1];
    descriptionLabel.text = object[@"fromUser"][@"username"];
    return cell;
}

- (PFQuery *)queryForTable {
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        return nil;
    }
    PFQuery *notApprovedFollowingQuery = [PFQuery queryWithClassName:@"Activity"];
    [notApprovedFollowingQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [notApprovedFollowingQuery whereKey:@"type" equalTo:@"follow"];
    [notApprovedFollowingQuery whereKey:@"isApproved" equalTo:[NSNumber numberWithBool:NO]];
    [notApprovedFollowingQuery includeKey:@"fromUser"];
    return notApprovedFollowingQuery;
}
@end
