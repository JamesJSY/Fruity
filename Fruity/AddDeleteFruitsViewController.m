//
//  AddDeleteFruitsViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "AddDeleteFruitsViewController.h"

@interface AddDeleteFruitsViewController ()

@property CGRect screenRect;

@property UIScrollView *fruitsInHandView;
@property UIScrollView *fruitsAddView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;


@property NSArray *seasonalFruits;

@end

@implementation AddDeleteFruitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create two subview, one for displaying fruits bought and one for displaying what fruits can be added.
    self.screenRect = [[UIScreen mainScreen] bounds];
    self.fruitsInHandView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.screenRect.size.width , self.screenRect.size.height / 2)];
    self.fruitsInHandView.backgroundColor = [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)217/255 blue:(CGFloat)192/255 alpha:1];
    self.fruitsInHandView.contentSize = CGSizeMake(self.screenRect.size.width, self.screenRect.size.height);
    
    self.fruitsAddView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.screenRect.size.height / 2, self.screenRect.size.width , self.screenRect.size.height / 2)];
    self.fruitsAddView.backgroundColor = [UIColor colorWithRed:(CGFloat)244/255 green:(CGFloat)244/255 blue:(CGFloat)206/255 alpha:1];
    
    // Create settings button
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton addTarget:self action:@selector(goToSettingsView:) forControlEvents:UIControlEventTouchUpInside];
    self.settingsButton.frame = CGRectMake((float)self.screenRect.size.width - 30, 20.0f, 20.0f, 20.0f);
    self.settingsButton.adjustsImageWhenHighlighted = false;
    [self.settingsButton setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [self.fruitsInHandView addSubview:self.settingsButton];
    
    // Create calendar button
    self.calendarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.calendarButton addTarget:self action:@selector(goToCalendarView:) forControlEvents:UIControlEventTouchUpInside];
    self.calendarButton.frame = CGRectMake(10.0f, 20.0f, 20.0f, 20.0f);
    self.calendarButton.adjustsImageWhenHighlighted = false;
    [self.calendarButton setImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
    [self.fruitsInHandView addSubview:self.calendarButton];
    
    // Load seasonal fruits into the FruitsAddView
    [self loadFruitsAddViewWitnSeasonalFruits];
    
    [self.view addSubview:self.fruitsInHandView];
    [self.view addSubview:self.fruitsAddView];
}

-(void)goToSettingsView:(UIButton*)settingsButton {
    
}

-(void)goToCalendarView:(UIButton*)calendarButton {
    
}

-(void)addFruitsToDatabase:(UIButton*)inputFruit {
    
}

-(void)loadFruitsAddViewWitnSeasonalFruits {
    UIButton *apple = [UIButton buttonWithType:UIButtonTypeCustom];
    [apple addTarget:self action:@selector(addFruitsToDatabase:) forControlEvents:UIControlEventTouchUpInside];
    [apple setImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
    
    UIButton *orange = [UIButton buttonWithType:UIButtonTypeCustom];
    [apple addTarget:self action:@selector(addFruitsToDatabase:) forControlEvents:UIControlEventTouchUpInside];
    [orange setImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
    
    self.seasonalFruits = [[NSArray alloc] initWithObjects:apple, orange, nil];
    
    // Display all seasonal fruits
    for (int i = 0; i < self.seasonalFruits.count; i++) {
        UIButton *fruitButton = self.seasonalFruits[i];
        fruitButton.frame = CGRectMake(20.0f, 60.0f +(float)i * 250, 40.0f, 200.0f);
        [self.fruitsInHandView addSubview:fruitButton];
    }
    
    self.fruitsInHandView.contentSize = CGSizeMake(self.screenRect.size.width, self.seasonalFruits.count * 200 + 125);
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
