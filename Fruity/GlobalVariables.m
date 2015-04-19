//
//  GlobalVariables.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "GlobalVariables.h"

@implementation GlobalVariables

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize font;

static GlobalVariables *instance = nil;

+ (GlobalVariables *)getInstance {
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [[GlobalVariables alloc] init];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            instance.screenWidth = screenRect.size.width;
            instance.screenHeight = screenRect.size.height;
            instance.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:16];
        }
    }
    return instance;
}

@end
