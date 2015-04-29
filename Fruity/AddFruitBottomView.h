//
//  AddFruitBottomView.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddFruitBottomViewDelegate

- (void)addFruitsToDatabaseWithQuantity:(UIButton *)button;

@end

@interface AddFruitBottomView : UIView {
    
    id <AddFruitBottomViewDelegate> _superViewDelegate;
}
@property (nonatomic) id <AddFruitBottomViewDelegate> superViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addButtonDidFinishPressing;

- (void)setUpQuantitiesWithQuantityBase:(int)base;

@end
