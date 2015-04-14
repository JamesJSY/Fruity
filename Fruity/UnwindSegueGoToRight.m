//
//  UnwindSegueGoToRight.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/13/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "UnwindSegueGoToRight.h"

@implementation UnwindSegueGoToRight

- (void)perform {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    // Add view to super view temporarily
    [sourceViewController.view.superview insertSubview:destinationViewController.view atIndex:0];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         sourceViewController.view.frame = CGRectOffset(sourceViewController.view.frame, screenRect.size.width, 0);
                     }
                     completion:^(BOOL finished){
                         [destinationViewController.view removeFromSuperview];
                         [sourceViewController dismissViewControllerAnimated:NO completion:NULL];
                     }];
    
    
    /*
    UIView *sourceView = [self.sourceViewController view];
    UIView *destinationView = [self.destinationViewController view];
    destinationView.frame = CGRectMake(-screenRect.size.width, 0, screenRect.size.width, screenRect.size.height);
    
    //[[sourceView superview] insertSubview:destinationView atIndex:0];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window insertSubview:destinationView belowSubview:sourceView];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         sourceView.frame = CGRectOffset(sourceView.frame, screenRect.size.width, 0);
                         //destinationView.frame = CGRectOffset(destinationView.frame, -screenRect.size.width, 0);
                     }
                     completion:^(BOOL finished) {
                         [destinationView  removeFromSuperview];
                         [self.sourceViewController dismissViewControllerAnimated:NO completion:NULL];
                     }];*/
}

@end
