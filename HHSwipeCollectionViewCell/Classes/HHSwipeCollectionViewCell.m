//
//  HHSwipeCollectionViewCell.m
//  Pods
//
//  Created by Henry on 2022/2/21.
//

#import "HHSwipeCollectionViewCell.h"
#import <objc/runtime.h>

@implementation HHSwipeAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        _font = [UIFont systemFontOfSize:17];
        _color = [UIColor whiteColor];
        _backgroundColor = [UIColor redColor];
        _horizontalPadding = 14;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title block:(HHSwipeActionBlock)block {
    self = [super init];
    if (self) {
        _font = [UIFont systemFontOfSize:17];
        _color = [UIColor whiteColor];
        _backgroundColor = [UIColor redColor];
        _horizontalPadding = 14;
        _title = title;
        _block = block;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor block:(HHSwipeActionBlock)block {
    self = [super init];
    if (self) {
        _font = [UIFont systemFontOfSize:17];
        _color = [UIColor whiteColor];
        _backgroundColor = backgroundColor;
        _horizontalPadding = 14;
        _title = title;
        _block = block;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor font:(UIFont *)font block:(HHSwipeActionBlock)block {
    self = [super init];
    if (self) {
        _font = font;
        _color = [UIColor whiteColor];
        _backgroundColor = backgroundColor;
        _horizontalPadding = 14;
        _title = title;
        _block = block;
    }
    return self;
}

@end

@interface UIView (SuperCollectionView)

- (UICollectionView *)hh_superCollectionView;

@end

@implementation UIView (SuperCollectionView)

- (UICollectionView *)hh_superCollectionView {
    UIView *superview = self.superview;
    while (superview != nil) {
        if ([superview isKindOfClass:[UICollectionView class]]) {
            return (id)superview;
        }
        superview = [superview superview];
    }
    return nil;
}

@end

NSString * const SwipeCollectionViewCurrentSwipeCell = @"currentSwipeCell";


@interface HHSwipeCollectionViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIView *snapShotView;
@property (nonatomic,strong) UIView *snapBackgroundView;
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;

@end

@implementation HHSwipeCollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.snapBackgroundView removeFromSuperview];
    self.snapBackgroundView = nil;
    [self.snapShotView removeFromSuperview];
    self.snapShotView = nil;
    [self.revealView removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.canSwiped = YES;
        [self configureGestureRecognizer];
    }
    return self;
}

- (void)configureGestureRecognizer {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hh_panAction:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.revealView.frame = (CGRect) {
        .origin = CGPointMake( CGRectGetWidth(self.frame) - CGRectGetWidth(self.revealView.frame), 0.0f),
        .size = self.revealView.frame.size
    };
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [gesture velocityInView:self];
        if (fabs(point.x) > fabs(point.y)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return otherGestureRecognizer != self.hh_superCollectionView.panGestureRecognizer;
}

- (void)setCanSwiped:(BOOL)canSwiped {
    _canSwiped = canSwiped;
    self.panGesture.enabled = canSwiped;
}

#pragma mark - event response
- (void)hh_deleteAction:(UIButton *)sender {
    [self hideRevealViewAnimated:YES];
    HHSwipeAction *action = self.actions[sender.tag];
    if (action.block) {
        action.block();
    }
}

- (void)hh_panAction:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self _closeOtherOpeningCell];
            [self addSubview:self.snapBackgroundView];
            [self addSubview:self.revealView];
            [self addSubview:self.snapShotView];
            
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translationPoint  = [panGesture translationInView:self];
            CGPoint centerPoint = CGPointMake(0, self.snapShotView.center.y);
            centerPoint.x = MIN(CGRectGetWidth(self.frame)/2 ,
                                                self.snapShotView.center.x + translationPoint.x);;
            [panGesture setTranslation:CGPointZero inView:self];
            self.snapShotView.center = centerPoint;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint velocity = [panGesture velocityInView:self];
            if ([self _bigThenRevealViewHalfWidth] || [self _shouldShowRevealViewForVelocity:velocity]) {
                [self showRevealViewAnimated:YES];
            }
            if ([self _lessThenRevealViewHalfWidth] || [self _shouldHideRevealViewForVelocity:velocity]) {
                if (CGPointEqualToPoint(self.snapShotView.center, self.center)) { return; }
                [self hideRevealViewAnimated:YES];
            }
        }
            break;
        default:
            break;
    }
}

- (BOOL)_shouldHideRevealViewForVelocity:(CGPoint)velocity {
    return fabs(velocity.x) > CGRectGetWidth(self.revealView.frame)/2 && velocity.x > 0;
}

- (BOOL)_shouldShowRevealViewForVelocity:(CGPoint)velocity {
    return fabs(velocity.x) > CGRectGetWidth(self.revealView.frame)/2 && velocity.x < 0;
}

- (BOOL)_bigThenRevealViewHalfWidth {
    return fabs(CGRectGetMinX(self.snapShotView.frame)) >= CGRectGetWidth(self.revealView.frame)/2;
}

- (BOOL)_lessThenRevealViewHalfWidth {
    return fabs(CGRectGetMinX(self.snapShotView.frame)) < CGRectGetWidth(self.revealView.frame)/2;
}

- (void)showRevealViewAnimated:(BOOL)isAnimated {
    [UIView animateWithDuration:isAnimated ? 0.1: 0
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.snapShotView.center = CGPointMake( CGRectGetWidth(self.frame)/2 - CGRectGetWidth(self.revealView.frame),
                                                                self.snapShotView.center.y );
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)hideRevealViewAnimated:(BOOL)isAnimated {
    [UIView animateWithDuration:isAnimated ? 0.1: 0
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.snapShotView.center = CGPointMake( CGRectGetWidth(self.frame)/2,
                                                                self.snapShotView.center.y );
                     }
                     completion:^(BOOL finished) {
                         [self.snapBackgroundView removeFromSuperview];
                         self.snapBackgroundView = nil;
                         [self.snapShotView removeFromSuperview];
                         self.snapShotView = nil;
                         [self.revealView removeFromSuperview];
                     }];
}

- (void)_closeOtherOpeningCell {
    if (self.hh_superCollectionView) {
        HHSwipeCollectionViewCell *currentCell = objc_getAssociatedObject(self.hh_superCollectionView, (__bridge const void *)(SwipeCollectionViewCurrentSwipeCell));
        if (currentCell != self) {
            [currentCell hideRevealViewAnimated:YES];
        }
        objc_setAssociatedObject(self.hh_superCollectionView, (__bridge const void *)(SwipeCollectionViewCurrentSwipeCell), self, OBJC_ASSOCIATION_ASSIGN);
    }
}

+ (void)closeSwipeCell:(UICollectionView *)collectionView {
    if (collectionView) {
        HHSwipeCollectionViewCell *currentCell = objc_getAssociatedObject(collectionView, (__bridge const void *)(SwipeCollectionViewCurrentSwipeCell));
        if (currentCell) {
            [currentCell hideRevealViewAnimated:YES];
            objc_setAssociatedObject(collectionView, (__bridge const void *)(SwipeCollectionViewCurrentSwipeCell), nil, OBJC_ASSOCIATION_ASSIGN);
        }
    }
}

#pragma mark - lazy
- (UIView *)snapBackgroundView {
    if (!_snapBackgroundView) {
        _snapBackgroundView = ({
            UIView *tmpView = [[UIView alloc] initWithFrame:self.bounds];
            tmpView.backgroundColor = [UIColor whiteColor];
            tmpView;
        });
    }
    return _snapBackgroundView;
}

- (UIView *)snapShotView {
    if (!_snapShotView) {
        _snapShotView = [self snapshotViewAfterScreenUpdates:NO];
    }
    return _snapShotView;
}
- (UIView *)revealView {
    if (!_revealView) {
        _revealView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        _revealView.backgroundColor = [UIColor clearColor];
    }
    return _revealView;
}

- (void)setActions:(NSArray *)actions {
    _actions = actions;
    
    CGFloat sw = 0;
    for (int i = 0; i < actions.count; i ++) {
        HHSwipeAction *action = actions[i];
        CGSize textSize = [action.title sizeWithAttributes:@{NSFontAttributeName:action.font}];
        UIButton *button = [self hh_buttonWithAction:action];
        button.tag = i;
        CGFloat width = textSize.width + action.horizontalPadding * 2;

        button.frame = CGRectMake(i*width, 0, width, self.frame.size.height);
        
        // FIXME: 右边圆角，更加cell圆角设置最后一个按钮
        if (i == actions.count - 1) {
            if (self.layer.cornerRadius > 0) {
                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(self.layer.cornerRadius, self.layer.cornerRadius)];
                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                maskLayer.frame = button.bounds;
                maskLayer.path = maskPath.CGPath;
                button.layer.mask = maskLayer;
            }
        }
        
        [self.revealView addSubview:button];
        
        sw += width;
    }
    
    self.revealView.frame = CGRectMake(self.frame.size.width - sw, 0, sw, self.frame.size.width);
    
}

- (UIButton *)hh_buttonWithAction:(HHSwipeAction *)action {
    UIButton *tempButton = [[UIButton alloc] initWithFrame:_revealView.bounds];
    [tempButton setTitle:action.title forState:UIControlStateNormal];
    [tempButton setTitleColor:action.color forState:UIControlStateNormal];
    tempButton.backgroundColor = action.backgroundColor;
    tempButton.titleLabel.font = action.font;
    [tempButton addTarget:self action:@selector(hh_deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return tempButton;
}

@end
