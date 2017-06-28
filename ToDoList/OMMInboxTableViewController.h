//
//  OMMInboxTableViewController.h
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMMTasksGroup.h"

@interface OMMInboxTableViewController : UITableViewController

@property (strong, nonatomic) OMMTasksGroup *tasksGroup; // if we came from ToDoList tab with tap in group 

@end
