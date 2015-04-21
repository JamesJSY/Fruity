//
//  GlobalVariables.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalVariables : NSObject
{
    int screenWidth;
    int screenHeight;
    UIFont *font;
    UIColor *blueColor;
    UIColor *softWhiteColor;
    UIColor *darkGreyColor;
    UIColor *lightGreyColor;
    UIColor *pinkColor;
}

@property (nonatomic) int screenWidth;
@property (nonatomic) int screenHeight;
@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *blueColor;
@property (nonatomic) UIColor *softWhiteColor;
@property (nonatomic) UIColor *darkGreyColor;
@property (nonatomic) UIColor *lightGreyColor;
@property (nonatomic) UIColor *pinkColor;

+ (GlobalVariables *)getInstance;

@end
