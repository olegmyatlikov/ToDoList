//
//  OMMToDoListTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 19/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMToDoListTableViewController.h"
#import "NSDate+OMMDateConverter.h"
#import "UIView+OMMHeaderInSection.h"
#import "OMMTask.h"
#import "OMMTasksGroup.h"
#import "OMMTaskService.h"
#import "OMMInboxTableViewController.h"
#import "OMMCreateGroupTableViewController.h"


@interface OMMToDoListTableViewController ()

@property (nonatomic, strong) OMMTaskService *taskService;
@property (nonatomic, strong) NSMutableArray *tasksGroupArray;

@end

@implementation OMMToDoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskService = [OMMTaskService sharedInstance];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tasksGroupArray = [self.taskService.tasksGroupsArray mutableCopy];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskWasCreatedOrEdited:) name:@"TaskWasCreatedOrEdited" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerGroupWasDeleted) name:@"GroupWasDeleted" object:nil];
}

- (void)triggerTaskWasCreatedOrEdited:(NSNotification *)notification {
    self.tasksGroupArray = [self.taskService.tasksGroupsArray mutableCopy];
    [self.tableView reloadData];
}

- (void)triggerGroupWasDeleted {
    [self.tableView reloadData];
}


#pragma mark - Setup UI for tableView

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    return [UIView createViewForHeaderInSection:tableView withTitle:sectionTitle];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 25.f;
    } else {
        return 50.f;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" ";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.tasksGroupArray.count + 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskListTableVCCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"OMMTaskListTableVCCell"];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Inbox";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)self.taskService.allTasksArray.count];
    } else if (indexPath.row == 0) {
        cell.textLabel.text = @"Create new group";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        OMMTasksGroup *taskGroup = [[OMMTasksGroup alloc] init];
        taskGroup = [self.taskService.tasksGroupsArray objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = taskGroup.groupName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)[taskGroup.tasksArray count]];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) {
        return NO;
    } else {
        return YES;
    }
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTasksGroup *taskGroup = [self.tasksGroupArray objectAtIndex:(indexPath.row - 1)];
    
    UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Rename" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *renameAvlertVC = [UIAlertController alertControllerWithTitle:@"Rename the group" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (renameAvlertVC.textFields.count > 0) {
                UITextField *textField = [renameAvlertVC.textFields firstObject];
                taskGroup.groupName = textField.text;
                self.tableView.editing = NO;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:YES];
            }
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [renameAvlertVC addAction:closeAction];
        [renameAvlertVC addAction:saveAction];
        [renameAvlertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = [[self.taskService.tasksGroupsArray objectAtIndex:(indexPath.row - 1)] valueForKey:@"groupName"];
        }];
        [self presentViewController:renameAvlertVC animated:YES completion:nil];
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:@"Are you sure want to delete the group" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.taskService removeTasksGroup:taskGroup];
            [self.tasksGroupArray removeObjectAtIndex:(indexPath.row - 1)];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:YES];
            tableView.editing = NO;
        }];
        
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [deleteAlertVC addAction:deleteAction];
        [deleteAlertVC addAction:closeAction];
        [self presentViewController:deleteAlertVC animated:YES completion:nil];
    }];
    
    renameAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, renameAction];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMInboxTableViewController *taskGroupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMInboxTableVCIdentifair"];
    OMMCreateGroupTableViewController *createGroupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OMMCreateGroupTableVCIdentifair"];
    UIViewController *pushingVC = [[UIViewController alloc] init];
    
    if (indexPath.section == 0) {
        taskGroupVC.tasksGroup = self.taskService.inboxTasksGroup;
        pushingVC = taskGroupVC;
    } else if (indexPath.row == 0) {
        OMMToDoListTableViewController * __weak weakSelfVC = self;
        createGroupVC.createNewGroup = ^(NSString *newGroupName) {
            OMMTasksGroup *newGroup = [self.taskService createTasksGroup:newGroupName];
            [weakSelfVC.taskService addTaskGroup:newGroup];
            [weakSelfVC.tasksGroupArray addObject:newGroup];
            [weakSelfVC.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.tasksGroupArray.count inSection:indexPath.section]] withRowAnimation:YES];
        };
        pushingVC = createGroupVC;
    } else {
        taskGroupVC.tasksGroup = [self.taskService.tasksGroupsArray objectAtIndex:indexPath.row - 1];
        pushingVC = taskGroupVC;
    }
    
    taskGroupVC.navigationItem.title = [NSString stringWithFormat:@"%@ group", taskGroupVC.tasksGroup.groupName];
    [self.navigationController pushViewController:pushingVC animated:YES];
}


@end
