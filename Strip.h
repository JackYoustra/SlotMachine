//
//  Strip.h
//  SlotMachine
//
//  Created by Jack Youstra on 10/24/14.
//  Copyright (c) 2014 HouseMixer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Strip : NSObject{
    int speedRotation;
    float execSpeed;
    float initSpeed;
}

@property(nonatomic) float endPos;
@property(nonatomic) float speed;
@property(nonatomic) NSMutableArray *rollingImages;

+(Strip*)stripWithImages: (NSArray*)images andSpeed: (float)speed withExecutionSpeed: (float)execSpeed;

-(float)nextSpeed;

@end
