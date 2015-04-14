//
//  SettingsViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/11/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property CGRect screenRect;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *notificationsView;

@property NSMutableArray *notificationRemindTimes;
@property NSUserDefaults *userPreference;

@property NSMutableArray *allReminderTextFields;

// Formatter that is used to transform date to string
@property NSDateFormatter *dateFormatter;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the screen resolution
    self.screenRect = [[UIScreen mainScreen] bounds];
    
    // Initialize the formatter to transform date to string
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"hh:mm a"];

    
    // Initialize the user preference
    self.userPreference = [[NSUserDefaults alloc] init];
    
    // Set a reminder at 10:00 the first launching the app
    if ([self.userPreference objectForKey:@"notificationRemindTimes"] == nil) {
        // Set the initial reminder time to 10:00
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents * comps = [[NSDateComponents alloc] init];
        [comps setHour:10];
        [comps setMinute:0];
        NSDate *date = [cal dateFromComponents:comps];
        
        NSMutableArray *reminders = [[NSMutableArray alloc] initWithObjects:date, nil];
        [self.userPreference setObject:reminders forKey:@"notificationRemindTimes"];
    }
    
    // Set profile image to be circle-shaped
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
    self.profileImageView.clipsToBounds = YES;
    
    // Load data from userDefaults
    [self loadUserPreference];
    
    // Display each notification reminder set by users
    [self displayNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserPreference {
    self.notificationRemindTimes = [[NSMutableArray alloc] initWithArray:[self.userPreference objectForKey:@"notificationRemindTimes"]];
    
    if ([self.userPreference objectForKey:@"remindTimeWhenIgnored"] == nil) {
        [self.userPreference setValue:@"30" forKey:@"remindTimeWhenIgnored"];
    }
}

- (void)displayNotifications {
    // Remove all subviews currently in the notificationsView
    [self.notificationsView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    // Set Font for the text
    UIFont *font = [UIFont fontWithName:@"AvenirLTStd-Light" size:16];
    
    // Reinitialize the array of all remind time text fields
    [self.allReminderTextFields removeAllObjects];
    self.allReminderTextFields = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.notificationRemindTimes count]; i++) {
        // Initialize the reminder text view
        UITextView *reminderTextView = [[UITextView alloc] init];
        reminderTextView.text = @"Push reminder on";
        reminderTextView.font = font;
        reminderTextView.textColor = [UIColor colorWithRed:255/255 green:0/255 blue:0/255 alpha:1];
        reminderTextView.textAlignment = NSTextAlignmentRight;
        reminderTextView.frame = CGRectMake(0, 30 + i * 50, self.screenRect.size.width * 1 / 2, 30);
        reminderTextView.backgroundColor = [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)217/255 blue:(CGFloat)194/255 alpha:1];
        
        // Initialize the reminder time text field
        UITextField *reminderTimeTextField = [[UITextField alloc] init];
        
        reminderTimeTextField.text = [self.dateFormatter stringFromDate:self.notificationRemindTimes[i]];
        reminderTimeTextField.font = font;
        reminderTimeTextField.textAlignment = NSTextAlignmentCenter;
        reminderTimeTextField.backgroundColor = [UIColor colorWithRed:(CGFloat)239/255 green:(CGFloat)245/255 blue:(CGFloat)207/255 alpha:1];
        reminderTimeTextField.frame = CGRectMake(self.screenRect.size.width * 1 / 2 + 30, 35 + i * 50, self.screenRect.size.width / 5, 30);
        reminderTimeTextField.layer.cornerRadius = 5;
        [self.allReminderTextFields addObject:reminderTimeTextField];
        
        // Initializ the date pick as the input view for reminder time text field
        UIDatePicker *reminderTimeDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        reminderTimeDatePicker.datePickerMode = UIDatePickerModeTime;
        [reminderTimeDatePicker addTarget:self action:@selector(reminderTimeDatePickerValueDidUpdate:) forControlEvents:UIControlEventValueChanged];
        [reminderTimeDatePicker setDate:self.notificationRemindTimes[i] animated:YES];
        reminderTimeDatePicker.tag = i;
        reminderTimeTextField.inputView = reminderTimeDatePicker;
        
        // Initialize the red decriptionButton
        UIButton *descriptionButton = [[UIButton alloc] init];
        descriptionButton.frame = CGRectMake(reminderTimeTextField.frame.origin.x + self.screenRect.size.width / 5 - 10, 25 + i * 50, 20, 20);
        [descriptionButton setImage:[UIImage imageNamed:@"questionmark.png"] forState:UIControlStateNormal];
        [descriptionButton addTarget:self action:@selector(displayTips:) forControlEvents:UIControlEventTouchUpInside];
        descriptionButton.tag = i;
        
        // Initialize the delete button if it is not the last row
        if (i < [self.notificationRemindTimes count] - 1) {
            UIButton *deleteReminderButton = [[UIButton alloc] init];
            deleteReminderButton.frame = CGRectMake(self.screenRect.size.width - 65, 33.5 + i * 50, 30, 30);
            [deleteReminderButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
            [deleteReminderButton addTarget:self action:@selector(deleteReminder:) forControlEvents: UIControlEventTouchUpInside];
            deleteReminderButton.tag = i;
            [self.notificationsView addSubview:deleteReminderButton];
        }
        
        // Initialize the add button if it is the last row
        if (i == [self.notificationRemindTimes count] - 1) {
            UIButton *addReminderButton = [[UIButton alloc] init];
            addReminderButton.frame = CGRectMake(self.screenRect.size.width - 65, 33.5 + i * 50, 30, 30);
            [addReminderButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
            [addReminderButton addTarget:self action:@selector(addReminder:) forControlEvents: UIControlEventTouchUpInside];
            [self.notificationsView addSubview:addReminderButton];
        }
    
        [self.notificationsView addSubview:reminderTextView];
        [self.notificationsView addSubview:reminderTimeTextField];
        [self.notificationsView addSubview:descriptionButton];
    }
    
    // Initialize the ignore reminder text view
    UITextView *ignoreReminderText = [[UITextView alloc] init];
    ignoreReminderText.text = @"When ignored, remind me";
    ignoreReminderText.textAlignment = NSTextAlignmentLeft;
    ignoreReminderText.font = font;
    ignoreReminderText.frame = CGRectMake(30, 50 + [self.notificationRemindTimes count] * 50, self.screenRect.size.width * 3 / 4, 30);
    ignoreReminderText.backgroundColor = [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)217/255 blue:(CGFloat)194/255 alpha:1];
    
    // Initialize the ignore reminder text view 2
    UITextView *ignoreReminderText2 = [[UITextView alloc] init];
    ignoreReminderText2.text = @"mins later";
    ignoreReminderText2.font = font;
    ignoreReminderText2.textAlignment = NSTextAlignmentLeft;
    ignoreReminderText2.frame = CGRectMake(30, 90 + [self.notificationRemindTimes count] * 50, self.screenRect.size.width * 1 / 2, 30);
    ignoreReminderText2.backgroundColor = [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)217/255 blue:(CGFloat)194/255 alpha:1];
    
    // Initialize the ignore reminder text field
    UITextField *ignoreReminderTimeTextField = [[UITextField alloc] init];
    ignoreReminderTimeTextField.text = [self.userPreference objectForKey:@"remindTimeWhenIgnored"];
    ignoreReminderTimeTextField.font = font;
    ignoreReminderTimeTextField.textAlignment = NSTextAlignmentCenter;
    ignoreReminderTimeTextField.backgroundColor = [UIColor colorWithRed:(CGFloat)239/255 green:(CGFloat)245/255 blue:(CGFloat)207/255 alpha:1];
    ignoreReminderTimeTextField.frame = CGRectMake(self.screenRect.size.width * 3 / 4 - 25, 55 + [self.notificationRemindTimes count] * 50, self.screenRect.size.width / 5, 30);
    ignoreReminderTimeTextField.layer.cornerRadius = 5;
    [ignoreReminderTimeTextField addTarget:self action:@selector(ignoreReminderTimeTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.notificationsView addSubview:ignoreReminderText];
    [self.notificationsView addSubview:ignoreReminderText2];
    [self.notificationsView addSubview:ignoreReminderTimeTextField];
}

- (void)ignoreReminderTimeTextFieldDidChange:(UITextField*) textField{
    [self.userPreference setValue:textField.text forKey:@"remindTimeWhenIgnored"];
}

- (void)reminderTimeDatePickerValueDidUpdate:(UIDatePicker*) datePicker{
    // Update the related remind time text field
    UITextField *textField = self.allReminderTextFields[datePicker.tag];
    textField.text = [self.dateFormatter stringFromDate:datePicker.date];
    
    // Update the date at index of datePicker.tag in notificationRemindTimes array
    [self.notificationRemindTimes replaceObjectAtIndex:datePicker.tag withObject:datePicker.date];
    
    // Update the stored object in the userPreference
    [self.userPreference setObject:self.notificationRemindTimes forKey:@"notificationRemindTimes"];
}

- (void)addReminder:(UIButton*)addButton {
    // Add one reminder
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.hour = 1;
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate: [NSDate date] options:0];
    [self.notificationRemindTimes addObject:date];
    
    // Update stored object in the userPreference
    [self.userPreference setObject:self.notificationRemindTimes forKey:@"notificationRemindTimes"];
    
    // Reload the scroll View
    [self displayNotifications];
}

- (void)deleteReminder:(UIButton*)deleteButton {
    // Delete the row from deleteButton.tag
    [self.notificationRemindTimes removeObjectAtIndex:deleteButton.tag];
    
    // Update stored object in the userPreference
    [self.userPreference setObject:self.notificationRemindTimes forKey:@"notificationRemindTimes"];
    
    // Reload the scroll View
    [self displayNotifications];
}

- (void)displayTips:(UIButton*)descriptionButton {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"Poped!");
}
*/

@end
