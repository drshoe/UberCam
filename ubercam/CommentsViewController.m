//
//  CommentsViewController.m
//  ubercam
//
//  Created by Daniel Sheng Xu on 2015-06-10.
//  Copyright (c) 2015 danielxu. All rights reserved.
//

#import "CommentsViewController.h"

#import "MessageTableViewCell.h"
#import "CommentTextView.h"
#import "Message.h"

#import "LoremIpsum.h"
#import "MBProgressHUD.h"

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";

@interface CommentsViewController ()

/*
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSArray *emojis;
*/
@property (nonatomic, strong) NSArray *searchResult;

@property (nonatomic, strong) NSArray *commentsArray;
@property (nonatomic, strong) NSMutableArray *userNames;

@end

@implementation CommentsViewController

// for init with code
- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        // Register a subclass of SLKTextView, if you need any special appearance and/or behavior customisation.
        [self registerClassForTextView:[CommentTextView class]];
    }
    return self;
}

// for init with storyboard
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Register a subclass of SLKTextView, if you need any special appearance and/or behavior customisation.
        [self registerClassForTextView:[CommentTextView class]];
    }
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ///////////////// set up test data
    /*
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 100; i++) {
        NSInteger words = (arc4random() % 40)+1;
        
        Message *message = [Message new];
        message.username = [LoremIpsum name];
        message.text = [LoremIpsum wordsWithNumber:words];
        [array addObject:message];
    }
    
    NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
    
    
    self.messages = [[NSMutableArray alloc] initWithArray:reversed];
    
    self.users = @[@"Allen", @"Anna", @"Alicia", @"Arnold", @"Armando", @"Antonio", @"Brad", @"Catalaya", @"Christoph", @"Emerson", @"Eric", @"Everyone", @"Steve"];
    self.channels = @[@"General", @"Random", @"iOS", @"Bugs", @"Sports", @"Android", @"UI", @"SSB"];
    self.emojis = @[@"m", @"man", @"machine", @"block-a", @"block-b", @"bowtie", @"boar", @"boat", @"book", @"bookmark", @"neckbeard", @"metal", @"fu", @"feelsgood"];
    */
    //////////////////
    
    // setup tableview behaviour
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    // setup text input field send button
    [self.rightButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    
    self.textInputbar.autoHideRightButton = NO; //set to YES if you want to hide the send button until user start typing
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit; // word count
    self.textInputbar.counterPosition = SLKCounterPositionTop;
    
    self.typingIndicatorView.canResignByTouch = YES;
    
    // setup auto completion view allowing you to mention or @ users who are in the conversation
    [self.autoCompletionView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:AutoCompletionCellIdentifier];
    [self registerPrefixesForAutoCompletion:@[@"@"]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadObjects];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - query comments data
- (void)loadObjects {
    NSLog(@"%@",self.photo);
    self.userNames = [NSMutableArray array];
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"type" equalTo:@"comment"];
    [query whereKey:@"photo" equalTo:self.photo];
    [query includeKey:@"fromUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            self.commentsArray = objects;
            if (objects.count >0) {
                for (PFObject *activity in objects) {
                    PFUser *user = activity[@"fromUser"];
                    [self.userNames addObject:user.username];
                }
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Overriden Methods
// send button is pressed
- (void)didPressRightButton:(id)sender
{
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    Message *message = [Message new];
    message.username = [LoremIpsum name];
    message.text = [self.textView.text copy];
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    //UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
    
    /*
    [self.tableView beginUpdates];
    [self.messages insertObject:message atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
    */
    //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
    
    
    // Trim the comment text
    NSString *trimmedComment = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedComment.length != 0 && [self.photo objectForKey:@"whoTook"]) {
        // Create the comment activity object
        PFObject *commentActivity = [PFObject objectWithClassName:@"Activity"];
        commentActivity[@"fromUser"] = [PFUser currentUser];
        commentActivity[@"toUser"] = self.photo[@"whoTook"];
        commentActivity[@"type"] = @"comment";
        commentActivity[@"commentString"] = trimmedComment;
        commentActivity[@"photo"] = self.photo;
    
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment,
        // stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                          target:self
                                                        selector:@selector(handleCommentTimeout:)
                                                        userInfo:[NSDictionary
                                                                  dictionaryWithObject:commentActivity
                                                                  forKey:@"comment"] repeats:NO];
        
        [commentActivity saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate]; // Stop the timer if it's still running
            
            // Check if the photo still exists
            if (error && [error code] == kPFErrorObjectNotFound) {
                [[[UIAlertView alloc] initWithTitle:@"Could not post comment"
                                            message:@"Photo was deleted"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects]; //refresh table view
        }];
    }
    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [super didPressRightButton:sender];
}
    
- (void) handleCommentTimeout:(NSDictionary *)userInfo {
    [[[UIAlertView alloc] initWithTitle:@"Could not post comment"
                                message:@"Please try again"
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (NSString *)keyForTextCaching
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

- (void)didCommitTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the right "Send" button for commiting the edited text
    /*
    Message *message = [Message new];
    message.username = [LoremIpsum name];
    message.text = [self.textView.text copy];
    
    [self.messages removeObjectAtIndex:0];
    [self.messages insertObject:message atIndex:0];
    [self.tableView reloadData];
    */
    [super didCommitTextEditing:sender];
}

- (BOOL)canShowAutoCompletion
{
    NSArray *array = nil;
    NSString *prefix = self.foundPrefix;
    NSString *word = self.foundWord;
    
    self.searchResult = nil;
    
    if ([prefix isEqualToString:@"@"]) {
        if (word.length > 0) {
            array = [self.userNames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
        }
        else {
            array = self.userNames;
        }
    }
    /*
    else if ([prefix isEqualToString:@"#"] && word.length > 0) {
        array = [self.channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    }
    else if ([prefix isEqualToString:@":"] && word.length > 1) {
        array = [self.emojis filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    }*/
    
    if (array.count > 0) {
        array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    self.searchResult = [[NSMutableArray alloc] initWithArray:array];
    
    return self.searchResult.count > 0;
}

- (CGFloat)heightForAutoCompletionView
{
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight*self.searchResult.count;
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return self.commentsArray.count;
    }
    else {
        return self.searchResult.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [self messageCellForRowAtIndexPath:indexPath];
    }
    else {
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    }
}

- (MessageTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];
    
    /*
    if (!cell.textLabel.text) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editCellMessage:)];
        [cell addGestureRecognizer:longPress];
    }*/
    
    PFObject *commentActivity = self.commentsArray[indexPath.row];
    PFUser *fromUser = commentActivity[@"fromUser"];
    cell.titleLabel.text = fromUser.username;
    cell.bodyLabel.text = commentActivity[@"commentString"];
    PFFile *profilePicture = fromUser[@"profilePicture"];
    cell.thumbnailView.file = profilePicture;
    [cell.thumbnailView loadInBackground];
    
    /*
    if (message.attachment) {
        cell.attachmentView.image = message.attachment;
        cell.attachmentView.layer.shouldRasterize = YES;
        cell.attachmentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }*/
    
    //cell.indexPath = indexPath;
    //cell.usedForMessage = YES;
    
    /*
    if (cell.needsPlaceholder)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
            scale = [UIScreen mainScreen].nativeScale;
        }
        
        CGSize imgSize = CGSizeMake(kAvatarSize*scale, kAvatarSize*scale);
        
        [LoremIpsum asyncPlaceholderImageWithSize:imgSize
                                       completion:^(UIImage *image) {
                                           UIImage *thumbnail = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
                                           cell.thumbnailView.image = thumbnail;
                                           cell.thumbnailView.layer.shouldRasterize = YES;
                                           cell.thumbnailView.layer.rasterizationScale = [UIScreen mainScreen].scale;
                                       }];
    }*/
    
    // Cells must inherit the table view's transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (MessageTableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
    cell.indexPath = indexPath;
    
    NSString *item = self.searchResult[indexPath.row];
    
    if ([self.foundPrefix isEqualToString:@"#"]) {
        item = [NSString stringWithFormat:@"# %@", item];
    }
    else if ([self.foundPrefix isEqualToString:@":"]) {
        item = [NSString stringWithFormat:@":%@:", item];
    }
    
    cell.titleLabel.text = item;
    cell.titleLabel.font = [UIFont systemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        PFObject *commentActivity = self.commentsArray[indexPath.row];
        PFUser *fromUser = commentActivity[@"fromUser"];
        NSString *username= fromUser.username;
        NSString *commentString = commentActivity[@"commentString"];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kAvatarSize;
        width -= 25.0;
        
        CGRect titleBounds = [username boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect bodyBounds = [commentString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        if (commentString.length == 0) {
            return 0.0;
        }
        
        CGFloat height = CGRectGetHeight(titleBounds);
        height += CGRectGetHeight(bodyBounds);
        height += 40.0;
        /*
        if (message.attachment) {
            height += 80.0 + 10.0;
        }*/
        
        if (height < kMinimumHeight) {
            height = kMinimumHeight;
        }
        
        return height;
    }
    else {
        return kMinimumHeight;
    }
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.autoCompletionView]) {
        
        NSMutableString *item = [self.searchResult[indexPath.row] mutableCopy];
        
        if ([self.foundPrefix isEqualToString:@"@"] && self.foundPrefixRange.location == 0) {
            [item appendString:@":"];
        }
        else if ([self.foundPrefix isEqualToString:@":"]) {
            [item appendString:@":"];
        }
        
        [item appendString:@" "];
        
        [self acceptAutoCompletionWithString:item keepPrefix:YES];
    }
}
@end
