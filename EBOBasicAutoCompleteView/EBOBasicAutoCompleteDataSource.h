//
//  EBOBasicAutoCompleteDataSource.h
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import <Foundation/Foundation.h>

@protocol EBOBasicAutoCompleteDataSource <NSObject>

@required
- (void)autoCompleteSuggestionsFor:(NSString *)query completeCallback:(void (^)(NSArray *))suggestionsCallback;

@end
