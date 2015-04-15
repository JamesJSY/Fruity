//
//  CalendarViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/13/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "CalendarViewController.h"

@interface CalendarViewController ()

@property CGRect screenRect;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the screen resolution
    self.screenRect = [[UIScreen mainScreen] bounds];
    
    // Initialize the calendar view
    UIScrollView *calendarView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, self.screenRect.size.width, self.screenRect.size.height * 2 / 3 - 20)];
    calendarView.backgroundColor = self.view.backgroundColor;
    
    // Initialize the bottom view
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.screenRect.size.height * 2 / 3, self.screenRect.size.width, self.screenRect.size.height * 1 / 3)];
    bottomView.backgroundColor = [UIColor colorWithRed:(CGFloat)244/255 green:(CGFloat)244/255 blue:(CGFloat)205/255 alpha:1];
    
    [self.view addSubview:calendarView];
    [self.view addSubview:bottomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
