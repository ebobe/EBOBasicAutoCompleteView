//
//  EBOBasicAutoCompleteDelegate.h
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import <Foundation/Foundation.h>

@class EBOBasicAutoCompleteView;

@protocol EBOBasicAutoCompleteDelegate <NSObject>

@optional
- (void)layoutAutoCompleteView:(EBOBasicAutoCompleteView *)autoCompleteView;
- (void)autoCompleteView:(EBOBasicAutoCompleteView *)autoCompleteView didSelectValue:(NSObject *)autoCompleteValue;
- (CGFloat)heightForAutoCompleteTableView:(UITableView *)autoCompleteTableView;

@end
