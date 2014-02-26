//
//  FollowButton.m
//  ubercam
//
//  Created by Daniel Sheng Xu on 2/26/2014.
//  Copyright (c) 2014 danielxu. All rights reserved.
//

#import "FollowButton.h"

@implementation FollowButton

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super initWithCoder:aDecoder]) {
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) buttonPressed {
    [self.delegate followButton:self didTapWithSectionIndex:self.sectionIndex];
}

@end
