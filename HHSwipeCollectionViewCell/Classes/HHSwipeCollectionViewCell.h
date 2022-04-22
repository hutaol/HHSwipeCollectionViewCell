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
/// 字体 默认：[UIFont systemFontOfSize:17]
@property (nonatomic, strong) UIFont *font;
/// 字体颜色 默认： [UIColor whiteColor]
@property (nonatomic, strong) UIColor *color;
/// 背景色 默认：[UIColor redColor]
@property (nonatomic, strong) UIColor *backgroundColor;

/// 水平内边距 默认：14
@property (nonatomic, assign) NSInteger horizontalPadding;

@property (nonatomic, copy) HHSwipeActionBlock block;

- (instancetype)initWithTitle:(NSString *)title block:(HHSwipeActionBlock)block;
- (instancetype)initWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor block:(HHSwipeActionBlock)block;
- (instancetype)initWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor font:(UIFont *)font block:(HHSwipeActionBlock)block;

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
