//
//  ViewController.m
//  K9RouletteDemo
//
//  Created by K999999999 on 2017/7/5.
//  Copyright © 2017年 K999999999. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import <SoundManager.h>
#import "K9Roulette.h"

@interface ViewController () <K9RouletteDataSource, K9RouletteDelegate>

@property (nonatomic)           BOOL                    sameAngle;
@property (nonatomic, strong)   NSArray <UIColor *>     *colors;
@property (nonatomic, strong)   NSArray <NSNumber *>    *angles;
@property (nonatomic, strong)   K9Roulette              *roulette;
@property (nonatomic, strong)   UIButton                *angleButton;
@property (nonatomic, strong)   UIButton                *rotationButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.sameAngle = YES;
    
    [self configViews];
}

#pragma mark - Config Views

- (void)configViews {
    
    [self configRoulette];
    [self configAngleButton];
    [self configRotationButton];
}

- (void)configRoulette {
    
    if (self.roulette.superview) {
        return;
    }
    
    [self.view addSubview:self.roulette];
    [self.roulette mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)configAngleButton {
    
    if (self.angleButton.superview) {
        return;
    }
    
    [self.view addSubview:self.angleButton];
    [self.angleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view).with.offset(-10.f);
        make.left.equalTo(self.view).with.offset(10.f);
        make.size.mas_equalTo(CGSizeMake(140.f, 44.f));
    }];
}

- (void)configRotationButton {
    
    if (self.rotationButton.superview) {
        return;
    }
    
    [self.view addSubview:self.rotationButton];
    [self.rotationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view).with.offset(-10.f);
        make.right.equalTo(self.view).with.offset(-10.f);
        make.size.mas_equalTo(CGSizeMake(140.f, 44.f));
    }];
}

#pragma mark <K9RouletteDataSource>

- (NSInteger)k9_numberOfSectorInRoulette:(K9Roulette *)roulette {
    return self.colors.count;
}

- (UIView *)k9_roulette:(K9Roulette *)roulette viewAtIndex:(NSInteger)index {
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = self.colors[index];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%ld", (long)index];
    return label;
}

#pragma mark <K9RouletteDelegate>

- (void)k9_rouletteDidRotateMinAngle:(K9Roulette *)roulette {
    [[SoundManager sharedManager] playSound:@"sound.mp3" looping:NO];
}

- (void)k9_roulette:(K9Roulette *)roulette didStopRotationAtIndex:(NSInteger)index {
    
    [[SoundManager sharedManager] stopAllSounds];
    NSLog(@"didStopRotationAtIndex:%ld", (long)index);
}

- (CGFloat)k9_roulette:(K9Roulette *)roulette angleAtIndex:(NSInteger)index {
    
    if (self.sameAngle) {
        return M_PI * 2.f / (double)self.colors.count;
    } else {
        return self.angles[index].floatValue;
    }
}

- (CFTimeInterval)k9_durationOfBeginRotationInRoulette:(K9Roulette *)roulette {
    return 1.f;
}

- (CFTimeInterval)k9_durationOfRotationInRoulette:(K9Roulette *)roulette {
    return .3f;
}

- (CFTimeInterval)k9_durationOfStopRotationInRoulette:(K9Roulette *)roulette {
    return 2.f;
}

#pragma mark - Action Methods

- (void)onAngleButton {
    
    self.sameAngle = !self.sameAngle;
    [self.angleButton setTitle:self.sameAngle ? @"Different Angle" : @"Same Angle" forState:UIControlStateNormal];
    [self.roulette k9_reloadData];
}

- (void)onRotationButton {
    
    [self.roulette k9_beginRotation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSInteger index = arc4random() % self.colors.count;
        [self.roulette k9_stopRotationAtIndex:index];
    });
}

#pragma mark - Getters

- (NSArray <UIColor *> *)colors {
    
    if (!_colors) {
        _colors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor]];
    }
    return _colors;
}

- (NSArray <NSNumber *> *)angles {
    
    if (!_angles) {
        _angles = @[@(M_PI * .1f), @(M_PI * .2f), @(M_PI * .3f), @(M_PI * .4f), @(M_PI * .1f), @(M_PI * .2f), @(M_PI * .2f), @(M_PI * .3f), @(M_PI * .2f)];
    }
    return _angles;
}

- (K9Roulette *)roulette {
    
    if (!_roulette) {
        
        _roulette = [[K9Roulette alloc] init];
        _roulette.k9_dataSource = self;
        _roulette.k9_delegate = self;
    }
    return _roulette;
}

- (UIButton *)angleButton {
    
    if (!_angleButton) {
        
        _angleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_angleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_angleButton setTitle:@"Different Angle" forState:UIControlStateNormal];
        _angleButton.layer.borderWidth = 1.f;
        _angleButton.layer.borderColor = [UIColor blackColor].CGColor;
        [_angleButton addTarget:self action:@selector(onAngleButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _angleButton;
}

- (UIButton *)rotationButton {
    
    if (!_rotationButton) {
        
        _rotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rotationButton setTitle:@"Rotation" forState:UIControlStateNormal];
        _rotationButton.layer.borderWidth = 1.f;
        _rotationButton.layer.borderColor = [UIColor blackColor].CGColor;
        [_rotationButton addTarget:self action:@selector(onRotationButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotationButton;
}

@end
