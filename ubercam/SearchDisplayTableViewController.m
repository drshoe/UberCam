//
//  SearchDisplayTableViewController.m
//  ubercam
//
//  Created by Daniel Xu on 2014-10-21.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import "SearchDisplayTableViewController.h"

@interface SearchDisplayTableViewController ()
@property (nonatomic, strong) NSString *username;
@end

@implementation SearchDisplayTableViewController

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
        self.parseClassName = @"User";
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
        self.username = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_logo"]];
}

#pragma mark - PFQueryTableViewDataSource and Delegates
// return objects in a different indexpath order. in this case we return object based on the section, not row, the default is row
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (object[@"username"]) {
        cell.textLabel.text = object[@"username"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (PFQuery *)queryForTable {
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        return nil;
    }
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"username" hasPrefix:self.username];
    
    [query orderByDescending:@"createdAt"];
    return query;
}


#pragma mark - UISearchControllerDelegate method
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.username = searchText;
    if (self.username.length>0) {
        [self loadObjects];
    }
}
@end
