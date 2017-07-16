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
#import <CoreData/CoreData.h>

@interface OMMTodayTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *openTasksFetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *closedTasksFetchedResultsController;

//@property (strong, nonatomic) NSMutableArray *allTodayTasks;
//@property (strong, nonatomic) NSMutableArray *openTasksArray;
//@property (strong, nonatomic) NSMutableArray *closeTaskArray;
//@property (assign, nonatomic) BOOL taskListWasModified;

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
static NSString * const OMMTodayVCPredicateOpenTaks = @"closed = 0";
static NSString * const OMMTodayVCPredicateCloseTaks = @"closed = 1";
static NSString * const OMMTodayVCEmptyTitleForSectionsHeader = @"";
static NSString * const OMMTodayVCTaskCellIdentifier = @"OMMTaskCellIdentifier";
static NSString * const OMMTodayVCTaskCellXibName = @"OMMTaskCell";


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = [appDelegate managedObjectContext];
    [self initializeOpenTasksFetchedResultsController];
    [self initializeClosedTasksFetchedResultsController];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

}


#pragma mark - initializete fetchedResults

- (void)initializeOpenTasksFetchedResultsController {
    NSFetchRequest *request = [OMMTask fetchRequest];

    NSSortDescriptor *taskNameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[taskNameSort]];
    NSPredicate *openTasksPredicate = [NSPredicate predicateWithFormat:@"closed == NO"];
    request.predicate = openTasksPredicate;
    
    [self setOpenTasksFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]];
    [self.openTasksFetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    if (![self.openTasksFetchedResultsController performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

- (void)initializeClosedTasksFetchedResultsController {
    NSFetchRequest *request = [OMMTask fetchRequest];
    
    NSSortDescriptor *taskNameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[taskNameSort]];
    NSPredicate *closedTasksPredicate = [NSPredicate predicateWithFormat:@"closed == YES"];
    request.predicate = closedTasksPredicate;
    
    [self setClosedTasksFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]];
    [self.closedTasksFetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    if (![self.closedTasksFetchedResultsController performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}


#pragma mark - methods

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
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.openTasksFetchedResultsController sections] firstObject];
        return [sectionInfo numberOfObjects];
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.closedTasksFetchedResultsController sections] firstObject];
    return [sectionInfo numberOfObjects];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:OMMTodayVCTaskCellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:OMMTodayVCTaskCellXibName bundle:nil] forCellReuseIdentifier:OMMTodayVCTaskCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:OMMTodayVCTaskCellIdentifier];
    }
    OMMTask *task = [[OMMTask alloc] init];
    if (indexPath.section == 0) {
        task = [self.openTasksFetchedResultsController objectAtIndexPath:indexPath];
    } else {
        task = [self.closedTasksFetchedResultsController objectAtIndexPath:indexPath];
    }
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToLongDateString];
    
    return cell;
}


#pragma mark - edit the row

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:OMMTodayVCDoneAction handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        
//        OMMTask *task = [self.openTasksArray objectAtIndex:indexPath.row];
//        [[OMMTaskService sharedInstance] closeTask:task];
//        [self.openTasksArray removeObject:task];
//        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationBottom];
//        [self.closeTaskArray addObject:task];
//        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.closeTaskArray.count - 1) inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:OMMTaskServiceTaskWasModifyNotification object:self];
//        self.taskListWasModified = NO; // don't reload data if changes was in this tab
//        tableView.editing = NO;
//    }];
//    
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:OMMTodayVCEditingActionDelete handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:OMMTodayVCAlertWarning message:nil preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:OMMTodayVCDeleteAction style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            OMMTask *taskForDelete = [[OMMTask alloc] init];
//            if (indexPath.section == 0) {
//                taskForDelete = [self.openTasksArray objectAtIndex:indexPath.row];
//                [self.openTasksArray removeObject:taskForDelete];
//            } else {
//                taskForDelete = [self.closeTaskArray objectAtIndex:indexPath.row];
//                [self.closeTaskArray removeObject:taskForDelete];
//            }
//            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section)]] withRowAnimation:UITableViewRowAnimationFade];
//            [[OMMTaskService sharedInstance] removeTask:taskForDelete];
//            self.taskListWasModified = NO; // don't reload data if changes was in this tab
//        }];
//        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:OMMTodayVCCloseAction style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            tableView.editing = NO;
//        }];
//        
//        [deleteAlertVC addAction:deleteAction];
//        [deleteAlertVC addAction:closeAction];
//        [self presentViewController:deleteAlertVC animated:YES completion:nil];
//    }];
//    
//    if (indexPath.section == 0) {
//        return @[deleteAction, doneAction];
//    }
//    return @[deleteAction];
//}


#pragma mark - Tap to cell

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:OMMTodayVCTaskDetailVCIndentifair];
//    
//    if (indexPath.section == 0) {
//        OMMTask *openTask = [self.openTasksArray objectAtIndex:indexPath.row];
//        taskDetails.task = openTask;
//    } else {
//        OMMTask *closedTask = [self.closeTaskArray objectAtIndex:indexPath.row];
//        taskDetails.task = closedTask;
//    }
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self.navigationController pushViewController:taskDetails animated:YES];
//}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] beginUpdates];
}

//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeMove:
//        case NSFetchedResultsChangeUpdate:
//            break;
//    }
//}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        
//        [self.managedObjectContext deleteObject: [self.fetchedResultsController objectAtIndexPath:indexPath]];
//        
//    }];
//    
//    return @[deleteAction];
//}


@end
