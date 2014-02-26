//
//  FollowButton.h
//  ubercam
//
//  Created by Daniel Sheng Xu on 2/26/2014.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FollowButton;
@protocol FollowButtonDelegate
- (void) followButton:(FollowButton *)button didTapWithSectionIndex:(NSInteger)index;
@end

@interface FollowButton : UIButton

@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, weak) id <FollowButtonDelegate> delegate;
@end
