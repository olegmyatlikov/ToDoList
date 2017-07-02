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
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMTodayTableViewController ()

@property (strong, nonatomic) NSMutableArray *allTodayTasks;
@property (strong, nonatomic) NSMutableArray *openTasksArray;
@property (strong, nonatomic) NSMutableArray *closeTaskArray;
@property (assign, nonatomic) BOOL taskListWasModified;

@end


@implementation OMMTodayTableViewController

#pragma mark - constants

static NSString * const OMMTodayVCTaskDetailVCIndentifair = @"OMMTaskDetailVCIndentifair";
static NSString * const OMMTodayVCPredicateOpenTaks = @"closed = 0";
static NSString * const OMMTodayVCPredicateCloseTaks = @"closed = 1";
static NSString * const OMMTodayVCSectionHeaderTitleComplited = @"Complited";
static NSString * const OMMTodayVCEmptyTitleForSectionsHeader = @"";
static NSString * const OMMTodayVCTaskCellIdentifier = @"OMMTaskCellIdentifier";
static NSString * const OMMTodayVCTaskCellXibName = @"OMMTaskCell";
static NSString * const OMMTodayVCDeleteAction = @"Delete";
static NSString * const OMMTodayVCDoneAction = @"Done";
static NSString * const OMMTodayVCCloseACtion = @"Close";
static NSString * const OMMTodayVCAlertWarning = @"Are you sure want to delete the task";


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareDataForTableView];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskListWasModify) name:OMMTaskServiceTaskWasModifyNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.taskListWasModified) {
        [self prepareDataForTableView];
        [self.tableView reloadData];
        self.taskListWasModified = NO;
    }
}

#pragma mark - methods

- (void)prepareDataForTableView {
    self.allTodayTasks = [self allTodayTasksInTasksArray:[OMMTaskService sharedInstance].allTasksArray];
    self.openTasksArray = [self allOpenTasksInArray:self.allTodayTasks];
    self.closeTaskArray = [self allCloseTasksInArray:self.allTodayTasks];
}

- (void)triggerTaskListWasModify {
    self.taskListWasModified = YES;
}

- (IBAction)addNewTaskButtonPressed:(UIBarButtonItem *)sender {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:OMMTodayVCTaskDetailVCIndentifair];
    [self.navigationController pushViewController:taskDetails animated:YES];
}

- (NSMutableArray *)allOpenTasksInArray:(NSMutableArray *)array {
    NSMutableArray *openTasksArray = [[NSMutableArray alloc] init];
    NSPredicate *openTaskPredicate = [NSPredicate predicateWithFormat:OMMTodayVCPredicateOpenTaks];
    openTasksArray = [[array filteredArrayUsingPredicate:openTaskPredicate] mutableCopy];
    return openTasksArray;
}

- (NSMutableArray *)allCloseTasksInArray:(NSMutableArray *)array {
    NSMutableArray *closeTasksArray = [[NSMutableArray alloc] init];
    NSPredicate *closeTaskPredicate = [NSPredicate predicateWithFormat:OMMTodayVCPredicateCloseTaks];
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
    } 
    return 50.f;
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
        return OMMTodayVCEmptyTitleForSectionsHeader;
    }
    return OMMTodayVCSectionHeaderTitleComplited;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.openTasksArray.count;
    }
    return self.closeTaskArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:OMMTodayVCTaskCellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:OMMTodayVCTaskCellXibName bundle:nil] forCellReuseIdentifier:OMMTodayVCTaskCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:OMMTodayVCTaskCellIdentifier];
    }
    OMMTask *task = [[OMMTask alloc] init];
    if (indexPath.section == 0) {
        task = [self.openTasksArray objectAtIndex:indexPath.row];
    } else {
        task = [self.closeTaskArray objectAtIndex:indexPath.row];
    }
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToLongDateString];
    
    return cell;
}


#pragma mark - edit the row

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:OMMTodayVCDoneAction handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        OMMTask *task = [self.openTasksArray objectAtIndex:indexPath.row];
        [[OMMTaskService sharedInstance] closeTask:task];
        [self.openTasksArray removeObject:task];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.closeTaskArray addObject:task];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.closeTaskArray.count - 1) inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
        self.taskListWasModified = NO; // don't reload data if changes was in this tab
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:OMMTodayVCDeleteAction handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:OMMTodayVCAlertWarning message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:OMMTodayVCDeleteAction style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            OMMTask *taskForDelete = [[OMMTask alloc] init];
            if (indexPath.section == 0) {
                taskForDelete = [self.openTasksArray objectAtIndex:indexPath.row];
                [self.openTasksArray removeObject:taskForDelete];
            } else {
                taskForDelete = [self.closeTaskArray objectAtIndex:indexPath.row];
                [self.closeTaskArray removeObject:taskForDelete];
            }
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationFade];
            [[OMMTaskService sharedInstance] removeTask:taskForDelete];
            self.taskListWasModified = NO; // don't reload data if changes was in this tab
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:OMMTodayVCCloseACtion style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [deleteAlertVC addAction:deleteAction];
        [deleteAlertVC addAction:closeAction];
        [self presentViewController:deleteAlertVC animated:YES completion:nil];
    }];
    
    if (indexPath.section == 0) {
        return @[deleteAction, doneAction];
    }
    return @[deleteAction];
}


#pragma mark - Tap to cell

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:OMMTodayVCTaskDetailVCIndentifair];
    
    if (indexPath.section == 0) {
        OMMTask *openTask = [self.openTasksArray objectAtIndex:indexPath.row];
        taskDetails.task = openTask;
    } else {
        OMMTask *closedTask = [self.closeTaskArray objectAtIndex:indexPath.row];
        taskDetails.task = closedTask;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:taskDetails animated:YES];
}

@end
