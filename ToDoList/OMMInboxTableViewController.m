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

@property (strong, nonatomic) NSMutableArray *tasksGroupsArray;
@property (strong, nonatomic) NSMutableArray *allTasksSortedByDateInArrays;

@property (assign, nonatomic) BOOL taskArrayDirectionReverse;
@property (strong, nonatomic) UISegmentedControl *sortByGroupsOrDateSegmentControl;
@property (assign, nonatomic) BOOL taskListWasModified;

@end

@implementation OMMInboxTableViewController

#pragma mark - localizetion 

static NSString *OMMInboxGroupSegmentControl;
static NSString *OMMInboxDateSegmentControl;
static NSString *OMMInboxCancelButton; // if we came to the inbox page from ToDoList
static NSString *OMMInboxEditingActionDelete;
static NSString *OMMInboxDoneButton;
static NSString *OMMInboxDeleteButton;
static NSString *OMMInboxCloseButton;
static NSString *OMMInboxAlertWarning;

+ (void)initialize {
    OMMInboxGroupSegmentControl = NSLocalizedString(@"segment_control.title-GROUP", nil);
    OMMInboxDateSegmentControl = NSLocalizedString(@"segment_control,title-DATE", nil);
    OMMInboxCancelButton = NSLocalizedString(@"left_bar_button_item.title-CLOSE", nil);
    OMMInboxEditingActionDelete = NSLocalizedString(@"editing_action.title-DELETE", nil);
    OMMInboxDoneButton = NSLocalizedString(@"edeiting_action.title-DONE", nil);
    OMMInboxDeleteButton = NSLocalizedString(@"alert_action_button.title-DELETE", nil);
    OMMInboxCloseButton = NSLocalizedString(@"alert_action_button.title-CLOSE", nil);
    OMMInboxAlertWarning = NSLocalizedString(@"alert_warning.title-ARE_YOU_SURE_WANT_TO_DELETE_THE_TASK", nil);
}


#pragma mark - constants

static NSString * const OMMInboxStartDateTasksProperty = @"startDate";
static NSString * const OMMInboxTaskArrayTasksGroupProperty = @"tasksArray";
static NSString * const OMMInboxTaskCellIndetifair = @"OMMTaskCellIdentifier";
static NSString * const OMMInboxTaskCellXibName = @"OMMTaskCell";
static NSString * const OMMInboxTaskDetailVCIndentifair = @"OMMTaskDetailVCIndentifair";


#pragma mark life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tasksGroupsArray = [[NSMutableArray alloc] init];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    self.sortByGroupsOrDateSegmentControl = [[UISegmentedControl alloc] initWithItems:@[OMMInboxGroupSegmentControl, OMMInboxDateSegmentControl]];
    [self.sortByGroupsOrDateSegmentControl setWidth:130.f forSegmentAtIndex:0];
    [self.sortByGroupsOrDateSegmentControl setWidth:130.f forSegmentAtIndex:1];
    self.sortByGroupsOrDateSegmentControl.center = headerView.center;
    self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex = 0;
    [self.sortByGroupsOrDateSegmentControl addTarget:self action:@selector(sortTasksSegmentControlWasChanged:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:self.sortByGroupsOrDateSegmentControl];
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self prepareDataForTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskListWasModify) name:OMMTaskServiceTaskWasModifyNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.taskListWasModified) {
        [self prepareDataForTableView];
        [self sortAllTaskByDate];
        if (self.taskArrayDirectionReverse) { // If tableView was reverse then reverse updated tableview
            [self revertButtonPressed:nil];
        }
        [self.tableView reloadData];
        self.taskListWasModified = NO;
    }
}


#pragma mark - methods

- (void)triggerTaskListWasModify {
    self.taskListWasModified = YES;
}

- (void)prepareDataForTableView {
    // check - if we came here from toDoList show only one group tasks
    if (!self.tasksGroup) {
        self.tasksGroupsArray = [[OMMTaskService sharedInstance].tasksGroupsArray mutableCopy];
        [self.tasksGroupsArray insertObject:[OMMTaskService sharedInstance].inboxTasksGroup atIndex:0];
    } else {
        [self.tasksGroupsArray removeAllObjects];
        [self.tasksGroupsArray addObject:self.tasksGroup];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:OMMInboxCancelButton style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = backButtonItem;
        self.navigationItem.rightBarButtonItems = @[[self.navigationItem.rightBarButtonItems objectAtIndex:0]]; // hide reverce button
        self.tableView.tableHeaderView = nil;
    }
    
    [self sortAllTaskByDate]; // prepare array witch sorted by date
}

- (IBAction)addNewTaskButtonPressed:(UIBarButtonItem *)sender {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:OMMInboxTaskDetailVCIndentifair];
    if (self.tasksGroupsArray.count == 1) { // if we in the group then send this group and add new task in it
        taskDetails.taskGroup = self.tasksGroupsArray[0];
    } else { // else add task in inbox group
        taskDetails.taskGroup = [OMMTaskService sharedInstance].inboxTasksGroup;
    }
    [self.navigationController pushViewController:taskDetails animated:YES];
}

- (void)backButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)sortTasksSegmentControlWasChanged:(id)sender {
    [self.tableView reloadData];
}

- (IBAction)revertButtonPressed:(UIBarButtonItem *)sender {

    // revert task witch sorted by group
    [self.tasksGroupsArray removeObjectAtIndex:0];
    NSArray *reverceArray = [[self.tasksGroupsArray reverseObjectEnumerator] allObjects];
    self.tasksGroupsArray = [reverceArray mutableCopy];
    [self.tasksGroupsArray insertObject:[OMMTaskService sharedInstance].inboxTasksGroup atIndex:0];

    // revert task witch sorted by date
    NSMutableArray *reverceTaskArray = [[NSMutableArray alloc] init];
    for (NSArray *taskArray in self.allTasksSortedByDateInArrays) {
        [reverceTaskArray insertObject:[[taskArray reverseObjectEnumerator] allObjects] atIndex:0];
    }
    self.allTasksSortedByDateInArrays = reverceTaskArray;

    self.taskArrayDirectionReverse = (self.taskArrayDirectionReverse) ? NO : YES; // save direction condition
    [self.tableView reloadData];
}

- (void)sortAllTaskByDate {
    self.allTasksSortedByDateInArrays = [[NSMutableArray alloc] init];
    NSSortDescriptor *sortByDateDescriptor = [[NSSortDescriptor alloc] initWithKey:OMMInboxStartDateTasksProperty ascending:YES];
    NSArray *sortDescriptorsArray = @[sortByDateDescriptor];
    NSArray *tasksSortedByStartDate = [[OMMTaskService sharedInstance].allTasksArray sortedArrayUsingDescriptors:sortDescriptorsArray];
    
    for (int i = 0; i < tasksSortedByStartDate.count; i++) {
        if (i == 0) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:tasksSortedByStartDate[i]];
            [self.allTasksSortedByDateInArrays addObject:array];
        } else if ([[[tasksSortedByStartDate[i] valueForKey:OMMInboxStartDateTasksProperty] convertToStringForCompareDate] isEqual:[[tasksSortedByStartDate[i-1] valueForKeyPath:OMMInboxStartDateTasksProperty] convertToStringForCompareDate]]) {
            [[self.allTasksSortedByDateInArrays lastObject] addObject:tasksSortedByStartDate[i]];
        } else {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:tasksSortedByStartDate[i]];
            [self.allTasksSortedByDateInArrays addObject:array];
        }
    }
    
}


#pragma mark - setup UI for tableView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    // move row in inbox section
    if (sourceIndexPath.section == 0 && sourceIndexPath.section == destinationIndexPath.section && self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex == 0) {
        OMMTask *task = [[OMMTaskService sharedInstance].inboxTasksGroup.tasksArray objectAtIndex:sourceIndexPath.row];
        [[OMMTaskService sharedInstance].inboxTasksGroup.tasksArray removeObjectAtIndex:sourceIndexPath.row];
        [[OMMTaskService sharedInstance].inboxTasksGroup.tasksArray insertObject:task atIndex:destinationIndexPath.row];
        
    // move row in group but only on it section
    } else if (sourceIndexPath.section == destinationIndexPath.section) {
        OMMTask *task = [[[[OMMTaskService sharedInstance].tasksGroupsArray objectAtIndex:(sourceIndexPath.section - 1)] valueForKey:OMMInboxTaskArrayTasksGroupProperty] objectAtIndex:sourceIndexPath.row];
        [[[[OMMTaskService sharedInstance].tasksGroupsArray objectAtIndex:(sourceIndexPath.section - 1)] valueForKey:OMMInboxTaskArrayTasksGroupProperty] removeObjectAtIndex:sourceIndexPath.row];
        [[[[OMMTaskService sharedInstance].tasksGroupsArray objectAtIndex:(sourceIndexPath.section - 1)] valueForKey:OMMInboxTaskArrayTasksGroupProperty] insertObject:task atIndex:destinationIndexPath.row];
    }
    
    [tableView reloadData];
}


#pragma mark - setup data for tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex == 0) {
        return self.tasksGroupsArray.count;
    }
    return self.allTasksSortedByDateInArrays.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex == 0) {
        OMMTasksGroup *taskGroup = [self.tasksGroupsArray objectAtIndex:section];
        return taskGroup.groupName;
    }
    
    OMMTask *task = [[self.allTasksSortedByDateInArrays objectAtIndex:section] objectAtIndex:0];
    return [task.startDate convertToStringForCompareDate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex == 0) {
        OMMTasksGroup *taskGroup = [self.tasksGroupsArray objectAtIndex:section];
        return taskGroup.tasksArray.count;
    }
    return [[self.allTasksSortedByDateInArrays objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:OMMInboxTaskCellIndetifair];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:OMMInboxTaskCellXibName bundle:nil] forCellReuseIdentifier:OMMInboxTaskCellIndetifair];
        cell = [tableView dequeueReusableCellWithIdentifier:OMMInboxTaskCellIndetifair];
    }
    
    OMMTasksGroup *taskGroup = [[OMMTasksGroup alloc] init];
    OMMTask *task = [[OMMTask alloc] init];
    if (self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex == 0) {
        taskGroup = [self.tasksGroupsArray objectAtIndex:indexPath.section];
        task = [taskGroup.tasksArray objectAtIndex:indexPath.row];
    } else {
        task = [[self.allTasksSortedByDateInArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToLongDateString];

 return cell;
 }


#pragma mark - edit the row

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get task witch editing
    OMMTasksGroup *taskGroup = [[OMMTasksGroup alloc] init];
    OMMTask *task = [[OMMTask alloc] init];
    if (self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex == 0) {
        taskGroup = [self.tasksGroupsArray objectAtIndex:indexPath.section];
        task = [taskGroup.tasksArray objectAtIndex:indexPath.row];
    } else {
        task = [[self.allTasksSortedByDateInArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    // done button - change task condition in closed
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:OMMInboxDoneButton handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[OMMTaskService sharedInstance] closeTask:task];
        [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
        self.taskListWasModified = NO;
        tableView.editing = NO;
    }];
    
    // delete button with alert "sure want to delete" when delete button pressed
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:OMMInboxEditingActionDelete handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:OMMInboxAlertWarning message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:OMMInboxDeleteButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex == 0) {
                
                // Delete task in all groups with animations
                for (NSInteger i = 0; i < self.tasksGroupsArray.count; i++) {
                    OMMTasksGroup *checkTaskGroup = [self.tasksGroupsArray objectAtIndex:i];
                    if ([checkTaskGroup.tasksArray containsObject:task]) {
                        NSInteger j = [checkTaskGroup.tasksArray indexOfObject:task];
                        [checkTaskGroup.tasksArray removeObjectAtIndex:j];
                        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:j inSection:i]] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
                [self.allTasksSortedByDateInArrays removeObject:task]; // and delete this task from allTasksSortedByDateInArrays
                [self sortAllTaskByDate]; // reload allTasksSortedByDateInArrays
                
            } else {
                [[self.allTasksSortedByDateInArrays objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            [[OMMTaskService sharedInstance] removeTask:task];
            self.taskListWasModified = NO;
        }];
        
        // cancel button close alert and stop editing
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:OMMInboxCloseButton style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [deleteAlertVC addAction:deleteAction];
        [deleteAlertVC addAction:closeAction];
        [self presentViewController:deleteAlertVC animated:YES completion:nil];
    }];
    
    
    // if task closed show only delete button
    if (task.isClosed) {
        return @[deleteAction];
    } 
    return @[deleteAction, doneAction];
}


#pragma mark - tap to cell

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:OMMInboxTaskDetailVCIndentifair];
    
    OMMTasksGroup *taskGroup = [[OMMTasksGroup alloc] init];
    OMMTask *task = [[OMMTask alloc] init];
    if (self.sortByGroupsOrDateSegmentControl.selectedSegmentIndex == 0) {
        taskGroup = [self.tasksGroupsArray objectAtIndex:indexPath.section];
        task = [taskGroup.tasksArray objectAtIndex:indexPath.row];
    } else {
        task = [[self.allTasksSortedByDateInArrays objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }

    taskDetails.task = task;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:taskDetails animated:YES]; // go to the edit task VC
}


@end
