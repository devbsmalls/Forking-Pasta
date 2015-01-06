// Generated by IB v0.7.1 gem. Do not edit it manually
// Run `rake ib:open` to refresh

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AppDelegate: UIResponder <UIApplicationDelegate>
-(IBAction) setupDays;
-(IBAction) setupDefaultCategories;

@end

@interface DetailController: UITableViewController

@property IBOutlet UIBarButtonItem * saveButton;

-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) validate;
-(IBAction) save;
-(IBAction) cancel;
-(IBAction) nameDidChange:(id) sender;
-(IBAction) daysDidChange:(id) sender;
-(IBAction) textFieldShouldReturn:(id) textField;
-(IBAction) numberOfSectionsInTableView:(id) tableView;

@end

@interface EditCategoryController: UITableViewController

@property IBOutlet UIBarButtonItem * saveButton;

-(IBAction) viewDidLoad;
-(IBAction) save;
-(IBAction) cancel;
-(IBAction) nameDidChange:(id) sender;
-(IBAction) textFieldShouldReturn:(id) textField;
-(IBAction) numberOfSectionsInTableView:(id) tableView;

@end

@interface MainController: UIViewController

@property IBOutlet UIView * watchView;
@property IBOutlet UIImageView * clockImageView;
@property IBOutlet UILabel * periodNameLabel;
@property IBOutlet UILabel * timeRemainingLabel;

-(IBAction) viewDidLoad;
-(IBAction) viewDidAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) redraw;

@end

@interface OverviewController: UITableViewController

@property IBOutlet UISegmentedControl * dayControl;

-(IBAction) viewDidLoad;
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) viewWillDisappear:(id) animated;
-(IBAction) dismiss;
-(IBAction) dayChanged;

@end

@interface SelectCategoryController: UITableViewController
-(IBAction) viewWillAppear:(id) animated;
-(IBAction) toggleEditing:(id) sender;

@end

@interface SetTimeController: UIViewController

@property IBOutlet UIDatePicker * timePicker;

-(IBAction) viewDidLoad;
-(IBAction) done;

@end

@interface CategoryColorMark: UIView
-(IBAction) initWithFrame:(id) frame;
-(IBAction) initWithCoder:(id) aDecoder;
-(IBAction) color;
-(IBAction) drawRect:(id) rect;

@end

@interface CategoryColorCell: UITableViewCell

@property IBOutlet UILabel * colorNameLabel;
@property IBOutlet CategoryColorMark * colorMark;

@end

@interface CategoryNameCell: UITableViewCell

@property IBOutlet UITextField * nameTextField;

@end

@interface PeriodCategoryCell: UITableViewCell

@property IBOutlet UILabel * nameLabel;
@property IBOutlet CategoryColorMark * colorMark;

@end

@interface PeriodColorMark: UIView
-(IBAction) color;
-(IBAction) drawRect:(id) rect;

@end

@interface PeriodCell: UITableViewCell

@property IBOutlet PeriodColorMark * categoryColorMark;
@property IBOutlet UILabel * periodNameLabel;
@property IBOutlet UILabel * timeRangeLabel;

@end

@interface PeriodDayCell: UITableViewCell

@property IBOutlet UILabel * dayLabel;
@property IBOutlet UISwitch * daySwitch;

@end

@interface PeriodNameCell: UITableViewCell

@property IBOutlet UITextField * nameTextField;

@end

@interface SelectCategoryCell: UITableViewCell

@property IBOutlet UILabel * nameLabel;
@property IBOutlet CategoryColorMark * colorMark;

@end

