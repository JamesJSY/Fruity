//
//  FruitTouchButton.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FruitItem.h"

@interface FruitTouchButton : UIButton

@property FruitItem *fruitItem;
@property int numberOfFruits;

- (instancetype)init;

@end
