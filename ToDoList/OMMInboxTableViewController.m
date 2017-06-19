//
//  OMMInboxTableViewController.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMInboxTableViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "OMMTask.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMInboxTableViewController ()

@property (strong, nonatomic) NSMutableArray* tasksArray;
@property (strong, nonatomic) NSMutableArray* openTasksArray;
@property (strong, nonatomic) NSMutableArray* closeTaskArray;

@end

@implementation OMMInboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tasksArray = [[NSMutableArray alloc] init];
    
    OMMTask *testTask = [[OMMTask alloc] init];
    testTask.name = @"Natalli";
    testTask.note = @"Notes natalli";
    testTask.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    OMMTask *testTask2 = [[OMMTask alloc] init];
    testTask2.name = @"Oleg";
    testTask2.closed = NO;
    testTask2.note = @"notes oleg";
    testTask2.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    OMMTask *testTask3 = [[OMMTask alloc] init];
    testTask3.name = @"Bogdan";
    testTask3.note = @"notes bogdan";
    testTask3.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    self.tasksArray = [[NSMutableArray alloc] initWithObjects:testTask, testTask2, testTask3, nil];
    
    [self sortByCloseStatus];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskWasCreatedOrEdited:) name:@"TaskWasCreatedOrEdited" object:nil];
}

- (void)triggerTaskWasCreatedOrEdited:(NSNotification *)notification {
    NSDictionary *dictWithTask = notification.userInfo;
    OMMTask *newTask = [dictWithTask valueForKey:@"message"];
    
    if ([[dictWithTask valueForKey:@"status"] isEqual:@"new"]) {
        [self.openTasksArray addObject:newTask];
    } else { // if edited - find and replace task
        for (int i = 0; i < [self.tasksArray count]; i++) {
            OMMTask *task = self.tasksArray[i];
            if (task.taskID == newTask.taskID) {
                [self.tasksArray replaceObjectAtIndex:i withObject:newTask];
            }
        }
    }
    [self.tableView reloadData];
}

- (IBAction)addNewTaskButtonPressed:(UIBarButtonItem *)sender {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    [self.navigationController pushViewController:taskDetails animated:YES];
}

- (void)sortByCloseStatus {
    NSPredicate *openTaskPredicate = [NSPredicate predicateWithFormat:@"closed = 0"];
    NSPredicate *closedTaskPredicate = [NSPredicate predicateWithFormat:@"closed = 1"];
    self.openTasksArray = [[self.tasksArray filteredArrayUsingPredicate:openTaskPredicate] mutableCopy];
    self.closeTaskArray = [[self.tasksArray filteredArrayUsingPredicate:closedTaskPredicate] mutableCopy];
}

//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    [super setEditing:editing animated:animated];
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    } else {
        return @"Closed Tasks";
    }
}

#pragma mark - sections header setup

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if (section == 0 || [tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 50.f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 50.0f)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, tableView.bounds.size.width, 20)];
    
    headerView.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    headerLabel.textColor = [UIColor grayColor];
    headerLabel.text = sectionTitle;
    
    [headerView addSubview:headerLabel];
    return headerView;
}

#pragma mark - cells setup

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.openTasksArray.count;
    } else {
        return self.closeTaskArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"OMMTaskCell" bundle:nil] forCellReuseIdentifier:@"OMMTaskCellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    }
    OMMTask *task = [[OMMTask alloc] init];
    if (indexPath.section == 0) {
        task = [self.openTasksArray objectAtIndex:indexPath.row];
    } else {
        task = [self.closeTaskArray objectAtIndex:indexPath.row];
    }
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToString];

 return cell;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}

#pragma mark - edit the row


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Done" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [(OMMTask *)[self.openTasksArray objectAtIndex:indexPath.row] setClosed:YES];
        [self.closeTaskArray addObject:[self.openTasksArray objectAtIndex:indexPath.row]];
        [self.openTasksArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete the task" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (indexPath.section == 0) {
                [self.openTasksArray removeObjectAtIndex:indexPath.row];
            } else {
                [self.closeTaskArray removeObjectAtIndex:indexPath.row];
            }
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData]; // because without this line header of section not delete immediately
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [deleteAlertVC addAction:deleteAction];
        [deleteAlertVC addAction:closeAction];
        [self presentViewController:deleteAlertVC animated:YES completion:nil];
    }];
    
    if (indexPath.section == 0) {
        return @[deleteAction, doneAction];
    } else {
        return @[deleteAction];
    }
    
}


#pragma mark - Tap to cell

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    
    if (indexPath.section == 0) {
        OMMTask *openTask = [self.openTasksArray objectAtIndex:indexPath.row];
        taskDetails.task = openTask;
    } else {
        OMMTask *closedTask = [self.closeTaskArray objectAtIndex:indexPath.row];
        taskDetails.task = closedTask;
    }
    
    [self.navigationController pushViewController:taskDetails animated:YES];
}


#pragma mark - Delegate method

//- (void)addNewTaskInTaskArray:(OMMTask *)task {
//    [self.openTasksArray addObject:task];
//    [self.tableView reloadData];
//}
//
//- (void)saveChangesInTaskArray:(OMMTask *)editingTask {
//    [self.tableView reloadData];
//}


@end
