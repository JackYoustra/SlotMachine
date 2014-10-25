//
//  Strip.m
//  SlotMachine
//
//  Created by Jack Youstra on 10/24/14.
//  Copyright (c) 2014 HouseMixer. All rights reserved.
//

#import "Strip.h"

@implementation Strip
@synthesize rollingImages, speed, endPos;

+(Strip *)stripWithImages:(NSArray *)images andSpeed:(float)speed withExecutionSpeed: (float)execSpeed{
    Strip* temp = [[Strip alloc]init];
    temp.rollingImages = [NSMutableArray arrayWithArray:images];
    temp.speed = speed;
    temp.endPos = 0;
    temp->initSpeed = speed;
    temp->speedRotation = 0;
    temp->execSpeed = execSpeed;
    return temp;
}

-(float)nextSpeed{
    speedRotation++;
    float seconds = speedRotation/(1/execSpeed);
    float velocity = (initSpeed/seconds)-initSpeed/2;
    if (velocity<0) {
        return 0;
    }
    return velocity;
}


@end
