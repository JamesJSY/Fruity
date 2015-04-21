//
//  FruitTouchButton.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "FruitTouchButton.h"

@implementation FruitTouchButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fruitItem = [[FruitItem alloc] init];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
