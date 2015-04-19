//
//  DisplaySeasonalFruitsScrollView.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FruitTouchButton.h"

@protocol DisplaySeasonalFruitsScrollViewDelegate

- (void)addFruitsToDatabase:(FruitTouchButton *)fruitButton;

@end

@interface DisplaySeasonalFruitsScrollView : UIScrollView
{
    
    id <DisplaySeasonalFruitsScrollViewDelegate> _superViewDelegate;
    
}
@property (nonatomic) id <DisplaySeasonalFruitsScrollViewDelegate> superViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)loadViewWithSeasonalFruitsBasicInfo:(NSMutableArray *)allFruitsBasicInfo withMonth:(int) month;

- (void)highlightOneFruitTouchButton:(FruitTouchButton *)fruitButton;
- (void)deHighlightFruitTouchButton;

- (void) disableAllFruitTouchButtonsInteraction;
- (void) enableAllFruitTouchButtonsInteraction;

@end
