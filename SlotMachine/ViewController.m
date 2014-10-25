//
//  ViewController.m
//  SlotMachine
//
//  Created by Jack Youstra on 10/13/14.
//  Copyright (c) 2014 HouseMixer. All rights reserved.
//

#define SPEED 5.0f
#define TIMER_INTERVAL 0.01

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize rightScrollImages, centerScrollImages, leftScrollImages;

- (void)viewDidLoad {
    [super viewDidLoad];
    // init all arrays
    rightScrollImages = [[NSMutableArray alloc]init]; // ordered lowest to highest
    centerScrollImages = [[NSMutableArray alloc]init];
    leftScrollImages = [[NSMutableArray alloc]init];
    // setup boundaries
    /*
    scrollContainerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+(self.view.frame.size.height/4), self.view.frame.size.width, (self.view.frame.size.height/4)*3);
    scrollCoverView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/4);
    */
     [self.view bringSubviewToFront:scrollCoverView];
    
    // setup ghost delegate
    ghostKeyboard.delegate = self;
    ghostKeyboard.alpha = 0.0;
    // setup image view
    //scrollContainerView.backgroundColor = [UIColor clearColor];
    
    [self clearAndReset];
    
    //[NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(rotate:) userInfo:[NSNumber numberWithFloat:1.0f] repeats:YES];
}

-(void)createBar:(int)offset toArray:(NSMutableArray*)imageList{
    UIImage *slotStripImage = [UIImage imageNamed:@"Slot Strip Test"];
    CGSize imageSize = slotStripImage.size;
    float ratio = imageSize.width/imageSize.height;
    
    UIImageView *rightBar = [[UIImageView alloc]init];
    [scrollContainerView addSubview:rightBar];
    rightBar.contentMode = UIViewContentModeScaleAspectFit;
    rightBar.image = slotStripImage;
    rightBar.frame = CGRectMake(
                                self.view.frame.size.width/4+offset,
                                scrollCoverView.frame.origin.y,
                                ratio * rightBar.superview.frame.size.height * 1.1,
                                rightBar.superview.frame.size.height * 1.1); // to add on a little buffer space
    [imageList addObject:rightBar];
}

- (void)clearAndReset{
    if (rightTimer) {
        [rightTimer invalidate];
    }
    if (centerTimer) {
        [centerTimer invalidate];
    }
    if (leftTimer) {
        [leftTimer invalidate];
    }
    
    [rightScrollImages removeAllObjects];
    [centerScrollImages removeAllObjects];
    [leftScrollImages removeAllObjects];
    
    [self createBar:-400 toArray:rightScrollImages]; // right bar
    [self createBar:-200 toArray:centerScrollImages]; // mid bar
    [self createBar:0 toArray:leftScrollImages]; // left bar
}

-(void)viewDidAppear:(BOOL)animated{
    NSAssert([ghostKeyboard becomeFirstResponder], @"Didn't become first responder");
    ghostKeyboard.inputView = [[UIView alloc] initWithFrame:CGRectZero]; // hides software keyboard
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// c is spin
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    string = [string lowercaseString];
    if ([string isEqualToString:@"c"]) {
        // speed randomized between 0.5 & 1.5
        [self clearAndReset];
        rightTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(rotate:) userInfo:[Strip stripWithImages:rightScrollImages andSpeed:(SPEED * (drand48() + 0.5)) withExecutionSpeed:TIMER_INTERVAL] repeats:YES];
        centerTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(rotate:) userInfo:[Strip stripWithImages:centerScrollImages andSpeed:(SPEED * (drand48() + 0.5)) withExecutionSpeed:TIMER_INTERVAL] repeats:YES];
        leftTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(rotate:) userInfo:[Strip stripWithImages:leftScrollImages andSpeed:(SPEED * (drand48() + 0.5)) withExecutionSpeed:TIMER_INTERVAL] repeats:YES];
    }
    return NO; // keep old text, no reason to change background thing
}

-(void)rotate:(NSTimer*) sender{
    Strip *strip = (Strip*)[sender userInfo];
    strip.speed = [strip nextSpeed];
    // check if there is need for a new reel
    for (int i = 0; i < [strip.rollingImages count]; i++) {
        UIImageView *currentRibbon = [strip.rollingImages objectAtIndex:i];
        if (currentRibbon.tag == 0 && !(currentRibbon.frame.origin.y + currentRibbon.frame.size.height < currentRibbon.superview.frame.size.height + currentRibbon.superview.frame.origin.y)) {
            // if nothing at top, add something there
            currentRibbon.tag = 1;
            UIImageView *newRibbon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Slot Strip Test"]];
            newRibbon.tag = 0;
            [scrollContainerView addSubview:newRibbon];
            newRibbon.contentMode = UIViewContentModeScaleAspectFit;
            newRibbon.frame = CGRectMake(currentRibbon.frame.origin.x, currentRibbon.frame.origin.y + currentRibbon.frame.size.height*-1 /*needed 'cause of weird y values*/, currentRibbon.superview.frame.size.width, currentRibbon.superview.frame.size.height);
            [strip.rollingImages addObject:newRibbon];
        }
    }
    for (int i = 0; i < [strip.rollingImages count]; i++) {
        UIImageView *ribbon = [strip.rollingImages objectAtIndex:i];
        CGRect cgr = ribbon.frame;
        cgr.origin.y+=strip.speed;
        ribbon.frame = cgr;
        if (!CGRectContainsRect(cgr, scrollContainerView.frame) && !CGRectIntersectsRect(cgr, scrollContainerView.frame)) {
            [ribbon removeFromSuperview];
            [strip.rollingImages removeObject:ribbon];
            i--;
        }
    }
    if (strip.speed == 0) {
        [sender invalidate];
        // calculate distance from ground
        float tentativePosition = 0;
        for (UIImageView *currentRoller in strip.rollingImages) {
            if (currentRoller.frame.origin.y < scrollSelectView.frame.origin.y && currentRoller.frame.origin.y+currentRoller.frame.size.height >= scrollSelectView.frame.origin.y) {
                // inside selector portion
                tentativePosition = scrollSelectView.frame.origin.y - currentRoller.frame.origin.y; // gets distance between bottom of ribbon and bottom of selector view
                const int sizePerElement = currentRoller.frame.size.height/16; // 16 elements
                tentativePosition/=sizePerElement; // get number of element spaces in band (remember, ribbon starts at 16)
                tentativePosition+=1; // account for 0 offset
                
                UILabel *recordingLabel = [[UILabel alloc]initWithFrame:CGRectMake(currentRoller.frame.origin.x + 250, 305, 400, 100)];
                recordingLabel.text = [NSString stringWithFormat:@"%0.2f", tentativePosition];
                recordingLabel.font = [UIFont fontWithName:@"Arial" size:36.0f];
                [currentRoller.superview addSubview:recordingLabel];
                
                NSLog(@"%0.2f, %0.2f", tentativePosition, currentRoller.frame.origin.x);
                break;
            }
        }
    }
}

@end
