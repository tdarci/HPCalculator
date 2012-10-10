//
//  HPCalcBrain.h
//  HPCalc
//
//  Created by Tom Darci on 10/9/12.
//  Copyright (c) 2012 So Much Fun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPCalcBrain : NSObject

- (void) pushOperand: (double) operand;
- (double) performOperation: (NSString *) operation;
- (void) clear;

@end
