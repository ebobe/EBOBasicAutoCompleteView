//
//  EBOBasicAutoCompleteView.h
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EBOBasicAutoCompleteDelegate.h"
#import "EBOBasicAutoCompleteDataSource.h"
#import "EBOBasicAutoCompleteCell.h"
#import "EBOBasicAutoCompleteCellFactory.h"

@interface EBOBasicAutoCompleteView : UIView

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) NSArray *autoCompleteList;

@property (nonatomic, strong) id <EBOBasicAutoCompleteDataSource> autoCompleteDataSource;
@property (nonatomic, strong) id <EBOBasicAutoCompleteDelegate> autoCompleteDelegate;
@property (nonatomic, strong) id <EBOBasicAutoCompleteCellFactory> autoCompleteCellFactory;

- (id)initWithFrame:(CGRect)frame
          textField:(UITextField *)textField
           delegate:(id <EBOBasicAutoCompleteDelegate>)delegate
         dataSource:(id <EBOBasicAutoCompleteDataSource>)dataSource
        cellFactory:(id <EBOBasicAutoCompleteCellFactory>)cellFactory
presentingController:(UIViewController *)presentingController;

@end
