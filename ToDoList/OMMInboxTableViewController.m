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
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMInboxTableViewController ()

@property (strong, nonatomic) OMMTaskService *taskService;
@property (strong, nonatomic) NSMutableArray *tasksGroupsArray;
@property (assign, nonatomic, getter=isArrayReverse) BOOL arrayDirection;
@property (strong, nonatomic) UISegmentedControl *filterForTasksSegmentControl;

@end

@implementation OMMInboxTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskService = [OMMTaskService sharedInstance];
    self.tasksGroupsArray = [[NSMutableArray alloc] init];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    self.filterForTasksSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Group", @"Date"]];
    [self.filterForTasksSegmentControl setWidth:130.f forSegmentAtIndex:0];
    [self.filterForTasksSegmentControl setWidth:130.f forSegmentAtIndex:1];
    self.filterForTasksSegmentControl.center = headerView.center;
    self.filterForTasksSegmentControl.selectedSegmentIndex = 0;
    [self.filterForTasksSegmentControl addTarget:self action:@selector(filteredTasks:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:self.filterForTasksSegmentControl];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // check if we came here by toDoList or not
    [self prepareDataForTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskListWasModify) name:@"TaskListWasModify" object:nil];
}

- (void)triggerTaskListWasModify {
    [self prepareDataForTableView];
    [self.tableView reloadData];
}

- (void)prepareDataForTableView {
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
    // If array was reverse then i will do it reverse
    if (self.isArrayReverse) {
        [self revertButtonPressed:nil];
        self.arrayDirection = YES;
    }
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

- (void)filteredTasks:(id)sender {
    NSLog(@"%ld", (long)[sender selectedSegmentIndex]);
    if ([sender selectedSegmentIndex]) {
        [self prepareDataForTableView];
        [self.tableView reloadData];
    } else {
        
    }
}

- (IBAction)revertButtonPressed:(UIBarButtonItem *)sender {
    if (self.filterForTasksSegmentControl.selectedSegmentIndex == 0) {
        [self.tasksGroupsArray removeObjectAtIndex:0];
        NSArray *reverceArray = [[self.tasksGroupsArray reverseObjectEnumerator] allObjects];
        self.tasksGroupsArray = [reverceArray mutableCopy];
        [self.tasksGroupsArray insertObject:self.taskService.inboxTasksGroup atIndex:0];
        [self.tableView reloadData];
    }
    self.arrayDirection = (self.isArrayReverse) ? NO : YES;
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == 0 && sourceIndexPath.section == destinationIndexPath.section) {
        OMMTask *task = [self.taskService.inboxTasksGroup.tasksArray objectAtIndex:sourceIndexPath.row];
        [self.taskService.inboxTasksGroup.tasksArray removeObjectAtIndex:sourceIndexPath.row];
        [self.taskService.inboxTasksGroup.tasksArray insertObject:task atIndex:destinationIndexPath.row];
    } else if (sourceIndexPath.section == destinationIndexPath.section) {
        OMMTask *task = [[[self.taskService.tasksGroupsArray objectAtIndex:(sourceIndexPath.section - 1)] valueForKey:@"tasksArray"] objectAtIndex:sourceIndexPath.row];
        [[[self.taskService.tasksGroupsArray objectAtIndex:(sourceIndexPath.section - 1)] valueForKey:@"tasksArray"] removeObjectAtIndex:sourceIndexPath.row];
        [[[self.taskService.tasksGroupsArray objectAtIndex:(sourceIndexPath.section - 1)] valueForKey:@"tasksArray"] insertObject:task atIndex:destinationIndexPath.row];
    }
    [tableView reloadData];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskListWasModify" object:self];
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete the task" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            OMMTask *taskForDelete = [taskGroup.tasksArray objectAtIndex:indexPath.row];
            [taskGroup.tasksArray removeObject:taskForDelete];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationFade];
            [self.taskService removeTask:taskForDelete];
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
