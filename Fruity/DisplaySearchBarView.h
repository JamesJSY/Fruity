//
//  DisplaySearchBarView.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/20/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DisplaySearchBarViewDelegate

- (void)addFruitToDBFromSearchBar:(NSString*)fruitName;

@end

@interface DisplaySearchBarView : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    id <DisplaySearchBarViewDelegate> _superViewDelegate;
}
@property id <DisplaySearchBarViewDelegate> superViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end
