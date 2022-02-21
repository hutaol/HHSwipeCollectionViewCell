//
//  HHViewController.m
//  HHSwipeCollectionViewCell
//
//  Created by hutaol on 02/21/2022.
//  Copyright (c) 2022 hutaol. All rights reserved.
//

#import "HHViewController.h"
#import "HHCollectionViewCell.h"

@interface HHViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation HHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[HHCollectionViewCell class] forCellWithReuseIdentifier:@"HHCollectionViewCell"];
    
    self.datas = [NSMutableArray array];
    for (int i = 0; i < 20; i ++) {
        [self.datas addObject:[NSString stringWithFormat:@"标题标题标题标题标题标题-%d", i]];
    }
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HHCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHCollectionViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = self.datas[indexPath.row];
    cell.canSwiped = YES;
    cell.backgroundColor = [UIColor lightGrayColor];
    
    HHSwipeAction *action1 = [[HHSwipeAction alloc] initWithTitle:@"删除" block:^{
        NSLog(@"删除");
    }];
    
    HHSwipeAction *action2 = [[HHSwipeAction alloc] init];
    action2.title = @"关注";
    action2.backgroundColor = [UIColor blueColor];
        
    if (indexPath.row == 0) {
        cell.actions = @[action1];
    } else {
        cell.actions = @[action1, action2];

    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width-20, 50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [HHSwipeCollectionViewCell closeSwipeCell:self.collectionView];
}

@end
