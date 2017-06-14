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

@end

@implementation OMMInboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tasksArray = [[NSMutableArray alloc] init];
    
    OMMTask *testTask = [[OMMTask alloc] init];
    testTask.name = @"task1";
    testTask.note = @"task1 notes";
    testTask.startDate = [NSDate convertStringToDate:@"10-07-2017 10:30"];
    testTask.finishDate = [NSDate convertStringToDate:@"11-07-2017 12:00"];
    testTask.priority = low;
    testTask.enableRemainder = NO;
    [self.tasksArray addObject:testTask];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskWasCreatedOrEdited:) name:@"TaskWasCreatedOrEdited" object:nil];
}

- (void)triggerTaskWasCreatedOrEdited:(NSNotification *)notification {
    NSDictionary *dictWithTask = notification.userInfo;
    OMMTask *newTask = [dictWithTask valueForKey:@"message"];
    
    if ([[dictWithTask valueForKey:@"status"] isEqual:@"new"]) {
        [self.tasksArray addObject:newTask];
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

//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//    [super setEditing:editing animated:animated];
//}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tasksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"OMMTaskCell" bundle:nil] forCellReuseIdentifier:@"OMMTaskCellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    }
    
    OMMTask *task = [self.tasksArray objectAtIndex:indexPath.row];
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskFinishDate.text = [task.finishDate convertDateToString];

 return cell;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}

#pragma mark - edit the row

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Done" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [(OMMTask *)[self.tasksArray objectAtIndex:indexPath.row] setClosed:YES];
        tableView.editing = NO;
        
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete the task" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.tasksArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [deleteAlertVC addAction:deleteAction];
        [deleteAlertVC addAction:closeAction];
        [self presentViewController:deleteAlertVC animated:YES completion:nil];
    }];
    
    return @[deleteAction, doneAction];
}


#pragma mark - Tap to cell

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTask *task = [self.tasksArray objectAtIndex:indexPath.row];
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    taskDetails.task = task;
    [self.navigationController pushViewController:taskDetails animated:YES];
}


#pragma mark - Delegate method

- (void)addNewTaskInTaskArray:(OMMTask *)task {
    [self.tasksArray addObject:task];
    [self.tableView reloadData];
}

- (void)saveChangesInTaskArray:(OMMTask *)editingTask {
    [self.tableView reloadData];
}


@end
