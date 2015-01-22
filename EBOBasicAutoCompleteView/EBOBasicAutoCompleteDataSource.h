//
//  EBOBasicAutoCompleteDataSource.h
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import <Foundation/Foundation.h>

@class EBOBasicAutoCompleteView;

@protocol EBOBasicAutoCompleteDataSource <NSObject>

@required
- (void)autoCompleteView:(EBOBasicAutoCompleteView *)autoCompleteView suggestionsForQuery:(NSString *)query completeCallback:(void (^)(NSArray *))suggestionsCallback;

@end
