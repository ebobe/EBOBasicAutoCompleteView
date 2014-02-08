//
//  EBOBasicAutoCompleteView.m
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import "EBOBasicAutoCompleteView.h"

@interface EBOBasicAutoCompleteView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITextField *autoCompleteTextField;
@property (nonatomic, weak) UIViewController *presentingController;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *autoCompleteList;

@property (nonatomic, assign) CGSize keyboardSize;

@end

@implementation EBOBasicAutoCompleteView

- (id)initWithFrame:(CGRect)frame
          textField:(UITextField *)textField
           delegate:(id <EBOBasicAutoCompleteDelegate>)delegate
         dataSource:(id<EBOBasicAutoCompleteDataSource>)dataSource
        cellFactory:(id<EBOBasicAutoCompleteCellFactory>)cellFactory
presentingController:(UIViewController *)presentingController {
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        
        self.autoCompleteTextField = textField;
        self.autoCompleteDelegate = delegate;
        self.autoCompleteDataSource = dataSource;
        self.autoCompleteCellFactory = cellFactory;
        self.presentingController = presentingController;
        
        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(autoCompleteTextFieldDidChange:)
         name:UITextFieldTextDidChangeNotification
         object:self.autoCompleteTextField];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(autoCompleteTextFieldDidBeginEditing:)
         name:UITextFieldTextDidBeginEditingNotification
         object:self.autoCompleteTextField];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(autoCompleteTextFieldDidEndEditing:)
         name:UITextFieldTextDidEndEditingNotification
         object:self.autoCompleteTextField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [self addSubview:self.tableView];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)close {
    self.hidden = YES;
}

- (void)layoutAutoCompleteTableView {
    // Allow the delegate to position the table view
    if (self.autoCompleteDelegate) {
        [self.autoCompleteDelegate layoutAutoCompleteTableView];
        return;
    }
    
    CGFloat contextViewHeight = 0;
    CGFloat kbHeight = 0;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        contextViewHeight = self.presentingController.view.frame.size.height;
        kbHeight = self.keyboardSize.height;
    }
    else if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        contextViewHeight = self.presentingController.view.frame.size.width;
        kbHeight = self.keyboardSize.width;
    }
    
    CGFloat calculatedY = self.autoCompleteTextField.frame.origin.y + self.autoCompleteTextField.frame.size.height;
    CGFloat calculatedHeight = contextViewHeight - calculatedY - kbHeight;
    
    calculatedHeight += self.presentingController.tabBarController.tabBar.frame.size.height;
    
    CGPoint presentationPoint = [self.presentingController.view convertPoint:CGPointMake(self.autoCompleteTextField.frame.origin.x, calculatedY) fromView:self.autoCompleteTextField.superview];
    self.frame = CGRectMake(presentationPoint.x,
                            presentationPoint.y,
                            self.autoCompleteTextField.frame.size.width,
                            MIN(calculatedHeight, self.tableView.contentSize.height));
    
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - UIKeyboard Notification methods

- (void)keyboardDidShow:(NSNotification *)notification
{
    self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self layoutAutoCompleteTableView];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self close];
}

#pragma mark - UITextFieldText Editing Notification methods

- (void)autoCompleteTextFieldDidChange:(id)sender
{
    [self attemptAutoCompleteOfText:self.autoCompleteTextField.text];
}

- (void)autoCompleteTextFieldDidBeginEditing:(id)sender {
    [self layoutAutoCompleteTableView];
    [self attemptAutoCompleteOfText:nil];
}

- (void)autoCompleteTextFieldDidEndEditing:(id)sender {
    [self close];
}

- (void)attemptAutoCompleteOfText:(NSString *)text {
    [self.autoCompleteDataSource autoCompleteSuggestionsFor:text completeCallback:^(NSArray *suggestions) {
        [self passInSearchResults:suggestions];
    }];
}

- (void)passInSearchResults:(NSArray *)searchResults {
    if ([NSThread isMainThread]) {
        if (!searchResults)
        {
            self.autoCompleteList = nil;
            [self.tableView reloadData];
            self.hidden = YES;
        }
        else {
            self.autoCompleteList = searchResults;
            [self.tableView reloadData];
            self.hidden = NO;
            
            if (self.tableView.frame.size.height == 0) {
                [self layoutAutoCompleteTableView];
            }
        }
    }
    else {
        [self performSelectorOnMainThread:@selector(passInSearchResults:) withObject:searchResults waitUntilDone:NO];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.autoCompleteList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"EBOBasicAutoCompleteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        if (self.autoCompleteCellFactory)
            cell = [self.autoCompleteCellFactory createReusableCellWithIdentifier:identifier];
        else
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    NSObject *autoCompleteValue = self.autoCompleteList[indexPath.row];
    NSAssert([autoCompleteValue isKindOfClass:[NSString class]], @"autoCompleteValue must be an NSString");
    
    // EBOBasicAutoCompleteCell
    if ([cell conformsToProtocol:@protocol(EBOBasicAutoCompleteCell)]) {
        UITableViewCell <EBOBasicAutoCompleteCell> *completionCell = (UITableViewCell <EBOBasicAutoCompleteCell> *) cell;
        
        if ([completionCell respondsToSelector:@selector(updateText:)])
            [completionCell updateText:(NSString*)autoCompleteValue];
    }
    // By default, update the text on a UITableViewCell
    else {
        ((UITableViewCell *)cell).textLabel.text = (NSString*)autoCompleteValue;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *autoCompleteValue = self.autoCompleteList[indexPath.row];
    NSAssert([autoCompleteValue isKindOfClass:[NSString class]], @"autoCompleteValue must be an NSString");
    
    self.autoCompleteTextField.text = (NSString*)autoCompleteValue;
    [self.autoCompleteTextField resignFirstResponder];
}

@end
