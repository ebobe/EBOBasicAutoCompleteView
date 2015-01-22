//
//  EBOBasicAutoCompleteCell.h
//  EBOBasicAutoCompleteViewDemo
//
//  Created by Ian Smith on 2/6/14.
//
//

#import <Foundation/Foundation.h>

@protocol EBOBasicAutoCompleteCell <NSObject>

@required
- (void)updateWithAutoCompleteObject:(NSObject *)updateObject;

@end
