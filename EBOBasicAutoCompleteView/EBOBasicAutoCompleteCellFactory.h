//
//  EBOBasicAutoCompleteCellFactory.h
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import <Foundation/Foundation.h>

@class EBOBasicAutoCompleteView;

@protocol EBOBasicAutoCompleteCell;

@protocol EBOBasicAutoCompleteCellFactory <NSObject>

@required
- (UITableViewCell *)autoCompleteView:(EBOBasicAutoCompleteView *)autoCompleteView createReusableCellWithIdentifier:(NSString *)identifier;

@optional
- (NSString *)identifierForAutoCompleteView:(EBOBasicAutoCompleteView *)autoCompleteView;

@end
