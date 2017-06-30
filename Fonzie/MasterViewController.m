//
//  MasterViewController.m
//  Fonzie
//
//  Created by John Oudsteyn on 6/29/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "HistoryTableViewCell.h"
#import "History.h"

@interface MasterViewController () {
    UIRefreshControl* refreshControl;
}

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(fetchEvents) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = refreshControl;

    [self fetchEvents];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy HH:mm"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];

    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    [currencyFormatter setGroupingSeparator:groupingSeparator];
    [currencyFormatter setGroupingSize:3];
    [currencyFormatter setAlwaysShowsDecimalSeparator:NO];
    [currencyFormatter setUsesGroupingSeparator:YES];
    
    NSNumberFormatter *numFormatter = [NSNumberFormatter new];
    [numFormatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    History *h = self.objects[indexPath.row];

    NSString *type = [h.type uppercaseString];
    
    cell.type.text = type;
    cell.createdAt.text = [formatter stringFromDate:h.createdAt];
    cell.note.text = h.note;
    cell.odometer.text = [NSString stringWithFormat:@"%@ %@", [numFormatter stringFromNumber:h.odometer], @" mi."];
    
    if( [h.impact floatValue] <= 0) {
        float amount = 0;
        if ([type isEqualToString:@"COLLISION"]) {
            amount = [self randomFloatBetweenMin:150 max:400];
            
        } else if ([type isEqualToString:@"IRRESPONSIBLE"]) {
            amount = [self randomFloatBetweenMin:10 max:75];
            
        } else {
            amount = [self randomFloatBetweenMin:0 max:10];
            
        }
        
        h.impact = [NSNumber numberWithFloat:amount];
    }

    
    cell.impact.text = [NSString stringWithFormat:@"- %@", [currencyFormatter stringFromNumber:h.impact]];
    
    return cell;
}

    
- (float)randomFloatBetweenMin:(float)min max:(float)max {
    float diff = max - min;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + min;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


- (void)fetchEvents {
    NSDictionary *headers = @{ @"content-type": @"application/json",
                               @"x-api-key": @"SsjA0MdYOGag8xSmLomllZ0wk2zp2s1GrXrBxhWuwt",
                               @"cache-control": @"no-cache",
                               @"postman-token": @"d443aa44-6830-dc54-e795-a0d15befae58" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ideo-autonet-node.run.aws-usw02-pr.ice.predix.io/api/vehicle/event/all"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    [refreshControl endRefreshing];
                                                    
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        
                                                        
                                                        NSMutableDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                                        
                                                        NSArray *events = [s objectForKey:@"events"];
                                                        
                                                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                                                        // Always use this locale when parsing fixed format date strings
                                                        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                                                        [formatter setLocale:posix];

                                                        NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
                                                        numFormatter.numberStyle = NSNumberFormatterNoStyle;

                                                        
                                                        NSMutableArray<History *> *list = [[NSMutableArray alloc] init];
                                                        for( NSDictionary *dict in events ) {
                                                            History* h = [[History alloc] init];
                                                            
                                                            h.createdAt = [formatter dateFromString:[dict objectForKey:@"createdAt"]];
                                                            
                                                            h.identifier = [dict objectForKey:@"id"];
                                                            h.note = [dict objectForKey:@"message"];
                                                            h.odometer = [numFormatter numberFromString:[dict objectForKey:@"odometer"]];
                                                            h.type = [dict objectForKey:@"type"];
                                                            h.impact = [NSNumber numberWithFloat:-1];
                                                            
                                                            [list addObject:h];
                                                        }
                                                        
                                                        self.objects = list;
                                                        [self.tableView reloadData];
                                                    }
                                                }];
    [dataTask resume];
}


@end
