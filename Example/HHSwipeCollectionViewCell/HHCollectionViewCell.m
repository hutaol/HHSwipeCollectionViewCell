//
//  HHCollectionViewCell.m
//  HHSwipeCollectionViewCell_Example
//
//  Created by Henry on 2022/2/21.
//  Copyright © 2022 hutaol. All rights reserved.
//

#import "HHCollectionViewCell.h"

@implementation HHCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end
