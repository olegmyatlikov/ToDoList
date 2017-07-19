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
//#import "OMMTaskService.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"
#import <CoreData/CoreData.h>
#import "OMMDataManager.h"

@interface OMMTodayTableViewController ()

@property (strong, nonatomic) NSMutableArray *openTasksArray;
@property (strong, nonatomic) NSMutableArray *closeTaskArray;
@property (assign, nonatomic) BOOL taskListWasModified;

@end


@implementation OMMTodayTableViewController

#pragma mark - localization

static NSString *OMMTodayVCSectionHeaderTitleComplited;
static NSString *OMMTodayVCEditingActionDelete;
static NSString *OMMTodayVCDeleteAction;
static NSString *OMMTodayVCDoneAction;
static NSString *OMMTodayVCCloseAction;
static NSString *OMMTodayVCAlertWarning;

+ (void)initialize {
    OMMTodayVCSectionHeaderTitleComplited = NSLocalizedString(@"section_header.title-COMPLITED", nil);
    OMMTodayVCEditingActionDelete = NSLocalizedString(@"editing_action.title-DELETE", nil);
    OMMTodayVCDoneAction = NSLocalizedString(@"edeiting_action.title-DONE", nil);
    OMMTodayVCDeleteAction = NSLocalizedString(@"alert_action_button.title-DELETE", nil);
    OMMTodayVCCloseAction = NSLocalizedString(@"alert_action_button.title-CLOSE", nil);
    OMMTodayVCAlertWarning = NSLocalizedString(@"alert_warning.title-ARE_YOU_SURE_WANT_TO_DELETE_THE_TASK", nil);
}


#pragma mark - constants

static NSString * const OMMTodayVCTaskDetailVCIndentifair = @"OMMTaskDetailVCIndentifair";
static NSString * const OMMTodayVCEmptyTitleForSectionsHeader = @"";
static NSString * const OMMTodayVCTaskCellIdentifier = @"OMMTaskCellIdentifier";
static NSString * const OMMTodayVCTaskCellXibName = @"OMMTaskCell";


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
    NSManagedObjectContext *context = [[OMMDataManager sharedInstance] managedObjectContext];
    NSDate *dateDayStart = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
    NSDate *dateDayNext = [dateDayStart dateByAddingTimeInterval:(24 * 60 * 60)];
    
    NSFetchRequest *openTodayTasksRequest = [OMMTask fetchRequest];
    NSSortDescriptor *taskByDateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
    NSPredicate *openTodayTaskPredicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) && (startDate < %@) && (closed == NO)", dateDayStart, dateDayNext];
    [openTodayTasksRequest setSortDescriptors:@[taskByDateDescriptor]];
    [openTodayTasksRequest setPredicate:openTodayTaskPredicate];
    self.openTasksArray = [[context executeFetchRequest:openTodayTasksRequest error:nil] mutableCopy];
    
    NSFetchRequest *closedTodayTasksRequest = [OMMTask fetchRequest];
    NSPredicate *closedTodayTaskPredicate = [NSPredicate predicateWithFormat:@"(startDate >= %@) && (startDate < %@) && (closed == YES)", dateDayStart, dateDayNext];
    [closedTodayTasksRequest setSortDescriptors:@[taskByDateDescriptor]];
    [closedTodayTasksRequest setPredicate:closedTodayTaskPredicate];
    self.closeTaskArray = [[context executeFetchRequest:closedTodayTasksRequest error:nil] mutableCopy];
}

- (void)triggerTaskListWasModify {
    self.taskListWasModified = YES;
}

- (IBAction)addNewTaskButtonPressed:(UIBarButtonItem *)sender {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:OMMTodayVCTaskDetailVCIndentifair];
    [self.navigationController pushViewController:taskDetails animated:YES];
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
        [[OMMDataManager sharedInstance] closeTaskByID:task.taskID];
        [self.openTasksArray removeObject:task];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.closeTaskArray addObject:task];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.closeTaskArray.count - 1) inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
        //self.taskListWasModified = NO; // don't reload data if changes was in this tab
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:OMMTodayVCEditingActionDelete handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:OMMTodayVCAlertWarning message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:OMMTodayVCDeleteAction style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            OMMTask *taskForDelete = nil;
            if (indexPath.section == 0) {
                taskForDelete = [self.openTasksArray objectAtIndex:indexPath.row];
                [self.openTasksArray removeObjectAtIndex:indexPath.row];
            } else {
                taskForDelete = [self.openTasksArray objectAtIndex:indexPath.row];
                [self.closeTaskArray removeObjectAtIndex:indexPath.row];
            }
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationFade];
            
            [[OMMDataManager sharedInstance] deleteTaskByID:taskForDelete.taskID];
            //self.taskListWasModified = NO; // don't reload data if changes was in this tab
            
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:OMMTodayVCCloseAction style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
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
