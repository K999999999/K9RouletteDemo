//
//  K9Roulette.m
//  K9RouletteDemo
//
//  Created by K999999999 on 2017/7/5.
//  Copyright © 2017年 K999999999. All rights reserved.
//

#import "K9Roulette.h"
#import "Masonry.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface K9RouletteAnimationDeleagte : NSObject <CAAnimationDelegate>
#else
@interface K9RouletteAnimationDeleagte : NSObject
#endif

@property (nonatomic, copy) void    (^animationStopBlock)(BOOL);

@end

@implementation K9RouletteAnimationDeleagte

#pragma mark <CAAnimationDelegate>

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (self.animationStopBlock) {
        self.animationStopBlock(flag);
    }
}

@end

@interface K9Roulette ()

@property (nonatomic)           BOOL                                        k9_needCutSector;
@property (nonatomic)           NSInteger                                   k9_viewCount;
@property (nonatomic)           NSInteger                                   k9_targetIndex;
@property (nonatomic)           CGFloat                                     k9_lastAngle;
@property (nonatomic, strong)   NSMutableDictionary <NSNumber *, UIView *>  *k9_sectorViews;

@property (nonatomic, strong)   UIView                                      *k9_rotationView;
@property (nonatomic, strong)   CADisplayLink                               *k9_displayLink;

@end

@implementation K9Roulette

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self k9_didInitialized];
    }
    return self;
}

- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    [self k9_fillDataSource];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self k9_cutSector];
}

#pragma mark - Public Methods

- (void)k9_reloadData {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self k9_removeAllSector];
        [self k9_fillDataSource];
    });
}

- (void)k9_beginRotation {
    [self k9_playBeginRotationAnimation];
}

- (void)k9_stopRotationAtIndex:(NSInteger)index {
    [self k9_playStopRotationAnimation:index];
}

#pragma mark - Action Methods

- (void)k9_displayRefresh {
    
    CGFloat angle = [[self.k9_rotationView.layer.presentationLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
    CGFloat angleOffset = angle - self.k9_lastAngle;
    if (angleOffset < 0.f) {
        angleOffset += M_PI * 2.f;
    }
    if (angleOffset > M_PI * .1f) {
        
        self.k9_lastAngle = angle;
        if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_rouletteDidRotateMinAngle:)]) {
            [self.k9_delegate k9_rouletteDidRotateMinAngle:self];
        }
    }
}

#pragma mark - Private Methods

- (void)k9_didInitialized {
    
    _k9_needCutSector = NO;
    _k9_viewCount = 0;
    _k9_targetIndex = 0;
}

- (NSInteger)k9_numberOfSector {
    
    if (self.k9_dataSource && [self.k9_dataSource respondsToSelector:@selector(k9_numberOfSectorInRoulette:)]) {
        return [self.k9_dataSource k9_numberOfSectorInRoulette:self];
    }
    return 0;
}

- (UIView *)k9_viewAtIndex:(NSInteger)index {
    
    if (self.k9_dataSource && [self.k9_dataSource respondsToSelector:@selector(k9_roulette:viewAtIndex:)]) {
        return [self.k9_dataSource k9_roulette:self viewAtIndex:index];
    }
    return nil;
}

- (CGFloat)k9_angleAtIndex:(NSInteger)index {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_roulette:angleAtIndex:)]) {
        return [self.k9_delegate k9_roulette:self angleAtIndex:index];
    }
    return M_PI * 2.f / (CGFloat)self.k9_viewCount;
}

- (CFTimeInterval)k9_durationOfBeginRotation {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_durationOfBeginRotationInRoulette:)]) {
        return [self.k9_delegate k9_durationOfBeginRotationInRoulette:self];
    }
    return .5f;
}

- (CFTimeInterval)k9_durationOfRotation {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_durationOfRotationInRoulette:)]) {
        return [self.k9_delegate k9_durationOfRotationInRoulette:self];
    }
    return .17f;
}

- (CFTimeInterval)k9_durationOfStopRotation {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_durationOfStopRotationInRoulette:)]) {
        return [self.k9_delegate k9_durationOfStopRotationInRoulette:self];
    }
    return 1.f;
}

- (NSArray *)k9_valuesOfBeginRotation:(CGFloat)fromAngle toAngle:(CGFloat)toAngle {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_valuesOfBeginRotationInRoulette:fromAngle:toAngle:)]) {
        return [self.k9_delegate k9_valuesOfBeginRotationInRoulette:self fromAngle:fromAngle toAngle:toAngle];
    }
    CGFloat angleOffset = toAngle - fromAngle;
    return @[@(fromAngle), @(fromAngle + angleOffset * .2f), @(fromAngle + angleOffset * .4f), @(fromAngle + angleOffset * .6f), @(fromAngle + angleOffset * .8f), @(toAngle)];
}

- (NSArray <NSNumber *> *)k9_keyTimesOfBeginRotation {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_keyTimesOfBeginRotationInRoulette:)]) {
        return [self.k9_delegate k9_keyTimesOfBeginRotationInRoulette:self];
    }
    return @[@(0.f), @(.31f), @(.58f), @(.79f), @(.93f), @(1.f)];
}

- (NSArray <CAMediaTimingFunction *> *)k9_timingFunctionsOfBeginRotation {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_timingFunctionsOfBeginRotationInRoulette:)]) {
        return [self.k9_delegate k9_timingFunctionsOfBeginRotationInRoulette:self];
    }
    return @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn] , [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
}

- (NSArray *)k9_valuesOfStopRotation:(CGFloat)fromAngle toAngle:(CGFloat)toAngle {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_valuesOfStopRotationInRoulette:fromAngle:toAngle:)]) {
        return [self.k9_delegate k9_valuesOfStopRotationInRoulette:self fromAngle:fromAngle toAngle:toAngle];
    }
    CGFloat angleOffset = toAngle - fromAngle;
    return @[@(fromAngle), @(fromAngle + angleOffset * .2f), @(fromAngle + angleOffset * .4f), @(fromAngle + angleOffset * .6f), @(fromAngle + angleOffset * .8f), @(fromAngle + angleOffset), @(fromAngle + angleOffset + M_PI * .2f), @(fromAngle + angleOffset)];
}

- (NSArray <NSNumber *> *)k9_keyTimesOfStopRotation {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_keyTimesOfStopRotationInRoulette:)]) {
        return [self.k9_delegate k9_keyTimesOfStopRotationInRoulette:self];
    }
    return @[@(0.f), @(.05f), @(.15f), @(.3f), @(.5f), @(.75f), @(.85f), @(1.f)];
}

- (NSArray <CAMediaTimingFunction *> *)k9_timingFunctionsOfStopRotation {
    
    if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_timingFunctionsOfStopRotationInRoulette:)]) {
        return [self.k9_delegate k9_timingFunctionsOfStopRotationInRoulette:self];
    }
    return @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] , [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
}

- (void)k9_removeAllSector {
    
    self.k9_rotationView.transform = CGAffineTransformIdentity;
    for (UIView *view in self.k9_sectorViews.allValues) {
        [view removeFromSuperview];
    }
    [self.k9_sectorViews removeAllObjects];
}

- (void)k9_fillDataSource {
    
    self.k9_viewCount = [self k9_numberOfSector];
    if (self.k9_viewCount == 0) {
        
        [self k9_removeAllSector];
        return;
    }
    
    self.k9_needCutSector = YES;
    for (NSInteger i = 0; i < self.k9_viewCount; i++) {
        
        UIView *view = [self k9_viewAtIndex:i];
        if (!view || view.superview) {
            continue;
        }
        
        view.layer.anchorPoint = CGPointMake(.5f, 1.f);
        [self.k9_sectorViews setObject:view forKey:@(i)];
    }
    [self layoutSubviews];
}

- (void)k9_cutSector {
    
    if (!self.k9_needCutSector) {
        return;
    }
    
    CGFloat length = MIN(self.bounds.size.width, self.bounds.size.height);
    if (length == 0.f) {
        return;
    }
    
    if (!self.k9_rotationView.superview) {
        
        [self addSubview:self.k9_rotationView];
        [self.k9_rotationView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.center.equalTo(self);
            make.width.height.mas_equalTo(length);
        }];
    }
    
    self.k9_needCutSector = NO;
    CGFloat rotationAngle = 0.f;
    for (NSInteger i = 0; i < self.k9_viewCount; i++) {
        
        UIView *view = [self.k9_sectorViews objectForKey:@(i)];
        CGFloat angle = [self k9_angleAtIndex:i];
        if (i > 0) {
            CGFloat lastAngle = [self k9_angleAtIndex:(i - 1)];
            rotationAngle += (lastAngle + angle) * .5f;
        }
        
        if (!view || view.superview) {
            continue;
        }
        
        CGFloat width = self.k9_viewCount > 2 ? length * tan(angle * .5f) : length;
        CGFloat height = self.k9_viewCount > 1 ? length * .5f : length;
        [self.k9_rotationView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self.k9_rotationView).with.offset(self.k9_viewCount > 1 ? 0.f : length * .5f);
            make.centerX.equalTo(self.k9_rotationView);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height);
        }];
        
        CGPoint center = CGPointMake(width * .5f, self.k9_viewCount > 1 ? height : height * .5f);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:(length * .5f) startAngle:-(angle * .5f + M_PI * .5f) endAngle:(angle * .5f - M_PI * .5f) clockwise:YES];
        [path addLineToPoint:center];
        [path closePath];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        view.layer.mask = shapeLayer;
        view.transform = CGAffineTransformMakeRotation(rotationAngle);
    }
}

- (void)k9_playBeginRotationAnimation {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat angle = atan2f(self.k9_rotationView.transform.b, self.k9_rotationView.transform.a);
        self.k9_lastAngle = angle;
        self.k9_rotationView.transform = CGAffineTransformIdentity;
        [self k9_beginDisplayLink];
        CAKeyframeAnimation *beginAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
        beginAnimation.values = [self k9_valuesOfBeginRotation:angle toAngle:(angle + M_PI * 2.f)];
        beginAnimation.keyTimes = [self k9_keyTimesOfBeginRotation];
        beginAnimation.timingFunctions = [self k9_timingFunctionsOfBeginRotation];
        beginAnimation.duration = [self k9_durationOfBeginRotation];
        beginAnimation.removedOnCompletion = YES;
        K9RouletteAnimationDeleagte *delegate = [[K9RouletteAnimationDeleagte alloc] init];
        __weak typeof(self)weakSelf = self;
        delegate.animationStopBlock = ^(BOOL flag) {
            
            __strong typeof(weakSelf)self = weakSelf;
            if (flag) {
                [self k9_playRotationAnimation];
            } else {
                [self k9_stopDisplayLink];
            }
        };
        beginAnimation.delegate = delegate;
        [self.k9_rotationView.layer addAnimation:beginAnimation forKey:@"BeginRotation"];
    });
}

- (void)k9_playRotationAnimation {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.fromValue = @(0.f);
        rotationAnimation.toValue = @(M_PI * 2.f);
        rotationAnimation.duration = [self k9_durationOfRotation];
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        rotationAnimation.repeatCount = HUGE_VALF;
        rotationAnimation.removedOnCompletion = NO;
        K9RouletteAnimationDeleagte *delegate = [[K9RouletteAnimationDeleagte alloc] init];
        __weak typeof(self)weakSelf = self;
        delegate.animationStopBlock = ^(BOOL flag) {
            
            __strong typeof(weakSelf)self = weakSelf;
            if (self.k9_rotationView.layer.animationKeys == 0) {
                [self k9_stopDisplayLink];
            }
        };
        rotationAnimation.delegate = delegate;
        [self.k9_rotationView.layer addAnimation:rotationAnimation forKey:@"Rotation"];
    });
}

- (void)k9_playStopRotationAnimation:(NSInteger)index {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.k9_rotationView.layer removeAllAnimations];
        
        if (self.k9_viewCount <= 0) {
            return;
        }
        
        if (index < 0 || index >= self.k9_viewCount) {
            self.k9_targetIndex = 0;
        } else {
            self.k9_targetIndex = index;
        }
        
        CGFloat angle = 0.f;
        if (self.k9_viewCount > 1 && self.k9_targetIndex != 0) {
            
            angle += [self k9_angleAtIndex:0] * .5f;
            for (NSInteger i = self.k9_viewCount - 1; i >= self.k9_targetIndex; i--) {
                
                if (i != self.k9_targetIndex) {
                    angle += [self k9_angleAtIndex:i];
                } else {
                    angle += [self k9_angleAtIndex:i] * .5f;
                }
            }
        }
        self.k9_rotationView.transform = CGAffineTransformMakeRotation(angle);
        angle += M_PI * 2.f;
        
        [self k9_beginDisplayLink];
        CAKeyframeAnimation *stopAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
        stopAnimation.values = [self k9_valuesOfStopRotation:0.f toAngle:angle];
        stopAnimation.keyTimes = [self k9_keyTimesOfStopRotation];
        stopAnimation.timingFunctions = [self k9_timingFunctionsOfStopRotation];
        stopAnimation.duration = [self k9_durationOfStopRotation];
        stopAnimation.removedOnCompletion = YES;
        K9RouletteAnimationDeleagte *delegate = [[K9RouletteAnimationDeleagte alloc] init];
        __weak typeof(self)weakSelf = self;
        delegate.animationStopBlock = ^(BOOL flag) {
            
            __strong typeof(weakSelf)self = weakSelf;
            [self k9_stopDisplayLink];
            if (flag) {
                if (self.k9_delegate && [self.k9_delegate respondsToSelector:@selector(k9_roulette:didStopRotationAtIndex:)]) {
                    [self.k9_delegate k9_roulette:self didStopRotationAtIndex:self.k9_targetIndex];
                }
            }
        };
        stopAnimation.delegate = delegate;
        [self.k9_rotationView.layer addAnimation:stopAnimation forKey:@"StopRotation"];
    });
}

- (void)k9_beginDisplayLink {
    [self.k9_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)k9_stopDisplayLink {
    
    if (_k9_displayLink) {
        
        [_k9_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [_k9_displayLink invalidate];
        _k9_displayLink = nil;
    }
}

#pragma mark - Getters

- (NSMutableDictionary <NSNumber *, UIView *> *)k9_sectorViews {
    
    if (!_k9_sectorViews) {
        _k9_sectorViews = [NSMutableDictionary dictionary];
    }
    return _k9_sectorViews;
}

- (UIView *)k9_rotationView {
    
    if (!_k9_rotationView) {
        
        _k9_rotationView = [[UIView alloc] init];
    }
    return _k9_rotationView;
}

- (CADisplayLink *)k9_displayLink {
    
    if (!_k9_displayLink) {
        
        _k9_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(k9_displayRefresh)];
        _k9_displayLink.frameInterval = 6;
    }
    return _k9_displayLink;
}

@end
