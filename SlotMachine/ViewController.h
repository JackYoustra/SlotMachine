//
//  ViewController.h
//  SlotMachine
//
//  Created by Jack Youstra on 10/13/14.
//  Copyright (c) 2014 HouseMixer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Strip.h"

@interface ViewController : UIViewController <UITextFieldDelegate>{
    __weak IBOutlet UITextField *ghostKeyboard;
    __weak IBOutlet UIView *scrollContainerView;
    __weak IBOutlet UIView *scrollCoverView;
    __weak IBOutlet UIView *scrollSelectView;
    
    NSTimer *rightTimer;
    NSTimer *centerTimer;
    NSTimer *leftTimer;
}

@property(nonatomic) NSMutableArray *rightScrollImages;
@property(nonatomic) NSMutableArray *centerScrollImages;
@property(nonatomic) NSMutableArray *leftScrollImages;


@end

