//
//  HomeVC.m
//  MyForage
//
//  Created by Cora Jacobson on 1/5/21.
//

#import "HomeVC.h"
#import "MyForage-Swift.h"

@interface HomeVC ()

@property (nonatomic) NSDate *currentDate;
@property (nonatomic, copy) NSString *timeOfDay;
@property (nonatomic) NSArray<ForageSpot *> *forageSpots;
@property (nonatomic) NSUInteger forageSpotCount;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *youHaveLabel;
@property (nonatomic) UILabel *forageSpotsLabel;
@property (nonatomic) UILabel *todaysBestLabel;
@property (nonatomic) UILabel *bestForageSpotLabel;
@property (nonatomic) UILabel *chanceLabel;
@property (nonatomic) UILabel *typeLabel;
@property (nonatomic) UIImageView *imageView;

@end

@implementation HomeVC

- (instancetype)initWithCoordinator:(MainCoordinator *)theCoordinator
{
    if (self = [super init]) {
        _coordinator = theCoordinator;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    [self updateView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateView];
}

- (void)updateView
{
    [self saveCurrentDate];
    [self fetchForageSpots];
    _titleLabel.text = [NSString stringWithFormat:@"Good %@!", _timeOfDay];
    _forageSpotsLabel.text = [NSString stringWithFormat:@"%lu Forage Spots", _forageSpotCount];
    ForageSpot *bestSpot = _forageSpots.firstObject;
    _bestForageSpotLabel.text = [NSString stringWithFormat:@"%@", bestSpot.name];
    NSString *chance = @"Unknown";
    switch ((int)bestSpot.favorability) {
        case 0 ... 2:
            chance = @"Poor";
            break;
        case 3 ... 5:
            chance = @"Fair";
            break;
        case 6 ... 8:
            chance = @"Good";
            break;
        case 9 ... 10:
            chance = @"Excellent";
    }
    _chanceLabel.text = [NSString stringWithFormat:@"%@ Chance of Finding", chance];
    _typeLabel.text = [NSString stringWithFormat:@"%@ Mushrooms", bestSpot.mushroomType];
}

- (void)setUpView
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    _titleLabel = [[UILabel alloc] init];
    [self setUpLabelWithLabel:_titleLabel text:@"Hello!" fontSize:28.];
    [_titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50].active = YES;
    
    _youHaveLabel = [[UILabel alloc] init];
    [self setUpLabelWithLabel:_youHaveLabel text:@"You Have:" fontSize:20.];
    [_youHaveLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:30].active = YES;
    
    _forageSpotsLabel = [[UILabel alloc] init];
    [self setUpLabelWithLabel:_forageSpotsLabel text:@"0 Forage Spots" fontSize:28.];
    [_forageSpotsLabel.topAnchor constraintEqualToAnchor:_youHaveLabel.bottomAnchor constant:10].active = YES;
    
    _todaysBestLabel = [[UILabel alloc] init];
    [self setUpLabelWithLabel:_todaysBestLabel text:@"Today's Best Forage Spot:" fontSize:20.];
    [_todaysBestLabel.topAnchor constraintEqualToAnchor:_forageSpotsLabel.bottomAnchor constant:50].active = YES;
    
    _bestForageSpotLabel = [[UILabel alloc] init];
    [self setUpLabelWithLabel:_bestForageSpotLabel text:@"Forage Spot Title" fontSize:28.];
    [_bestForageSpotLabel.topAnchor constraintEqualToAnchor:_todaysBestLabel.bottomAnchor constant:10].active = YES;
    
    _imageView = [[UIImageView alloc] init];
    [self.view addSubview:_imageView];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_imageView.heightAnchor constraintEqualToConstant:200.].active = YES;
    [_imageView.widthAnchor constraintEqualToConstant:200.].active = YES;
    [_imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_imageView.topAnchor constraintEqualToAnchor:_bestForageSpotLabel.bottomAnchor constant:15].active = YES;
    _imageView.image = [UIImage imageNamed:@"Mushroom"];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentDetailVC)];
    [_imageView addGestureRecognizer:tapGesture];
    [_imageView setUserInteractionEnabled:YES];
    
    _chanceLabel = [[UILabel alloc] init];
    [self setUpLabelWithLabel:_chanceLabel text:@"Great Chance of Finding" fontSize:18.];
    [_chanceLabel.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:15].active = YES;
    
    _typeLabel = [[UILabel alloc] init];
    [self setUpLabelWithLabel:_typeLabel text:@"Mushrooms" fontSize:24.];
    [_typeLabel.topAnchor constraintEqualToAnchor:_chanceLabel.bottomAnchor constant:5].active = YES;
}

- (void)setUpLabelWithLabel:(UILabel *)label text:(NSString *)text fontSize:(CGFloat)size
{
    [self.view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont boldSystemFontOfSize:size];
    label.text = text;
    [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
}

- (void)saveCurrentDate
{
    _currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0.];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPOSIXLocale];
    [formatter setDateFormat:@"HH"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *timeString = [formatter stringFromDate:_currentDate];
    int timeInt = timeString.intValue;
    if (timeInt < 12) {
        _timeOfDay = @"Morning";
    } else if (timeInt < 17) {
        _timeOfDay = @"Afternoon";
    } else {
        _timeOfDay = @"Evening";
    }
}

- (void)fetchForageSpots
{
    _forageSpots = [self.coordinator fetchForageSpots];
    _forageSpotCount = _forageSpots.count;
}

-(void)presentDetailVC
{
    [self.coordinator presentDetailViewWithForageSpot:_forageSpots.firstObject];
}

@end
