//
//  K9Roulette.h
//  K9RouletteDemo
//
//  Created by K999999999 on 2017/7/5.
//  Copyright © 2017年 K999999999. All rights reserved.
//

#import <UIKit/UIKit.h>

@class K9Roulette;

@protocol K9RouletteDataSource <NSObject>

- (NSInteger)k9_numberOfSectorInRoulette:(K9Roulette *)roulette;

- (UIView *)k9_roulette:(K9Roulette *)roulette viewAtIndex:(NSInteger)index;

@end

@protocol K9RouletteDelegate <NSObject>

@optional

- (void)k9_rouletteDidRotateMinAngle:(K9Roulette *)roulette;

- (void)k9_roulette:(K9Roulette *)roulette didStopRotationAtIndex:(NSInteger)index;

- (CGFloat)k9_roulette:(K9Roulette *)roulette angleAtIndex:(NSInteger)index;

- (CFTimeInterval)k9_durationOfBeginRotationInRoulette:(K9Roulette *)roulette;

- (CFTimeInterval)k9_durationOfRotationInRoulette:(K9Roulette *)roulette;

- (CFTimeInterval)k9_durationOfStopRotationInRoulette:(K9Roulette *)roulette;

- (NSArray *)k9_valuesOfBeginRotationInRoulette:(K9Roulette *)roulette fromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle;

- (NSArray <NSNumber *> *)k9_keyTimesOfBeginRotationInRoulette:(K9Roulette *)roulette;

- (NSArray <CAMediaTimingFunction *> *)k9_timingFunctionsOfBeginRotationInRoulette:(K9Roulette *)roulette;

- (NSArray *)k9_valuesOfStopRotationInRoulette:(K9Roulette *)roulette fromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle;

- (NSArray <NSNumber *> *)k9_keyTimesOfStopRotationInRoulette:(K9Roulette *)roulette;

- (NSArray <CAMediaTimingFunction *> *)k9_timingFunctionsOfStopRotationInRoulette:(K9Roulette *)roulette;

@end

@interface K9Roulette : UIView

@property (nonatomic, weak) id<K9RouletteDataSource>    k9_dataSource;
@property (nonatomic, weak) id<K9RouletteDelegate>      k9_delegate;

- (void)k9_reloadData;

- (void)k9_beginRotation;

- (void)k9_stopRotationAtIndex:(NSInteger)index;

@end
