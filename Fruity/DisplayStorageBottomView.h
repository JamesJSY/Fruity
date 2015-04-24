//
//  DisplayStorageBottomView.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DisplayStorageBottomViewDelegate

- (NSArray *) loadAllFruitsInStorageFromDB;
- (void) deleteFruitItemWithID:(int) ID;
- (void) eatFruitItemWithID:(int) ID;

@end

@interface DisplayStorageBottomView : UIView
{
    id <DisplayStorageBottomViewDelegate> _superViewDelegate;
}
@property (nonatomic) id <DisplayStorageBottomViewDelegate> superViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)loadDisplayStorageBottomView;
- (void)mainViewDidMoveDown;

@end
