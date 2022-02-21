//
//  HHSwipeCollectionViewCell.h
//  Pods
//
//  Created by Henry on 2022/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HHSwipeActionBlock)(void);

@interface HHSwipeAction : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, copy) HHSwipeActionBlock block;

- (instancetype)initWithTitle:(NSString *)title block:(HHSwipeActionBlock)block;

@end

extern NSString * const SwipeCollectionViewCurrentSwipeCell;

@interface HHSwipeCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView *revealView;

@property (nonatomic, assign) BOOL canSwiped;

@property (nonatomic, strong) NSArray <HHSwipeAction *> *actions;

- (void)showRevealViewAnimated:(BOOL)isAnimated;
- (void)hideRevealViewAnimated:(BOOL)isAnimated;

+ (void)closeSwipeCell:(UICollectionView *)collectionView;

@end

NS_ASSUME_NONNULL_END
