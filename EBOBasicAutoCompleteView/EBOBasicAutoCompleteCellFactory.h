//
//  EBOBasicAutoCompleteCellFactory.h
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import <Foundation/Foundation.h>

@protocol EBOBasicAutoCompleteCell;

@protocol EBOBasicAutoCompleteCellFactory <NSObject>

@required
- (UITableViewCell <EBOBasicAutoCompleteCell>*)createReusableCellWithIdentifier:(NSString *)identifier;

@end
