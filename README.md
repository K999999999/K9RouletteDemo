This is a roulette with support for same or different angle.

## Requirements

- iOS 8.0 or later

## How To Use

```objective-c
Objective-C:

#import <K9Roulette.h>
...

K9Roulette *roulette = [[K9Roulette alloc] init];
roulette.k9_dataSource = self;

...

- (NSInteger)k9_numberOfSectorInRoulette:(K9Roulette *)roulette {
    ...
}

- (UIView *)k9_roulette:(K9Roulette *)roulette viewAtIndex:(NSInteger)index {
    ...
}

```

#### Podfile
```
platform :ios, '8.0'
pod 'K9Roulette', '~> 0.0.1'
```

## Author
- [K999999999](https://github.com/K999999999)

## Licenses

All source code is licensed under the [MIT License](https://github.com/K999999999/K9RouletteDemo/LICENSE).
