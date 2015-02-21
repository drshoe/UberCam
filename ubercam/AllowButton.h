//
//  AllowButton.h
//  ubercam
//
//  Created by Daniel Sheng Xu on 2015-02-20.
//  Copyright (c) 2015 danielxu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AllowButton;
@protocol AllowButtonDelegate
- (void) allowButton:(AllowButton *)button didTapWithSectionIndex:(NSInteger)index;
@end

@interface AllowButton : UIButton

@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, weak) id <AllowButtonDelegate> delegate;
@end
