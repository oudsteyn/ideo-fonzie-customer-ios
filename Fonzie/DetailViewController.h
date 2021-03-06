//
//  DetailViewController.h
//  Fonzie
//
//  Created by John Oudsteyn on 6/29/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

