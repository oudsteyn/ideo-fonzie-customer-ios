//
//  History.h
//  Fonzie
//
//  Created by John Oudsteyn on 6/29/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface History : NSObject

@property (copy,nonatomic)NSDate* createdAt;
@property (copy,nonatomic)NSString* identifier;
@property (copy,nonatomic)NSNumber* impact;
@property (copy,nonatomic)NSNumber* odometer;
@property (copy,nonatomic)NSString* type;
@property (copy,nonatomic)NSString* note;

@end
