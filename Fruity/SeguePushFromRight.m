//
//  SeguePushFromRight.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/13/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "SeguePushFromRight.h"

@implementation SeguePushFromRight

- (void)perform {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIView *sourceView = [self.sourceViewController view];
    UIView *destinationView = [self.destinationViewController view];
    destinationView.frame = CGRectMake(screenRect.size.width, 0, screenRect.size.width, screenRect.size.height);
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window insertSubview:destinationView aboveSubview:sourceView];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         destinationView.frame = CGRectOffset(destinationView.frame, -screenRect.size.width, 0);
                     }
                     completion:^(BOOL finished) {
                         [self.sourceViewController presentViewController:self.destinationViewController animated:NO completion:nil];
                     }];
}

@end
