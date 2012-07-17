//
//  DGViewController.m
//  MapTests
//
//  Created by Mike Muszynski on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGViewController.h"

#define FEET_PER_METER 3.28084

@interface DGViewController ()

@end

@implementation DGViewController
@synthesize toggleButton;

@synthesize currentLocation, locationManager, mapView, updateTimer, accessoryView;

NSDictionary *dataDict;
NSMutableArray *dataArray;
NSMutableArray *locationArray;
NSUserDefaults *defaults;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    currentLocation = [[CLLocation alloc] init];
      
    defaults = [NSUserDefaults standardUserDefaults];
    dataDict = [[NSDictionary alloc] init];
    
    if(dataArray == nil) {
        dataArray = [[NSMutableArray alloc] init];
    }
        
    if(![defaults objectForKey:@"FirstRun"] || ![[defaults objectForKey:@"StoredData"] isKindOfClass:[NSArray class]]) {
        [defaults setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"FirstRun"];
        [defaults setObject:dataArray forKey:@"StoredData"];
    } else {
        dataArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"StoredData"]];
    }
    
    if(![dataArray count])
        [deletebutton setEnabled:NO];
            
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setToggleButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)toggleLocationUpdates:(id)sender {
    
    //currentLocation = [locationManager location];
    //[mapView setRegion:MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 50 / FEET_PER_METER, 50 / FEET_PER_METER) animated:NO];
    
    if([toggleButton.titleLabel.text isEqualToString:@"Suspend Location Updates"]) {
        [self stopGettingLocation:self];
        [toggleButton setTitle:@"Begin Location Updates" forState:UIControlStateNormal];
    } else {
        [self startGettingLocation:self];
        [mapView setRegion:MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 500 / FEET_PER_METER, 500 / FEET_PER_METER) animated:NO];
        [toggleButton setTitle:@"Suspend Location Updates" forState:UIControlStateNormal];
    }
    
}

-(void)startGettingLocation:(id)sender {
    [self updateLocationInfo];
    
    updateTimer = [NSTimer timerWithTimeInterval:.5
                                          target:self
                                        selector:@selector(updateLocationInfo)
                                        userInfo:nil
                                         repeats:YES];
    
    locationArray = [[NSMutableArray alloc] init];
    
    [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSDefaultRunLoopMode];
    
}

-(void)stopGettingLocation:(id)sender {
    [updateTimer invalidate];
    [locationLabel setText:@"Not receiving data"];
    [errorLabelHorizontal setText:@"n/a"];
    [errorLabelVertical setText:@"n/a"];
    [locationManager stopUpdatingLocation];
    
    UIView *questionView;;
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"Questionnaire"
                                                    owner:self options:nil];
    
    for (id object in bundle) {
        if ([object isKindOfClass:[UIView class]]){
            questionView = (UIView*)object;
        }
    }

    [UIView transitionWithView:self.view duration:.3 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [self.view addSubview:questionView];
    } completion:nil];
    
}

-(IBAction)submitFeedbackPressed:(id)sender {
    
    //NSString *arrayAsString = [NSString stringWithFormat:@"%@", locationArray];
    NSString *text = feedbackTextView.text;
    NSString *sky = [NSString stringWithFormat:@"Sky Visible: %.f%%", slider.value];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
      
    dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                locationArray, @"LocationArray",
                text, @"Feedback",
                sky, @"SkyVisible",
                date, @"Date", nil];
    
    [dataArray addObject:dataDict];
    
    [UIView transitionWithView:self.view duration:.3 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [[[self.view subviews] lastObject] removeFromSuperview];
    } completion:nil];
        
    [defaults setObject:dataArray forKey:@"StoredData"];
    [defaults synchronize];
        
    if(![deletebutton isEnabled])
        [deletebutton setEnabled:YES];
   
}

-(IBAction)sendFeedback:(id)sender {
    
    NSString *feedback = [NSString stringWithFormat:@"%@", dataArray];
    
    [TestFlight submitFeedback:feedback];
    
    [dataArray removeAllObjects];
    [defaults setObject:dataArray forKey:@"StoredData"];
    [defaults synchronize];
    [deletebutton setEnabled:NO];
    
}

-(void)updateLocationInfo {
        
    [locationManager startUpdatingLocation];
    currentLocation = [locationManager location];
    
    [locationLabel setText:[NSString stringWithFormat:@"%.5f, %.5f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]];
    [errorLabelHorizontal setText:[NSString stringWithFormat:@"%.1f Feet", [currentLocation horizontalAccuracy] * FEET_PER_METER]];
    [errorLabelHorizontal setText:[NSString stringWithFormat:@"%.1f Feet", [currentLocation verticalAccuracy] * FEET_PER_METER]];
        
    [locationArray addObject:[NSString stringWithFormat:@"%@: (%f, %f), %f", currentLocation.timestamp, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, currentLocation.horizontalAccuracy]];
    
}

-(IBAction)updateSliderLabel:(id)sender {
    
    [sliderLabel setText:[NSString stringWithFormat:@"%.f%%", slider.value]];
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    
    NSLog(@"text view editing");
    
    if (feedbackTextView.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"AccessoryView" owner:self options:nil];
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        
        NSLog(@"%@", accessoryView);
        feedbackTextView.inputAccessoryView = accessoryView;
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.accessoryView = nil;
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
        
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
        
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
}


-(IBAction)clearTextView:(id)sender {
    
    [feedbackTextView setText:nil];
    
}

-(IBAction)dismissKeyboard:(id)sender {
    
    [feedbackTextView resignFirstResponder];
    
}


@end
