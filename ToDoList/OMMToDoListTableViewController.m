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
#import "OMMDataManager.h"


@interface OMMToDoListTableViewController ()

@property (nonatomic, strong) NSMutableArray *tasksGroupArray;
@property (assign, nonatomic) BOOL taskListWasModified;

@end


@implementation OMMToDoListTableViewController

#pragma mark - localization

static NSString *OMMToDoListInboxGroup;
static NSString *OMMToDoListGreateNewGroupLabelText;
static NSString *OMMToDoListRenameTitleForEditingAction;
static NSString *OMMToDoListRenameGroupAlertName;
static NSString *OMMToDoListSaveButtonInRenameAlert;
static NSString *OMMToDoListCloseButtonInRenameAlert;
static NSString *OMMToDoListDeleteTitleForEditingAction;
static NSString *OMMToDoListCloseTitleForEditingAction;
static NSString *OMMToDoListDeleteGroupAlertWarning;

+ (void)initialize
{
    OMMToDoListInboxGroup = NSLocalizedString(@"section_name.text-INBOX", nil);
    OMMToDoListGreateNewGroupLabelText =  NSLocalizedString(@"cell.title-GREATE_NEW_GROUP", nil);
    OMMToDoListRenameTitleForEditingAction = NSLocalizedString(@"editing_action_button.title-RENAME", nil);
    OMMToDoListRenameGroupAlertName = NSLocalizedString(@"alert_rename_group_name.title-RENAME_THE_GROUP", nil);
    OMMToDoListSaveButtonInRenameAlert = NSLocalizedString(@"alert_rename_group_button.title-SAVE", nil);
    OMMToDoListCloseButtonInRenameAlert = NSLocalizedString(@"alert_rename_group_button.title-CLOSE", nil);
    OMMToDoListDeleteTitleForEditingAction = NSLocalizedString(@"alert_delte_droup_button.title-DELETE", nil);
    OMMToDoListCloseTitleForEditingAction = NSLocalizedString(@"alert_delte_droup_button.title-CLOSE", nil);
    OMMToDoListDeleteGroupAlertWarning = NSLocalizedString(@"alert_warning.title-ARE_YOU_SURE_WANT_TO_DELETE_THE_GROUP", nil);
}


#pragma mark - constants

static NSString * const OMMToDoListTaskListTableVCCellIdentifair = @"OMMTaskListTableVCCell";
static NSString * const OMMToDoListEmptyHeaderSection = @" ";
static NSString * const OMMToDoListPlusImage = @"ic_plus.png";
static NSString * const OMMToDoListEmptyLabelText = @"";
static NSString * const OMMToDoListGroupNameTaskGroupProperty = @"groupName";
static NSString * const OMMToDoListInboxTableVCIdentifair = @"OMMInboxTableVCIdentifair";
static NSString * const OMMToDoListCreateGroupTableVCIdentifair = @"OMMCreateGroupTableVCIdentifair";


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tasksGroupArray = [[[OMMDataManager sharedInstance] getAllTasksGroups] mutableCopy];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskListWasModify) name:OMMTaskServiceTaskWasModifyNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.taskListWasModified) {
        self.tasksGroupArray = [[[OMMDataManager sharedInstance] getAllTasksGroups] mutableCopy];
        [self.tableView reloadData];
        self.taskListWasModified = NO;
    }
}

- (void)triggerTaskListWasModify {
    self.taskListWasModified = YES;
}


#pragma mark - setup UI for tableView

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    return [UIView createViewForHeaderInSection:tableView withTitle:sectionTitle];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 25.f;
    }
    return 50.f;
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
    }
    return self.tasksGroupArray.count + 1; // +1 - "greate new group" row
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OMMToDoListTaskListTableVCCellIdentifair forIndexPath:indexPath];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:OMMToDoListTaskListTableVCCellIdentifair];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = OMMToDoListInboxGroup;
        OMMTasksGroup *inboxGroup = [[OMMDataManager sharedInstance] inboxTasksGroup];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)[[inboxGroup allTasksArray] count]];
        
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
        OMMTasksGroup *taskGroup = [[[OMMDataManager sharedInstance] getAllTasksGroups] objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = taskGroup.groupName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)[taskGroup.tasks count]];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) { // disallow edit inbox and "greate new group"  rows
        return NO;
    } 
    return YES;
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
                [[OMMDataManager sharedInstance] renameTasksGroupWithID:taskGroup.groupID to:textField.text];
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
            textField.text = [[[[OMMDataManager sharedInstance] getAllTasksGroups] objectAtIndex:(indexPath.row - 1)] valueForKey:OMMToDoListGroupNameTaskGroupProperty];
        }];
        [self presentViewController:renameAvlertVC animated:YES completion:nil];
    }];
    
    // delete action
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:OMMToDoListDeleteTitleForEditingAction handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController *deleteAlertVC = [UIAlertController alertControllerWithTitle:OMMToDoListDeleteGroupAlertWarning message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:OMMToDoListDeleteTitleForEditingAction style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.tasksGroupArray removeObjectAtIndex:(indexPath.row - 1)];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:YES];
            [[OMMDataManager sharedInstance] deleteTasksGroupByID:taskGroup.groupID];
            self.taskListWasModified = NO;
            tableView.editing = NO;
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
        taskGroupVC.tasksGroup = [[OMMDataManager sharedInstance] inboxTasksGroup];
        pushingVC = taskGroupVC;
    } else if (indexPath.row == 0) { // 1st row in 2nd section - "greate new group". Push to CreateNewGroupVC
        OMMToDoListTableViewController * __weak weakSelfVC = self;
        createGroupVC.createNewGroup = ^(NSString *newGroupName) {
            OMMTasksGroup *tasksGroup = [[OMMDataManager sharedInstance] createTasksGroupWithName:newGroupName];
            [weakSelfVC.tasksGroupArray addObject:tasksGroup];
            [weakSelfVC.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.tasksGroupArray.count inSection:indexPath.section]] withRowAnimation:YES];
        };
        pushingVC = createGroupVC;
    } else { // if we tap to a group row
        taskGroupVC.tasksGroup = [[[OMMDataManager sharedInstance] getAllTasksGroups] objectAtIndex:indexPath.row - 1];
        pushingVC = taskGroupVC;
    }
    
    // push to inboxVC with group witch we chosed 
    taskGroupVC.navigationItem.title = [NSString stringWithFormat:@"%@ group", taskGroupVC.tasksGroup.groupName];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:pushingVC animated:YES];
}


@end
