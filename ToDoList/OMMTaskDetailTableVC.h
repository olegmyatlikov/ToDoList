//
//  OMMTaskDetailTableVC.h
//  ToDoList
//
//  Created by Admin on 12.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMMTask.h"
#import "NSDate+OMMDateConverter.h"
#import "OMMDatepickerViewController.h"


@interface OMMTaskDetailTableVC : UITableViewController <OMMDatepickerViewControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) OMMTask *task;

- (void)setDateFromDatePickerVC:(OMMDatepickerViewController *)datePickerVC date:(NSString *)date;
- (void)showTabBar;

@end
