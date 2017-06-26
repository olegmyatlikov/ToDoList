//
//  OMMTodayTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 22/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMTodayTableViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "UIView+OMMHeaderInSection.h"
#import "OMMTaskService.h"
#import "OMMTasksGroup.h"
#import "OMMTask.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMTodayTableViewController ()

@property (strong, nonatomic) OMMTaskService *taskService;
@property (strong, nonatomic) NSMutableArray *allTodayTasks;
@property (strong, nonatomic) NSMutableArray *openTasksArray;
@property (strong, nonatomic) NSMutableArray *closeTaskArray;

@end

@implementation OMMTodayTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskService = [OMMTaskService sharedInstance];
    [self prepareDataForTableView];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskWasCreatedOrEdited:) name:@"TaskWasCreatedOrEdited" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerGroupWasDeleted) name:@"GroupWasDeleted" object:nil];
}


- (void)prepareDataForTableView {
    self.allTodayTasks = [self allTodayTasksInTasksArray:self.taskService.allTasksArray];
    self.openTasksArray = [self allOpenTasksInArray:self.allTodayTasks];
    self.closeTaskArray = [self allCloseTasksInArray:self.allTodayTasks];
}

- (void)triggerTaskWasCreatedOrEdited:(NSNotification *)notification {
    [self prepareDataForTableView];
    [self.tableView reloadData];
}

- (void)triggerGroupWasDeleted {
    [self prepareDataForTableView];
    [self.tableView reloadData];
}


#pragma mark - helpers methods

- (IBAction)addNewTaskButtonPressed:(UIBarButtonItem *)sender {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    [self.navigationController pushViewController:taskDetails animated:YES];
}

- (NSMutableArray *)allOpenTasksInArray:(NSMutableArray *)array {
    NSMutableArray *openTasksArray = [[NSMutableArray alloc] init];
    NSPredicate *openTaskPredicate = [NSPredicate predicateWithFormat:@"closed = 0"];
    openTasksArray = [[array filteredArrayUsingPredicate:openTaskPredicate] mutableCopy];
    return openTasksArray;
}

- (NSMutableArray *)allCloseTasksInArray:(NSMutableArray *)array {
    NSMutableArray *closeTasksArray = [[NSMutableArray alloc] init];
    NSPredicate *closeTaskPredicate = [NSPredicate predicateWithFormat:@"closed = 1"];
    closeTasksArray = [[array filteredArrayUsingPredicate:closeTaskPredicate] mutableCopy];
    return closeTasksArray;
}

- (NSMutableArray *)allTodayTasksInTasksArray:(NSArray *)tasksArray {
    NSMutableArray *allTodayTasks = [[NSMutableArray alloc] init];
    for (OMMTask *task in tasksArray) {
        if ([[task.startDate convertToStringForCompareDate] isEqualToString:[[NSDate date] convertToStringForCompareDate]]) {
                [allTodayTasks addObject:task];
        }
    }
    
    return allTodayTasks;
}


#pragma mark - Setup UI for tableView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else if (section == 0) {
        return 25.f;
    } else {
        return 50.f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    return [UIView createViewForHeaderInSection:tableView withTitle:sectionTitle];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}


#pragma mark - Setup data for tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    } else {
        return @"Complited";
    }
}

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


#pragma mark - edit the row

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Done" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[self.openTasksArray objectAtIndex:indexPath.row] setClosed:YES];
        [self.closeTaskArray addObject:[self.openTasksArray objectAtIndex:indexPath.row]];
        [self.openTasksArray removeObjectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskWasCreatedOrEdited" object:self];
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete the task" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            OMMTask *taskForDelete = [[OMMTask alloc] init];
            if (indexPath.section == 0) {
                taskForDelete = [self.openTasksArray objectAtIndex:indexPath.row];
                [self.openTasksArray removeObject:taskForDelete];
            } else {
                taskForDelete = [self.closeTaskArray objectAtIndex:indexPath.row];
                [self.closeTaskArray removeObject:taskForDelete];
            }
            [self.taskService removeTask:taskForDelete];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationFade];
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

@end
