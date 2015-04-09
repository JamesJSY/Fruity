//
//  ViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/5/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property UIView *fruitsInHandView;
@property UIView *fruitsAddView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.fruitsInHandView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width , screenRect.size.height / 2)];
    self.fruitsInHandView.backgroundColor = [UIColor blueColor];
    
    self.fruitsAddView = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height / 2, screenRect.size.width , screenRect.size.height / 2)];
    self.fruitsAddView.backgroundColor = [UIColor orangeColor];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
