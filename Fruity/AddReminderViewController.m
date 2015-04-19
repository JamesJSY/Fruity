//
//  AddReminderViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/14/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "AddReminderViewController.h"

@interface AddReminderViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *myDatepicker;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation AddReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myDatepicker.datePickerMode = UIDatePickerModeTime;
    self.myDatepicker.date = self.date;
    self.didClickDelete = false;
    if (self.isFromAddButton) {
        [self.deleteButton setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender == self.saveButton) {
        self.date = self.myDatepicker.date;
    }
    else if (self.isFromAddButton) {
        self.date = nil;
    }
    else if (self.deleteButton) {
        self.didClickDelete = YES;
    }
}


@end
