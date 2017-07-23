//
//  OMMTaskDetailTableVC.h
//  ToDoList
//
//  Created by Admin on 12.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+OMMDateConverter.h"
#import "OMMDatepickerViewController.h"
#import "OMMTaskService.h"


@interface OMMTaskDetailTableVC : UITableViewController <OMMDatepickerViewControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) OMMTask *task;
@property (strong, nonatomic) OMMTasksGroup *taskGroup;

- (void)viewControllerDidDoneAction:(OMMDatepickerViewController *)sender;
- (void)viewControllerDidCancelAction:(OMMDatepickerViewController *)sender;

@end
