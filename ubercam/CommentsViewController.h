//
//  CommentsViewController.h
//  ubercam
//
//  Created by Daniel Sheng Xu on 2015-06-10.
//  Copyright (c) 2015 danielxu. All rights reserved.
//

#import "SLKTextViewController.h"
#import <Parse/Parse.h>
@interface CommentsViewController : SLKTextViewController

@property (nonatomic, strong) PFObject *photo;
@end
