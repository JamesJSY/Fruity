//
//  AddReminderViewController.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/14/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddReminderViewController : UIViewController

@property NSDate *date;
@property bool didClickDelete;
@property (nonatomic) bool isFromAddButton;

@end
