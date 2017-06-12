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


@interface OMMTaskDetailTableVC : UITableViewController

@property (strong, nonatomic) OMMTask *task;

@end
