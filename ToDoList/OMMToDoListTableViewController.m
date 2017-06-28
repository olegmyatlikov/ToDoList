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
#import "OMMTaskService.h"
#import "OMMInboxTableViewController.h"
#import "OMMCreateGroupTableViewController.h"


@interface OMMToDoListTableViewController ()

@property (nonatomic, strong) OMMTaskService *taskService;
@property (nonatomic, strong) NSMutableArray *tasksGroupArray;

@end


@implementation OMMToDoListTableViewController


#pragma mark - constants

static NSString * const OMMToDoListTaskListWasModifyNotification = @"TaskListWasModify";
static NSString * const OMMToDoListTaskListTableVCCellIdentifair = @"OMMTaskListTableVCCell";
static NSString * const OMMToDoListEmptyHeaderSection = @" ";
static NSString * const OMMToDoListInboxGroup = @"Inbox";
static NSString * const OMMToDoListPlusImage = @"ic_plus.png";
static NSString * const OMMToDoListGreateNewGroupLabelText = @"Create new group";
static NSString * const OMMToDoListEmptyLabelText = @"";
static NSString * const OMMToDoListRenameTitleForEditingAction = @"Rename";
static NSString * const OMMToDoListRenameGroupAlertName = @"Rename the group";
static NSString * const OMMToDoListSaveButtonInRenameAlert = @"Save";
static NSString * const OMMToDoListCloseButtonInRenameAlert = @"Close";
static NSString * const OMMToDoListGroupNameTaskGroupProperty = @"groupName";
static NSString * const OMMToDoListDeleteTitleForEditingAction = @"Delete";
static NSString * const OMMToDoListCloseTitleForEditingAction = @"Close";
static NSString * const OOMMToDoListDeleteGroupAlertWarning = @"Are you sure want to delete the group";
static NSString * const OMMToDoListInboxTableVCIdentifair = @"OMMInboxTableVCIdentifair";
static NSString * const OMMToDoListCreateGroupTableVCIdentifair = @"OMMCreateGroupTableVCIdentifair";


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskService = [OMMTaskService sharedInstance];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tasksGroupArray = [self.taskService.tasksGroupsArray mutableCopy];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskListWasModify) name:OMMToDoListTaskListWasModifyNotification object:nil];
}

- (void)triggerTaskListWasModify {
    self.tasksGroupArray = [self.taskService.tasksGroupsArray mutableCopy];
    [self.tableView reloadData];
}


#pragma mark - setup UI for tableView

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


#pragma mark - setup data for tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // inbox and sections with other group
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return OMMToDoListEmptyHeaderSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.tasksGroupArray.count + 1; // +1 - "greate new group" row
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OMMToDoListTaskListTableVCCellIdentifair forIndexPath:indexPath];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:OMMToDoListTaskListTableVCCellIdentifair];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = OMMToDoListInboxGroup;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)self.taskService.allTasksArray.count];
        
    // crete view with image for "greate new group" row
    } else if (indexPath.row == 0) {
        UIImageView *iconPlus = [[UIImageView alloc] initWithFrame:CGRectMake(13, 13, 21, 21)];
        iconPlus.image = [UIImage imageNamed:OMMToDoListPlusImage];
        [cell.contentView addSubview:iconPlus];
        
        UILabel *customTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0f, 2.0f, (self.view.bounds.size.width - 95), 40.0f)];
        customTextLabel.text = OMMToDoListGreateNewGroupLabelText;
        [cell.contentView addSubview:customTextLabel];
        
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = OMMToDoListEmptyLabelText;
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
    if (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) { // disallow edit inbox and "greate new group"  rows
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - edit rows

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OMMTasksGroup *taskGroup = [self.tasksGroupArray objectAtIndex:(indexPath.row - 1)]; // 1st section uneditable. -1 because in 2nd section we have 1 more row - "greate new group"
    
    // rename action
    UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:OMMToDoListRenameTitleForEditingAction handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *renameAvlertVC = [UIAlertController alertControllerWithTitle:OMMToDoListRenameGroupAlertName message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:OMMToDoListSaveButtonInRenameAlert style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (renameAvlertVC.textFields.count > 0) {
                UITextField *textField = [renameAvlertVC.textFields firstObject];
                taskGroup.groupName = textField.text;
                self.tableView.editing = NO;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:YES];
            }
        }];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:OMMToDoListCloseButtonInRenameAlert style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [renameAvlertVC addAction:closeAction];
        [renameAvlertVC addAction:saveAction];
        [renameAvlertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = [[self.taskService.tasksGroupsArray objectAtIndex:(indexPath.row - 1)] valueForKey:OMMToDoListGroupNameTaskGroupProperty];
        }];
        [self presentViewController:renameAvlertVC animated:YES completion:nil];
    }];
    
    // delete action
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:OMMToDoListDeleteTitleForEditingAction handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:OOMMToDoListDeleteGroupAlertWarning message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:OMMToDoListDeleteTitleForEditingAction style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.tasksGroupArray removeObjectAtIndex:(indexPath.row - 1)];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:YES];
            tableView.editing = NO;
            [self.taskService removeTasksGroup:taskGroup];
        }];
        
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:OMMToDoListCloseTitleForEditingAction style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            tableView.editing = NO;
        }];
        
        [deleteAlertVC addAction:deleteAction];
        [deleteAlertVC addAction:closeAction];
        [self presentViewController:deleteAlertVC animated:YES completion:nil];
    }];
    
    renameAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, renameAction];
}


#pragma mark - select row

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMInboxTableViewController *taskGroupVC = [self.storyboard instantiateViewControllerWithIdentifier:OMMToDoListInboxTableVCIdentifair];
    OMMCreateGroupTableViewController *createGroupVC = [self.storyboard instantiateViewControllerWithIdentifier:OMMToDoListCreateGroupTableVCIdentifair];
    UIViewController *pushingVC = [[UIViewController alloc] init];
    
    if (indexPath.section == 0) { // if we touch Inbox row
        taskGroupVC.tasksGroup = self.taskService.inboxTasksGroup;
        pushingVC = taskGroupVC;
    } else if (indexPath.row == 0) { // 1st row in 2nd section - "greate new group". Push to CreateNewGroupVC
        OMMToDoListTableViewController * __weak weakSelfVC = self;
        createGroupVC.createNewGroup = ^(NSString *newGroupName) {
            OMMTasksGroup *newGroup = [self.taskService createTasksGroup:newGroupName];
            [weakSelfVC.taskService addTaskGroup:newGroup];
            [weakSelfVC.tasksGroupArray addObject:newGroup];
            [weakSelfVC.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.tasksGroupArray.count inSection:indexPath.section]] withRowAnimation:YES];
        };
        pushingVC = createGroupVC;
    } else { // if we tap to a group row
        taskGroupVC.tasksGroup = [self.taskService.tasksGroupsArray objectAtIndex:indexPath.row - 1];
        pushingVC = taskGroupVC;
    }
    
    // push to inboxVC with group witch we chosed 
    taskGroupVC.navigationItem.title = [NSString stringWithFormat:@"%@ group", taskGroupVC.tasksGroup.groupName];
    [self.navigationController pushViewController:pushingVC animated:YES];
}


@end
