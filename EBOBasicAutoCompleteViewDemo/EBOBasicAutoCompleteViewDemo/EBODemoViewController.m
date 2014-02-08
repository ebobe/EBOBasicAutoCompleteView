//
//  EBODemoViewController.m
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import "EBODemoViewController.h"
#import "EBOBasicAutoCompleteView.h"
#import "EBOBasicAutoCompleteCell.h"

@interface TestCell : UITableViewCell<EBOBasicAutoCompleteCell>

@end

@implementation TestCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.textLabel.font = [UIFont systemFontOfSize:9];
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)updateText:(NSString *)text {
    self.textLabel.text = text;
}

@end

@interface EBODemoViewController ()

@property (nonatomic, strong) UITextField *testFieldSolo;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *testFieldNestedInTableViewCell;
@property (nonatomic, strong) EBOBasicAutoCompleteView *autoCompleteView;

@end

@implementation EBODemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        UITextField *testFieldSolo = [[UITextField alloc] init];
        testFieldSolo.borderStyle = UITextBorderStyleBezel;
        testFieldSolo.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:testFieldSolo];
        self.testFieldSolo = testFieldSolo;
        
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.layer.borderColor = [UIColor blackColor].CGColor;
        tableView.layer.borderWidth = 1;
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[testFieldSolo(>=60)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(testFieldSolo)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[tableView(>=200)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[testFieldSolo(<=30)]-70-[tableView(>=44)]-70-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(testFieldSolo, tableView)]];
        
        UITextField *testFieldNestedInTableViewCell = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 200, 30)];
        testFieldNestedInTableViewCell.borderStyle = UITextBorderStyleBezel;
        testFieldNestedInTableViewCell.backgroundColor = [UIColor lightGrayColor];
        testFieldNestedInTableViewCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.testFieldNestedInTableViewCell = testFieldNestedInTableViewCell;
        
        // Add the autocomplete view
        EBOBasicAutoCompleteView *autoCompleteView = [[EBOBasicAutoCompleteView alloc] initWithFrame:CGRectZero textField:self.testFieldSolo delegate:nil dataSource:self cellFactory:nil presentingController:self];
        autoCompleteView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:autoCompleteView];
        self.autoCompleteView = autoCompleteView;
        
        EBOBasicAutoCompleteView *autoCompleteView2 = [[EBOBasicAutoCompleteView alloc] initWithFrame:CGRectZero textField:self.testFieldNestedInTableViewCell delegate:nil dataSource:self cellFactory:nil presentingController:self];
        autoCompleteView2.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:autoCompleteView2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EBOBasicAutoCompleteDataSource

- (void)autoCompleteSuggestionsFor:(NSString *)query completeCallback:(void (^)(NSArray *))suggestionsCallback {
    NSArray *returnSuggestions = nil;
    if ([self.testFieldSolo isFirstResponder]) {
        returnSuggestions = @[@"blah"];
    }
    else if ([self.testFieldNestedInTableViewCell isFirstResponder]) {
        returnSuggestions = @[@"test"];
    }
    
    if (suggestionsCallback) {
        suggestionsCallback(returnSuggestions);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ParentTestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell.contentView addSubview:self.testFieldNestedInTableViewCell];
    }

    return cell;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
