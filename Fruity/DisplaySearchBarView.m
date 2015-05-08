//
//  DisplaySearchBarView.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/20/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "DisplaySearchBarView.h"
#import "GlobalVariables.h"

@interface DisplaySearchBarView ()

@property GlobalVariables *globalVs;

@property UILabel *displayFunctionLabel;
@property UITextField *searchBarTextField;
@property UITableView *displayAutoCompletedItemsTableView;

@property NSMutableArray *allFruitNames;
@property NSMutableArray *autoCompletedFruitNames;

// Used to enlarge the current view height so that user is able to choose the nth row in the table view
@property float frameHeight;

@end

@implementation DisplaySearchBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.allFruitNames = [[NSMutableArray alloc] initWithObjects:@"apple", @"apricot", @"avocado", @"banana", @"blackberry", @"blueberry", @"boysenberry", @"cherry", @"fig", @"grape", @"grapefruit", @"guava", @"kiwi", @"lemon", @"lime", @"melon", @"orange", @"pear", @"plum", @"pomegranate", @"raspberry", @"strawberry", nil];
        self.autoCompletedFruitNames = [[NSMutableArray alloc] init];
        
        self.frameHeight = self.frame.size.height;
        
        self.clipsToBounds = NO;
        
        self.globalVs = [GlobalVariables getInstance];
        
        self.displayFunctionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 3)];
        self.displayFunctionLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 4);
        self.displayFunctionLabel.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:20];
        self.displayFunctionLabel.textColor = self.globalVs.lightGreyColor;
        self.displayFunctionLabel.backgroundColor = [UIColor clearColor];
        self.displayFunctionLabel.text = @"Your fruits are not seasonal?";
        self.displayFunctionLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.displayFunctionLabel];
        
        self.searchBarTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * 2 / 3, self.frame.size.height / 2)];
        self.searchBarTextField.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height * 2 / 3);
        self.searchBarTextField.layer.cornerRadius = self.frame.size.height / 6;
        self.searchBarTextField.font  = [UIFont fontWithName:@"AvenirLTStd-Light" size:20];
        self.searchBarTextField.textColor = self.globalVs.darkGreyColor;
        self.searchBarTextField.backgroundColor = self.globalVs.blueColor;
        self.searchBarTextField.placeholder = @"fruit name";
        self.searchBarTextField.delegate = self;
        
        [self.searchBarTextField addTarget:self action:@selector(searchBarDidTouchDown) forControlEvents:UIControlEventTouchDown];
        
        // Set a space view to the left of the text in the text field so that the text would not be too close to the left edge of the text field
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height / 6, self.frame.size.height / 6)];
        [self.searchBarTextField setLeftViewMode:UITextFieldViewModeAlways];
        [self.searchBarTextField setLeftView:spacerView];
        [self.searchBarTextField setTintColor:self.globalVs.darkGreyColor];
        
        [self addSubview:self.searchBarTextField];
        
        self.displayAutoCompletedItemsTableView = [[UITableView alloc] initWithFrame:
                                 CGRectMake(self.frame.size.width / 6 + self.frame.size.height / 6, self.searchBarTextField.frame.origin.y + self.searchBarTextField.frame.size.height , self.frame.size.width * 2 / 3 - self.frame.size.height / 3, self.frame.size.height) style:UITableViewStylePlain];
        self.displayAutoCompletedItemsTableView.delegate = self;
        self.displayAutoCompletedItemsTableView.dataSource = self;
        self.displayAutoCompletedItemsTableView.scrollEnabled = YES;
        self.displayAutoCompletedItemsTableView.hidden = YES;
        self.displayAutoCompletedItemsTableView.backgroundColor = self.searchBarTextField.backgroundColor;
        [self.displayAutoCompletedItemsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self addSubview:self.displayAutoCompletedItemsTableView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(dismissKeyboard:)];
        tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)mainViewDidFinishAddingFruitToDB {
    [self.searchBarTextField resignFirstResponder];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frameHeight);
    self.displayAutoCompletedItemsTableView.hidden = YES;
}

- (void)dismissKeyboard:(UITapGestureRecognizer *)tap{
    CGPoint tapLocation = [tap locationInView:self];
    if (!CGRectContainsPoint(self.displayAutoCompletedItemsTableView.frame, tapLocation)) {
        [self.searchBarTextField resignFirstResponder];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frameHeight);
        self.displayAutoCompletedItemsTableView.hidden = YES;
    }
}

- (void) searchBarDidTouchDown{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 4 * self.frameHeight);
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    [self.autoCompletedFruitNames removeAllObjects];
    for(NSString *curString in self.allFruitNames) {
        NSRange substringRange = [curString rangeOfString:substring];
        NSRange subStringWithFirstLetterInUpperCaseRange = [[curString capitalizedString] rangeOfString:substring];
        if (substringRange.location == 0 || subStringWithFirstLetterInUpperCaseRange.location == 0) {
            [self.autoCompletedFruitNames addObject:curString];
        }
    }
    [self.displayAutoCompletedItemsTableView reloadData];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring
                 stringByReplacingCharactersInRange:range withString:string];
    
    self.displayAutoCompletedItemsTableView.hidden = NO;
    
    [self searchAutocompleteEntriesWithSubstring:substring];
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 4 * self.frameHeight);
    
    return YES;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.autoCompletedFruitNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [self.autoCompletedFruitNames objectAtIndex:indexPath.row];
    NSString *imageName = [[NSString alloc] initWithFormat:@"%@.png", cell.textLabel.text];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.frame = CGRectMake(0, 0, 200, 50);
    cell.backgroundColor = self.searchBarTextField.backgroundColor;
    cell.textLabel.font = self.globalVs.font;
    cell.textLabel.textColor = self.searchBarTextField.textColor;
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frameHeight);
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.searchBarTextField.text = @"";
    [self.superViewDelegate addFruitToDBFromSearchBar:selectedCell.textLabel.text];
    [self.searchBarTextField resignFirstResponder];

    
    //urlField.text = selectedCell.textLabel.text;
    
    //[self goPressed];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
