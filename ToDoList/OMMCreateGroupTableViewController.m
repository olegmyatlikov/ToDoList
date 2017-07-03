//
//  OMMCreateGroupTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 6/25/17.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMCreateGroupTableViewController.h"
#import "UIView+OMMHeaderInSection.h"

@interface OMMCreateGroupTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

@end


@implementation OMMCreateGroupTableViewController

#pragma mark - constants

static NSString * const OMMCreateGroupDoneButton = @"Done";
static NSString * const OMMCreateGroupCabcelButton = @"Cancel";
static NSString * const OMMCreateGroupTitleForHeaderOfSectionGroup = @"Group";


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:OMMCreateGroupDoneButton style:UIBarButtonItemStyleDone target:nil action:@selector(doneButtonPressed)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:OMMCreateGroupCabcelButton style:UIBarButtonItemStylePlain target:nil action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    self.doneButton.enabled = NO;
    self.navigationItem.leftBarButtonItem = cancelButton;
    [self.groupNameTextField addTarget:self action:@selector(checkTextField) forControlEvents:UIControlEventEditingChanged];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.groupNameTextField becomeFirstResponder];
}


#pragma mark - methods

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    self.createNewGroup(self.groupNameTextField.text);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkTextField {
    if (self.groupNameTextField.text.length > 0) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}


#pragma mark - tableViews methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return OMMCreateGroupTitleForHeaderOfSectionGroup;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    return [UIView createViewForHeaderInSection:tableView withTitle:sectionTitle];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
        return 50.f;
}


@end
