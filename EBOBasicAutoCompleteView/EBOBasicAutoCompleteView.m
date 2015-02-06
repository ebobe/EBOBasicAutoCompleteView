//
//  EBOBasicAutoCompleteView.m
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import "EBOBasicAutoCompleteView.h"

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.1
#endif

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
        self.tableView.backgroundColor = [UIColor whiteColor];
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

#pragma mark - Public Methods

- (void)dismiss {
    self.hidden = YES;
    self.autoCompleteList = nil;
}

#pragma mark - Private Methods

- (void)close {
    [self dismiss];
}

- (void)layoutAutoCompleteTableView {
    CGRect layoutFrame = [self frameForLayoutBelow];
    // If we cannot fit the table below the text field (between textfield and keyboard)
    if (layoutFrame.size.height < self.tableView.rowHeight) {
        // Attempt a layout above
        layoutFrame = [self frameForLayoutAbove];
    }
    self.frame = layoutFrame;
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (CGRect)frameForLayoutBelow {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect mainFrame = rootView.bounds;
    // The bottom of the screen
    CGFloat bottomOfScreen = CGRectGetMaxY(mainFrame);
    // Keyboard display height
    CGFloat kbHeight = 0;
    
    // iOS 8 actually returns the correct keyboard size per orientation, so always use the height
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        kbHeight = self.keyboardSize.height;
    }
    else if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        kbHeight = self.keyboardSize.height;
    }
    else if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        kbHeight = self.keyboardSize.width;
    }
    
    // Get the view from which we will display our AutoComplete TableView
    UIView *viewToDisplayFrom = nil;
    if (self.autoCompleteDelegate && [self.autoCompleteDelegate respondsToSelector:@selector(substitueViewToDisplayAutoCompleteView:)]) {
        viewToDisplayFrom = [self.autoCompleteDelegate substitueViewToDisplayAutoCompleteView:self];
    }
    if (!viewToDisplayFrom) {
        viewToDisplayFrom = self.autoCompleteTextField;
    }
    
    // Find the point at which to display our AutoComplete TableView
    CGPoint localOriginOfTable = CGPointMake(viewToDisplayFrom.frame.origin.x, viewToDisplayFrom.frame.origin.y + viewToDisplayFrom.frame.size.height);
    CGPoint presentationPoint = [self.presentingController.view convertPoint:localOriginOfTable fromView:viewToDisplayFrom.superview];
    
    // Window space origin of the Presenting Point
    CGPoint globalOriginOfPP = [self.presentingController.view convertPoint:presentationPoint toView:nil];
    
    // Correct for iOS 6, landscape mode
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0) {
        if (UIInterfaceOrientationLandscapeLeft == [UIApplication sharedApplication].statusBarOrientation) {
            globalOriginOfPP.y = globalOriginOfPP.x - rootView.frame.origin.x;
        }
        else if (UIInterfaceOrientationLandscapeRight == [UIApplication sharedApplication].statusBarOrientation) {
            globalOriginOfPP.y = rootView.frame.size.width - globalOriginOfPP.x;
        }
    }
    
    // The total remaining height
    CGFloat remainingHeight = (bottomOfScreen - kbHeight) - (globalOriginOfPP.y + rootView.bounds.origin.y);
    
    return CGRectMake(presentationPoint.x + self.contentInset.left,
                            presentationPoint.y + self.contentInset.top,
                            viewToDisplayFrom.frame.size.width - self.contentInset.left - self.contentInset.right,
                            MIN(remainingHeight, self.tableView.contentSize.height) - self.contentInset.top - self.contentInset.bottom);
}

- (CGRect)frameForLayoutAbove {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    // Get the view from which we will display our AutoComplete TableView
    UIView *viewToDisplayFrom = nil;
    if (self.autoCompleteDelegate && [self.autoCompleteDelegate respondsToSelector:@selector(substitueViewToDisplayAutoCompleteView:)]) {
        viewToDisplayFrom = [self.autoCompleteDelegate substitueViewToDisplayAutoCompleteView:self];
    }
    if (!viewToDisplayFrom) {
        viewToDisplayFrom = self.autoCompleteTextField;
    }
    
    // Find the point at which to display our AutoComplete TableView
    CGPoint localOriginOfTable = CGPointMake(viewToDisplayFrom.frame.origin.x, viewToDisplayFrom.frame.origin.y);
    CGPoint presentationPoint = [self.presentingController.view convertPoint:localOriginOfTable fromView:viewToDisplayFrom.superview];
    
    // Window space origin of the Presenting View Controllers view
    CGPoint globalOriginOfPVC = [self.presentingController.view convertPoint:self.presentingController.view.bounds.origin toView:nil];

    // Window space origin of the Presenting Point
    CGPoint globalOriginOfPP = [self.presentingController.view convertPoint:presentationPoint toView:nil];
    
    // Correct for iOS 6, landscape mode
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0) {
        if (UIInterfaceOrientationLandscapeLeft == [UIApplication sharedApplication].statusBarOrientation) {
            globalOriginOfPP.y = globalOriginOfPP.x - rootView.frame.origin.x;
        }
        else if (UIInterfaceOrientationLandscapeRight == [UIApplication sharedApplication].statusBarOrientation) {
            globalOriginOfPP.y = rootView.frame.size.width - globalOriginOfPP.x;
        }
    }
    
    // The total remaining height
    CGFloat remainingHeight = globalOriginOfPVC.y - globalOriginOfPP.y;
    
    return CGRectMake(presentationPoint.x + self.contentInset.left,
                      presentationPoint.y + self.contentInset.top,
                      viewToDisplayFrom.frame.size.width - self.contentInset.left - self.contentInset.right,
                      MAX(remainingHeight, -self.tableView.contentSize.height) - self.contentInset.top - self.contentInset.bottom);
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
    [self.autoCompleteDataSource autoCompleteView:self suggestionsForQuery:text completeCallback:^(NSArray *suggestions) {
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
            BOOL shouldLayout = self.autoCompleteList.count != searchResults.count;
            self.autoCompleteList = searchResults;
            [self.tableView reloadData];
            self.hidden = NO;
            
            if (self.tableView.frame.size.height == 0 || shouldLayout) {
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
    static NSString *eboCellIdentifier = @"EBOBasicAutoCompleteCell";
    
    // Try and get an identifier from the Cell Factory
    NSString *identifier = nil;
    if (self.autoCompleteCellFactory && [self.autoCompleteCellFactory respondsToSelector:@selector(identifierForAutoCompleteView:)]) {
        identifier = [self.autoCompleteCellFactory identifierForAutoCompleteView:self];
    }
    
    // If it's still nil, then just set to our default identifier
    if (!identifier) {
        identifier = eboCellIdentifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        if (self.autoCompleteCellFactory)
            cell = [self.autoCompleteCellFactory autoCompleteView:self createReusableCellWithIdentifier:identifier];
        else
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    if (!self.autoCompleteList || indexPath.row >= self.autoCompleteList.count) {
        return cell;
    }
    
    NSObject *autoCompleteValue = self.autoCompleteList[indexPath.row];
    NSAssert([autoCompleteValue isKindOfClass:[NSObject class]], @"autoCompleteValue must be an NSObject");
    
    // EBOBasicAutoCompleteCell
    if ([cell conformsToProtocol:@protocol(EBOBasicAutoCompleteCell)]) {
        UITableViewCell <EBOBasicAutoCompleteCell> *completionCell = (UITableViewCell <EBOBasicAutoCompleteCell> *)cell;
        
        if ([completionCell respondsToSelector:@selector(updateWithAutoCompleteObject:)])
            [completionCell updateWithAutoCompleteObject:autoCompleteValue];
    }
    // By default, update the text on a UITableViewCell
    else if ([autoCompleteValue isKindOfClass:[NSString class]]) {
        ((UITableViewCell *)cell).textLabel.text = (NSString*)autoCompleteValue;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *autoCompleteValue = self.autoCompleteList[indexPath.row];
    NSAssert([autoCompleteValue isKindOfClass:[NSObject class]], @"autoCompleteValue must be an NSObject");
    
    if (self.autoCompleteDelegate && [self.autoCompleteDelegate respondsToSelector:@selector(autoCompleteView:didSelectValue:)]) {
        [self.autoCompleteDelegate autoCompleteView:self didSelectValue:autoCompleteValue];
    }
    else if ([autoCompleteValue isKindOfClass:[NSString class]]) {
        self.autoCompleteTextField.text = (NSString*)autoCompleteValue;
    }
    
    [self.autoCompleteTextField resignFirstResponder];
}

@end
