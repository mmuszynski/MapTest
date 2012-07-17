//
//  DGViewController.h
//  MapTests
//
//  Created by Mike Muszynski on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define METERS_PER_MILE 1609.344

@interface DGViewController : UIViewController <UITextViewDelegate> {
    
    IBOutlet MKMapView *mapView;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    IBOutlet UILabel *locationLabel;
    IBOutlet UILabel *errorLabelHorizontal;
    IBOutlet UILabel *errorLabelVertical;
    
    IBOutlet UISlider *slider;
    IBOutlet UILabel *sliderLabel;
    
    IBOutlet UIButton *deletebutton;
    
    IBOutlet UITextView *feedbackTextView;
    
    NSMutableArray *feedbackArray;
    
    UIView *accessoryView;
    
    NSTimer *updateTimer;
    
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic) IBOutlet UIButton *toggleButton;

@property (nonatomic, retain) UIView IBOutlet *accessoryView;

-(IBAction)startGettingLocation:(id)sender;

@end
