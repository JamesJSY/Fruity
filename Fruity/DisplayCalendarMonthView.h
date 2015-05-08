//
//  DisplayCalendarMonthView.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/27/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DisplayCalendarMonthViewDelegate

- (void)reloadSuperViewWithChangeOfMonthView:(id)view willDisplayDays:(bool)isDisplayingDays;

@end

@interface DisplayCalendarMonthView : UIView {
    id <DisplayCalendarMonthViewDelegate> _delegate;
}
@property id <DisplayCalendarMonthViewDelegate> delegate;

- (instancetype) initWithFrame:(CGRect)frame date:(NSDate*)currDate willDisplayDays:(bool)willDisplayDays;

- (void)setWillDisplayDaysToNO;
- (void)setWillDisplayDaysToYES;

@end
