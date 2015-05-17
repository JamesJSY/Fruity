//
//  DisplayCalendarHistoryView.h
//  Fruity
//
//  Created by Shiyuan Jiang on 5/11/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DisplayCalendarHistoryViewDelegate

- (void) clickOnTheViewToQuitShowingStorageList;

@end

@interface DisplayCalendarHistoryView : UIView {
    id <DisplayCalendarHistoryViewDelegate> _delegate;
}
@property (nonatomic) id <DisplayCalendarHistoryViewDelegate> delegate;

- (void) reloadEatenFruitHistory;

- (instancetype) initWithFrame:(CGRect)frame;

- (void) superViewDidShowBottomStorageView;

@end
