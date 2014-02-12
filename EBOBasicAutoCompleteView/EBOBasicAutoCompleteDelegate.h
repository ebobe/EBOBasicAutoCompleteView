//
//  EBOBasicAutoCompleteDelegate.h
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import <Foundation/Foundation.h>

@protocol EBOBasicAutoCompleteDelegate <NSObject>

@optional
- (void)layoutAutoCompleteTableView;

- (CGFloat)heightForAutoCompleteTableView:(UITableView *)autoCompleteTableView;

@end
