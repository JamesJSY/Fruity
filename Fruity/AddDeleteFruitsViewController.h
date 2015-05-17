//
//  AddDeleteFruitsViewController.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplaySeasonalFruitsScrollView.h"
#import "AddFruitBottomView.h"
#import "DisplayStorageBottomView.h"
#import "DisplaySearchBarView.h"
#import "DisplayCalendarHistoryView.h"

@interface AddDeleteFruitsViewController : UIViewController <DisplaySeasonalFruitsScrollViewDelegate,AddFruitBottomViewDelegate, DisplayStorageBottomViewDelegate, DisplaySearchBarViewDelegate, DisplayCalendarHistoryViewDelegate>

@end
