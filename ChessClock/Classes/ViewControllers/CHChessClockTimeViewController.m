//
//  CHChessClockTimeViewController.m
//  Chess.com
//
//  Created by Pedro Bolaños on 11/1/12.
//  Copyright (c) 2012 psbt. All rights reserved.
//

#import "CHChessClockTimeViewController.h"

enum CHTimeComponents {
    CHTimeComponentHours,
    CHTimeComponentMinutes,
    CHTimeComponentSeconds
};

//------------------------------------------------------------------------------
#pragma mark - Private methods declarations
//------------------------------------------------------------------------------
@interface CHChessClockTimeViewController()

@property (assign, nonatomic) IBOutlet UIView *timePickerParentView;
@property (assign, nonatomic) IBOutlet UIPickerView* timePickerView;

@property (retain, nonatomic) NSMutableArray* components;
@property (retain, nonatomic) NSDictionary* rowsDictionary;

@end

//------------------------------------------------------------------------------
#pragma mark - CHChessClockTimeViewController implementation
//------------------------------------------------------------------------------
@implementation CHChessClockTimeViewController

static const NSUInteger CHPickerRowLabelTag = 10;

- (void)dealloc
{
    _delegate = nil;
    
    [_components release];
    [_rowsDictionary release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    if (self.maximumHours != 0) {
        [self.components addObject:[NSNumber numberWithInt:CHTimeComponentHours]];
    }
    
    if (self.maximumMinutes != 0) {
        [self.components addObject:[NSNumber numberWithInt:CHTimeComponentMinutes]];
    }
    
    if (self.maximumSeconds != 0) {
        [self.components addObject:[NSNumber numberWithInt:CHTimeComponentSeconds]];
    }
    
    [self selectInitialTime];
    [self createSelectionIndicatorLabels];
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0f, self.timePickerView.bounds.size.height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUInteger selectedTime = [self calculateSelectedTime];
    NSUInteger componentsCount = [self.components count];
    
    if (!self.zeroSelectionAllowed && selectedTime == 0 && [self.components count] != 0) {
        // The default component is the middle one!
        NSUInteger defaultComponent = componentsCount / 2.0f;
        
        NSNumber* firstComponent = [self.components objectAtIndex:defaultComponent];
        NSArray* rowsForFirstComponent = [self.rowsDictionary objectForKey:firstComponent];
     
        if ([rowsForFirstComponent count] > 1) {
            NSUInteger defaultTime = [[rowsForFirstComponent objectAtIndex:1] integerValue];
     
            if ([firstComponent integerValue] == CHTimeComponentHours) {
                defaultTime *= 3600;
            }
            else if ([firstComponent integerValue] == CHTimeComponentMinutes) {
                defaultTime *= 60;
            }
     
            selectedTime = defaultTime;
        }
     }
    
    [self.delegate chessClockTimeViewController:self closedWithSelectedTime:selectedTime];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for (NSUInteger i = 0; i < [self.components count]; i++) {
        UILabel* label = (UILabel*)[self.timePickerParentView viewWithTag:i + 1];
        CGRect frame = label.frame;
        frame.origin = [self selectionIndicatorPositionForComponent:i];
        label.frame = frame;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Private methods definitions
//------------------------------------------------------------------------------
- (NSMutableArray*)components
{
    if (_components == nil) {
        _components = [[NSMutableArray array] retain];
    }
    
    return _components;
}

- (NSDictionary*)rowsDictionary
{
    if (_rowsDictionary == nil) {
        _rowsDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
                           [self arrayForTimeComponentWithMaximumValue:self.maximumHours],
                           [NSNumber numberWithInt:CHTimeComponentHours],
                           [self arrayForTimeComponentWithMaximumValue:self.maximumMinutes],
                           [NSNumber numberWithInt:CHTimeComponentMinutes],
                           [self arrayForTimeComponentWithMaximumValue:self.maximumSeconds],
                           [NSNumber numberWithInt:CHTimeComponentSeconds],
                           nil] retain];
                           
    }
    
    return _rowsDictionary;
}

- (NSArray*)arrayForTimeComponentWithMaximumValue:(NSUInteger)maximumValue
{
    NSMutableArray* componentArray = [NSMutableArray arrayWithCapacity:maximumValue];
    for (NSUInteger i = 0; i < maximumValue; i++) {
        [componentArray addObject:[NSNumber numberWithInt:i]];
    }

    return componentArray;
}

- (NSUInteger)calculateSelectedTime
{
    NSUInteger selectedTime = 0;
    
    for (NSUInteger i = 0; i < [self.timePickerView numberOfComponents]; i++) {
        NSNumber* component = [self.components objectAtIndex:i];
        NSArray* rowsInComponent = [self.rowsDictionary objectForKey:component];
        
        NSUInteger selectedRow = [self.timePickerView selectedRowInComponent:i];
        NSUInteger selectedValue = [[rowsInComponent objectAtIndex:selectedRow] intValue];
        
        if ([component intValue] == CHTimeComponentHours) {
            selectedTime += selectedValue * 3600;
        }
        else if ([component intValue] == CHTimeComponentMinutes) {
            selectedTime += selectedValue * 60;
        }
        else if ([component intValue] == CHTimeComponentSeconds) {
            selectedTime += selectedValue;
        }
    }
    
    return selectedTime;
}

- (void)selectInitialTime
{
    NSUInteger hours = self.selectedTime / 3600;
    NSUInteger minutes = (self.selectedTime / 60) % 60;
    NSUInteger seconds = self.selectedTime % 60;
    
    for (NSUInteger i = 0; i < [self.timePickerView numberOfComponents]; i++) {
        NSUInteger component = [[self.components objectAtIndex:i] intValue];
        NSUInteger row = 0;
        
        if (component == CHTimeComponentHours) {
            row = hours;
        }
        else if (component == CHTimeComponentMinutes) {
            row = minutes;
        }
        else if (component == CHTimeComponentSeconds) {
            row = seconds;
        }
        
        [self.timePickerView selectRow:row inComponent:i animated:NO];
    }
}

- (void)createSelectionIndicatorLabels
{
    UIFont* font = [UIFont boldSystemFontOfSize:18.0f];
    
    for (NSUInteger i = 0; i < [self.components count]; i++) {
        NSUInteger selectedRow = [self.timePickerView selectedRowInComponent:i];
        
        CGPoint position = [self selectionIndicatorPositionForComponent:i];
        CGRect frame = CGRectMake(position.x, position.y, 100.0f, 100.0f);
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        label.font = font;
        label.text = [self selectionIndicatorTextForRow:selectedRow inComponent:i];
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.tag = i + 1;
        [label sizeToFit];
                
        [self.timePickerParentView addSubview:label];
        [label release];
    }
}

- (CGPoint)selectionIndicatorPositionForComponent:(NSUInteger)component
{
    NSUInteger selectedRow = [self.timePickerView selectedRowInComponent:component];
    UIView* view = [self.timePickerView viewForRow:selectedRow forComponent:component];
    UILabel* label = (UILabel*)[view viewWithTag:CHPickerRowLabelTag];
    CGPoint transformedPoint = [view convertPoint:label.frame.origin toView:self.timePickerParentView];
 
    CGSize rowSize = [self.timePickerView rowSizeForComponent:component];
    CGFloat rowWidth = rowSize.width;
    CGFloat rowHeight = rowSize.height;

    CGFloat x = transformedPoint.x + (rowWidth * 0.42f);
    CGFloat y = transformedPoint.y + (rowHeight * 0.27f);
    
    return CGPointMake(x, y);
}

- (NSString*)selectionIndicatorTextForRow:(NSUInteger)row inComponent:(NSUInteger)component
{
    NSNumber* realComponent = [self.components objectAtIndex:component];
    NSArray* rowsInComponent = [self.rowsDictionary objectForKey:realComponent];
    NSNumber* value = [rowsInComponent objectAtIndex:row];
    NSString* text = nil;
    
    NSUInteger realComponentValue = [realComponent integerValue];
    
    if ([value integerValue] == 1) {
        if (realComponentValue == CHTimeComponentHours) {
            text = NSLocalizedString(@"hour", nil);
        }
        else if (realComponentValue == CHTimeComponentMinutes) {
            text = NSLocalizedString(@"min", @"Abbreviation for minute");
        }
        else if (realComponentValue == CHTimeComponentSeconds) {
            text = NSLocalizedString(@"sec", @"Abbreviation for second");
        }
    }
    else {
        if (realComponentValue == CHTimeComponentHours) {
            text = NSLocalizedString(@"hours", nil);
        }
        else if (realComponentValue == CHTimeComponentMinutes) {
            text = NSLocalizedString(@"mins", @"Abbreviation for minutes");
        }
        else if (realComponentValue == CHTimeComponentSeconds) {
            text = NSLocalizedString(@"secs", @"Abbreviation for seconds");
        }
    }
    
    return text;
}

//------------------------------------------------------------------------------
#pragma mark - UIPickerViewDataSource methods
//------------------------------------------------------------------------------
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self.components count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSNumber* componentNumber = [self.components objectAtIndex:component];
    return [[self.rowsDictionary objectForKey:componentNumber] count];
}

//------------------------------------------------------------------------------
#pragma mark - UIPickerViewDelegate methods
//------------------------------------------------------------------------------
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    if (view == nil) {
        CGSize rowSize = [pickerView rowSizeForComponent:component];
        view = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rowSize.width, rowSize.height)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rowSize.width * 0.37f, rowSize.height)];
        label.font = [UIFont boldSystemFontOfSize:21.0f];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentRight;
        label.tag = CHPickerRowLabelTag;
        [view addSubview:label];
        [label release];
    }
    
    UILabel* label = (UILabel*)[view viewWithTag:CHPickerRowLabelTag];

    if ([pickerView selectedRowInComponent:component] == row) {
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    }
    else {
        label.shadowOffset = CGSizeMake(0.0f, 0.0f);
    }
    
    NSNumber* componentNumber = [self.components objectAtIndex:component];
    NSNumber* value = [[self.rowsDictionary objectForKey:componentNumber] objectAtIndex:row];
    label.text = [NSString stringWithFormat:@"%d", [value integerValue]];

    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel* selectionIndicatorLabel = (UILabel*)[self.timePickerParentView viewWithTag:component + 1];
    
    if (!self.zeroSelectionAllowed && [self calculateSelectedTime] == 0) {
        [pickerView selectRow:1 inComponent:component animated:YES];
        selectionIndicatorLabel.text = [self selectionIndicatorTextForRow:1 inComponent:component];
        return;
    }
    
    UIView* view = [pickerView viewForRow:row forComponent:component];
    UILabel* label = (UILabel*)[view viewWithTag:CHPickerRowLabelTag];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    
    selectionIndicatorLabel.text = [self selectionIndicatorTextForRow:row inComponent:component];
    [selectionIndicatorLabel sizeToFit];
}

@end
