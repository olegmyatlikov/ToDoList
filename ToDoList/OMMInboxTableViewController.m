//
//  OMMInboxTableViewController.m
//  ToDoList
//
//  Created by Admin on 03.06.17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMInboxTableViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "UIView+OMMHeaderInSection.h"
#import "OMMTaskService.h"
#import "OMMTask.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMInboxTableViewController ()

@property (strong, nonatomic) OMMTaskService *taskService;
@property (strong, nonatomic) NSMutableArray *tasksGroupsArray;
@property (strong, nonatomic) NSMutableArray *openTasksArray;
@property (strong, nonatomic) NSMutableArray *closeTaskArray;

@end

@implementation OMMInboxTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskService = [OMMTaskService sharedInstance];
    self.tasksGroupsArray = [[NSMutableArray alloc] init];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    UISegmentedControl *segmentControlButtons = [[UISegmentedControl alloc] initWithItems:@[@"Group", @"Date"]];
    [segmentControlButtons setWidth:130.f forSegmentAtIndex:0];
    [segmentControlButtons setWidth:130.f forSegmentAtIndex:1];
    segmentControlButtons.center = headerView.center;
    segmentControlButtons.selectedSegmentIndex = 0;
    [headerView addSubview:segmentControlButtons];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (!self.tasksGroup) {
        self.tasksGroupsArray = [self.taskService.tasksGroupsArray mutableCopy];
        [self.tasksGroupsArray insertObject:self.taskService.inboxTasksGroup atIndex:0];
    } else {
        [self.tasksGroupsArray removeAllObjects];
        [self.tasksGroupsArray addObject:self.tasksGroup];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = backButtonItem;
        self.tableView.tableHeaderView = nil;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskWasCreatedOrEdited:) name:@"TaskWasCreatedOrEdited" object:nil];
}

- (void)triggerTaskWasCreatedOrEdited:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (IBAction)addNewTaskButtonPressed:(UIBarButtonItem *)sender {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    if (self.tasksGroupsArray.count == 1) { // if we in group not in inbox tab
        taskDetails.taskGroup = self.tasksGroupsArray[0];
    } else {
        taskDetails.taskGroup = self.taskService.inboxTasksGroup;
    }
    [self.navigationController pushViewController:taskDetails animated:YES];
}

- (void)backButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Setup UI for tableView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
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
    return self.tasksGroupsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    OMMTasksGroup *taskGroup = [self.tasksGroupsArray objectAtIndex:section];
    return taskGroup.groupName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    OMMTasksGroup *taskGroup = [self.tasksGroupsArray objectAtIndex:section];
    return taskGroup.tasksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"OMMTaskCell" bundle:nil] forCellReuseIdentifier:@"OMMTaskCellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskCellIdentifier"];
    }
    OMMTasksGroup *taskGroup = [self.tasksGroupsArray objectAtIndex:indexPath.section];
    OMMTask *task = [taskGroup.tasksArray objectAtIndex:indexPath.row];
    
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToString];

 return cell;
 }

#pragma mark - edit the row


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTasksGroup *taskGroup = [self.tasksGroupsArray objectAtIndex:indexPath.section];
    OMMTask *task = [taskGroup.tasksArray objectAtIndex:indexPath.row];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Done" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [task setClosed:YES];
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete the task" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [taskGroup.tasksArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationFade];
            //[self.tableView reloadData]; // because without this line header of section not delete immediately
        }];
        
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [deleteAlertVC addAction:deleteAction];
        [deleteAlertVC addAction:closeAction];
        [self presentViewController:deleteAlertVC animated:YES completion:nil];
    }];
    
    if (task.isClosed) {
        return @[deleteAction];
    } else {
        return @[deleteAction, doneAction];
    }
}


#pragma mark - Tap to cell

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMTaskDetailVCIndentifair"];
    OMMTasksGroup *taskGroup = [self.tasksGroupsArray objectAtIndex:indexPath.section];
    OMMTask *task = [taskGroup.tasksArray objectAtIndex:indexPath.row];
    taskDetails.task = task;
    [self.navigationController pushViewController:taskDetails animated:YES];
}


@end
