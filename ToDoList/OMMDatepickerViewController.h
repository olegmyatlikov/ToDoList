//
//  OMMDatepickerViewController.h
//  ToDoList
//
//  Created by Admin on 04.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateSetDelegate;


@interface OMMDatepickerViewController : UIViewController

@property (strong, nonatomic) NSDate *selectedDate;
@property (weak, nonatomic) id <DateSetDelegate> delegate;

@end


@protocol DateSetDelegate <NSObject>

- (void)sendDateToTaskViewController:(NSString *)textForButtonTitle;
- (void)showTabBar;

@end


