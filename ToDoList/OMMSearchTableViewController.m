//
//  OMMSearchTableViewController.m
//  ToDoList
//
//  Created by Oleg Myatlikov on 15/06/2017.
//  Copyright © 2017 Oleg Myatlikov. All rights reserved.
//

#import "OMMSearchTableViewController.h"
#import "OMMTaskService.h"
#import "OMMTaskCell.h"
#import "OMMTaskDetailTableVC.h"

@interface OMMSearchTableViewController () <UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSArray *resultTaskArray;
@property (nonatomic, strong) UISearchController *searchController;
@property (assign, nonatomic) BOOL taskListWasModified;

@property (nonatomic, strong) NSPredicate *activeTasksPredicate;
@property (nonatomic, strong) NSPredicate *closedTasksPredicate;

@end


@implementation OMMSearchTableViewController

#pragma mark - constants

static NSString * const OMMsearchTaskIsOpen = @"closed = 0";
static NSString * const OMMsearchTaskIsClosed = @"closed = 1";
static NSString * const OMMsearchActiveTasks = @"Active tasks";
static NSString * const OMMsearchComplitedTasks = @"Completed";
static NSString * const OMMsearchClearText = @"";
static NSString * const OMMsearchNoResultText = @"No Result";
static NSString * const OMMSearchTaskCellIdentifier = @"OMMTaskCellIdentifier";
static NSString * const OMMSearchTaskCellXibName = @"OMMTaskCell";
static NSString * const OMMSearchTaskDetailVCIndentifair = @"OMMTaskDetailVCIndentifair";


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activeTasksPredicate = [NSPredicate predicateWithFormat:OMMsearchTaskIsOpen];
    self.closedTasksPredicate = [NSPredicate predicateWithFormat:OMMsearchTaskIsClosed];
    
    self.resultTaskArray = [self filterArrayUsingSelectScopeButton:[OMMTaskService sharedInstance].allTasksArray];
    
    //setup the search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[OMMsearchActiveTasks, OMMsearchComplitedTasks];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES; // hide searchController if present another viewController and do visible if go back
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerTaskListWasModify) name:OMMTaskServiceTaskWasModifyNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.taskListWasModified) {
        self.resultTaskArray = [self filterArrayUsingSelectScopeButton:[OMMTaskService sharedInstance].allTasksArray];
        self.searchController.searchBar.text = OMMsearchClearText;
        [self.tableView reloadData];
        self.taskListWasModified = NO;
        NSLog(@"Data was reloaded in today tab");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchController.searchBar becomeFirstResponder];
}


#pragma mark - methods

- (void)triggerTaskListWasModify {
    self.taskListWasModified = YES;
    NSLog(@"Data was changed. TRIGGER");
}

- (NSArray *)filterArrayUsingSelectScopeButton:(NSArray *)array {
    NSArray *resultArray = [[NSArray alloc] init];
    if (self.searchController.searchBar.selectedScopeButtonIndex == 0) {
        resultArray = [array filteredArrayUsingPredicate:self.activeTasksPredicate];
    } else {
        resultArray = [array filteredArrayUsingPredicate:self.closedTasksPredicate];
    }
    return resultArray;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultTaskArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:OMMSearchTaskCellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:OMMSearchTaskCellXibName bundle:nil] forCellReuseIdentifier:OMMSearchTaskCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:OMMSearchTaskCellIdentifier];
    }
    
    OMMTask *task = [self.resultTaskArray objectAtIndex:indexPath.row];
    cell.taskName.text = task.name;
    cell.taskNote.text = task.note;
    cell.taskStartDate.text = [task.startDate convertDateToLongDateString];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OMMTask *task = [self.resultTaskArray objectAtIndex:indexPath.row];
    OMMTaskDetailTableVC *taskDetails = [self.storyboard instantiateViewControllerWithIdentifier:OMMSearchTaskDetailVCIndentifair];
    taskDetails.task = task;
    [self.navigationController pushViewController:taskDetails animated:YES];
}


#pragma mark - search and update result

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultTaskArray = [self filterArrayUsingSelectScopeButton:[OMMTaskService sharedInstance].allTasksArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    if (searchText.length != 0) {
        self.resultTaskArray = [self.resultTaskArray filteredArrayUsingPredicate:predicate];
    }
}

// "No result" on dispaly if resultArray is empty

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.resultTaskArray.count > 0) {
        self.tableView.backgroundView = nil;
        return 1;
    }
    UILabel *noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    noResultLabel.text = OMMsearchNoResultText;
    [noResultLabel setFont:[UIFont systemFontOfSize:24 weight:normal]];
    noResultLabel.textColor = [UIColor lightGrayColor];
    noResultLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.backgroundView = noResultLabel;
    return 0;

}

// select scope another button

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if (selectedScope == 0) {
        self.resultTaskArray = [[OMMTaskService sharedInstance].allTasksArray filteredArrayUsingPredicate:self.activeTasksPredicate];
    } else {
        self.resultTaskArray = [[OMMTaskService sharedInstance].allTasksArray filteredArrayUsingPredicate:self.closedTasksPredicate];
    }
    [self.tableView reloadData];
    self.searchController.searchBar.text = OMMsearchClearText;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.resultTaskArray = [self filterArrayUsingSelectScopeButton:[OMMTaskService sharedInstance].allTasksArray];
}


@end
