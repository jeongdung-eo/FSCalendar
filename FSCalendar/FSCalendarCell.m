//
//  FSCalendarCell.m
//  Pods
//
//  Created by Wenchao Ding on 12/3/15.
//
//

#import "FSCalendarCell.h"
#import "FSCalendar.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarConstants.h"

@interface FSCalendarCell ()
//오늘 날짜 dot label color
@property (readonly, nonatomic) UIColor *colorForTodayDotLabel;
@property (readonly, nonatomic) UIColor *colorForCellFill;
@property (readonly, nonatomic) UIColor *colorForTitleLabel;
@property (readonly, nonatomic) UIColor *colorForSubtitleLabel;
@property (readonly, nonatomic) UIColor *colorForCellBorder;
@property (readonly, nonatomic) NSArray<UIColor *> *colorsForEvents;
@property (readonly, nonatomic) CGFloat borderRadius;

@end

@implementation FSCalendarCell

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{   
    UILabel *label;
    CAShapeLayer *shapeLayer;
    UIImageView *imageView;
    FSCalendarEventIndicator *eventIndicator;

     // 오늘 날짜 dot label
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:label];
    self.todayDotLabel = label;
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;    
    [self.contentView addSubview:label];
    self.titleLabel = label;
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;   
    [self.contentView addSubview:label];
    self.subtitleLabel = label;
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.borderWidth = 1.0;
    shapeLayer.borderColor = [UIColor clearColor].CGColor;
    shapeLayer.opacity = 0;
    [self.contentView.layer insertSublayer:shapeLayer below:_todayDotLabel.layer];
    self.shapeLayer = shapeLayer;
    
    eventIndicator = [[FSCalendarEventIndicator alloc] initWithFrame:CGRectZero];
    eventIndicator.backgroundColor = [UIColor clearColor];
    eventIndicator.hidden = YES;
    [self.contentView addSubview:eventIndicator];
    self.eventIndicator = eventIndicator;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeBottom|UIViewContentModeCenter;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    self.clipsToBounds = NO;
    self.contentView.clipsToBounds = NO;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_subtitle) {
        _subtitleLabel.text = _subtitle;
        if (_subtitleLabel.hidden) {
            _subtitleLabel.hidden = NO;
        }
    } else {
        if (!_subtitleLabel.hidden) {
            _subtitleLabel.hidden = YES;
        }
    }
    
    if (_subtitle) {

        //.weak 버전일 때 

        [_todayDotLabel.topAnchor constraintEqualToAnchor: self.topAnchor ].active = YES;
        [_todayDotLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        
        [_titleLabel.topAnchor constraintEqualToAnchor:self.todayDotLabel.bottomAnchor ].active = YES;
        [_titleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        
        [_subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:20.0].active = YES;
        [_subtitleLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    
    } else {
        // .month 버전일 때 

        CGFloat todayHeight = self.todayDotLabel.font.lineHeight;
        [_todayDotLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:1.0].active = YES;
        [_todayDotLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        
        [_titleLabel.topAnchor constraintEqualToAnchor:self.todayDotLabel.bottomAnchor constant:2.0].active = YES;
        [_titleLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [_titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant: -1.0].active = YES;
    }
    
    _imageView.frame = CGRectMake(self.preferredImageOffset.x, self.preferredImageOffset.y, self.contentView.fs_width, self.contentView.fs_height);
    
    CGFloat titleHeight = self.bounds.size.height*5.0/6.0;
    CGFloat diameter = MIN(self.bounds.size.height*5.0/6.0,self.bounds.size.width);
    diameter = diameter > FSCalendarStandardCellDiameter ? (diameter - (diameter-FSCalendarStandardCellDiameter)*0.5) : diameter;
     // .month인 경우 border 사이즈 // 월간 캘린더 셀 중앙으로 
    if (!_subtitle) {
       _shapeLayer.frame = CGRectMake(5,
                                       5,
                                       self.bounds.size.width-8,
                                       self.bounds.size.width-8);
        // Calculate the center coordinates
        CGFloat centerX = CGRectGetMidX(self.bounds);
        CGFloat centerY = CGRectGetMidY(self.bounds);

        // Calculate the new origin based on the center coordinates and the size of the shape layer
        CGFloat newX = centerX - CGRectGetWidth(_shapeLayer.frame) / 2;
        CGFloat newY = centerY - CGRectGetHeight(_shapeLayer.frame) / 2;

        // Update the frame with the new origin
        _shapeLayer.frame = CGRectMake(newX, newY, CGRectGetWidth(_shapeLayer.frame), CGRectGetHeight(_shapeLayer.frame));
    } else {
     // .week인 경우 border 사이즈
        _shapeLayer.frame = CGRectMake(0,
                                       +1,
                                       self.bounds.size.width,
                                       self.bounds.size.height);
    }
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_shapeLayer.bounds
                                                cornerRadius:CGRectGetWidth(_shapeLayer.bounds)*0.5*self.borderRadius].CGPath;
    if (!CGPathEqualToPath(_shapeLayer.path,path)) {
        _shapeLayer.path = path;
    }
    
    CGFloat eventSize = _shapeLayer.frame.size.height/6.0;
    _eventIndicator.frame = CGRectMake(
                                       self.preferredEventOffset.x,
                                       CGRectGetMaxY(_shapeLayer.frame)+eventSize*0.17+self.preferredEventOffset.y,
                                       self.fs_width,
                                       eventSize*0.83
                                      );
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (self.window) { // Avoid interrupt of navigation transition somehow
        [CATransaction setDisableActions:YES]; // Avoid blink of shape layer.
    }
    self.shapeLayer.opacity = 0;
    [self.contentView.layer removeAnimationForKey:@"opacity"];
}

#pragma mark - Public

- (void)performSelecting
{
    _shapeLayer.opacity = 1;
        
    CAAnimationGroup *group = [CAAnimationGroup animation];
    // CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // zoomOut.fromValue = @0.3;
    // zoomOut.toValue = @1.2;
    // zoomOut.duration = FSCalendarDefaultBounceAnimationDuration/4*3;
    // CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // zoomIn.fromValue = @1.2;
    // zoomIn.toValue = @1.0;
    // zoomIn.beginTime = FSCalendarDefaultBounceAnimationDuration/4*3;
    // zoomIn.duration = FSCalendarDefaultBounceAnimationDuration/4;
    // group.duration = FSCalendarDefaultBounceAnimationDuration;
    // group.animations = @[zoomOut, zoomIn];
    [_shapeLayer addAnimation:group forKey:@"bounce"];
    [self configureAppearance];
    
}

#pragma mark - Private

- (void)configureAppearance
{
    UIColor *textColor = self.colorForTitleLabel;
    if (![textColor isEqual:_titleLabel.textColor]) {
        _titleLabel.textColor = textColor;
    }
    UIFont *titleFont = self.calendar.appearance.titleFont;
    if (![titleFont isEqual:_titleLabel.font]) {
        _titleLabel.font = titleFont;
    }
    if (_subtitle) {
        textColor = self.colorForSubtitleLabel;
        if (![textColor isEqual:_subtitleLabel.textColor]) {
            _subtitleLabel.textColor = textColor;
        }
        titleFont = self.calendar.appearance.subtitleFont;
        if (![titleFont isEqual:_subtitleLabel.font]) {
            _subtitleLabel.font = titleFont;
        }
    }
           // 오늘 날짜 dot label color, font 
    if (_todayDotLabel) {
        textColor = self.colorForTodayDotLabel;
        if (![textColor isEqual:_todayDotLabel.textColor]) {
            _todayDotLabel.textColor = textColor;
        }
        titleFont = self.calendar.appearance.todayTitleDotFont;
        if (![titleFont isEqual:_todayDotLabel.font]) {
            _todayDotLabel.font = titleFont;
        }
    }
    
    UIColor *borderColor = self.colorForCellBorder;
    UIColor *fillColor = self.colorForCellFill;
    
    BOOL shouldHideShapeLayer = !self.selected && !self.dateIsToday && !borderColor && !fillColor;
    
    if (_shapeLayer.opacity == shouldHideShapeLayer) {
        _shapeLayer.opacity = !shouldHideShapeLayer;
    }
    if (!shouldHideShapeLayer) {
        
        CGColorRef cellFillColor = self.colorForCellFill.CGColor;
        if (!CGColorEqualToColor(_shapeLayer.fillColor, cellFillColor)) {
            _shapeLayer.fillColor = cellFillColor;
        }
        
        CGColorRef cellBorderColor = self.colorForCellBorder.CGColor;
        if (!CGColorEqualToColor(_shapeLayer.strokeColor, cellBorderColor)) {
            _shapeLayer.strokeColor = cellBorderColor;
        }
        
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_shapeLayer.bounds
                                                    cornerRadius:CGRectGetWidth(_shapeLayer.bounds)*0.5*self.borderRadius].CGPath;
        if (!CGPathEqualToPath(_shapeLayer.path, path)) {
            _shapeLayer.path = path;
        }
        
    }
    
    if (![_image isEqual:_imageView.image]) {
        _imageView.image = _image;
        _imageView.hidden = !_image;
    }
    
    if (_eventIndicator.hidden == (_numberOfEvents > 0)) {
        _eventIndicator.hidden = !_numberOfEvents;
    }
    
    _eventIndicator.numberOfEvents = self.numberOfEvents;
    _eventIndicator.color = self.colorsForEvents;

}

- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected) {
        if (self.dateIsToday) {
            return dictionary[@(FSCalendarCellStateSelected|FSCalendarCellStateToday)] ?: dictionary[@(FSCalendarCellStateSelected)];
        }
        return dictionary[@(FSCalendarCellStateSelected)];
    }
    if (self.dateIsToday && [[dictionary allKeys] containsObject:@(FSCalendarCellStateToday)]) {
        return dictionary[@(FSCalendarCellStateToday)];
    }
    if (self.placeholder && [[dictionary allKeys] containsObject:@(FSCalendarCellStatePlaceholder)]) {
        return dictionary[@(FSCalendarCellStatePlaceholder)];
    }
    if (self.weekend && [[dictionary allKeys] containsObject:@(FSCalendarCellStateWeekend)]) {
        return dictionary[@(FSCalendarCellStateWeekend)];
    }
    return dictionary[@(FSCalendarCellStateNormal)];
}

#pragma mark - Properties

- (UIColor *)colorForCellFill
{
    if (self.selected) {
        return self.preferredFillSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
    }
    return self.preferredFillDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
}
// 오늘 날짜 dot label color
- (UIColor *)colorForTodayDotLabel
{
    if (self.selected) {
        return self.preferredTitleDotSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.todayTitleDotColors];
    }
    return self.preferredTitleTodayDotDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.todayTitleDotColors];
}

- (UIColor *)colorForTitleLabel
{
    if (self.selected) {
        return self.preferredTitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
    }
    return self.preferredTitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
}

- (UIColor *)colorForSubtitleLabel
{
    if (self.selected) {
        return self.preferredSubtitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
    }
    return self.preferredSubtitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
}

- (UIColor *)colorForCellBorder
{
    if (self.selected) {
        return _preferredBorderSelectionColor ?: _appearance.borderSelectionColor;
    }
    return _preferredBorderDefaultColor ?: _appearance.borderDefaultColor;
}

- (NSArray<UIColor *> *)colorsForEvents
{
    if (self.selected) {
        return _preferredEventSelectionColors ?: @[_appearance.eventSelectionColor];
    }
    return _preferredEventDefaultColors ?: @[_appearance.eventDefaultColor];
}

- (CGFloat)borderRadius
{
    return _preferredBorderRadius >= 0 ? _preferredBorderRadius : _appearance.borderRadius;
}

#define OFFSET_PROPERTY(NAME,CAPITAL,ALTERNATIVE) \
\
@synthesize NAME = _##NAME; \
\
- (void)set##CAPITAL:(CGPoint)NAME \
{ \
    BOOL diff = !CGPointEqualToPoint(NAME, self.NAME); \
    _##NAME = NAME; \
    if (diff) { \
        [self setNeedsLayout]; \
    } \
} \
\
- (CGPoint)NAME \
{ \
    return CGPointEqualToPoint(_##NAME, CGPointInfinity) ? ALTERNATIVE : _##NAME; \
}

OFFSET_PROPERTY(preferredTitleOffset, PreferredTitleOffset, _appearance.titleOffset);
OFFSET_PROPERTY(preferredSubtitleOffset, PreferredSubtitleOffset, _appearance.subtitleOffset);
OFFSET_PROPERTY(preferredImageOffset, PreferredImageOffset, _appearance.imageOffset);
OFFSET_PROPERTY(preferredEventOffset, PreferredEventOffset, _appearance.eventOffset);

#undef OFFSET_PROPERTY

- (void)setCalendar:(FSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _appearance = calendar.appearance;
        [self configureAppearance];
    }
}

- (void)setSubtitle:(NSString *)subtitle
{
    if (![_subtitle isEqualToString:subtitle]) {
        BOOL diff = (subtitle.length && !_subtitle.length) || (_subtitle.length && !subtitle.length);
        _subtitle = subtitle;
        if (diff) {
            [self setNeedsLayout];
        }
    }
}

@end


@interface FSCalendarEventIndicator ()

@property (weak, nonatomic) UIView *contentView;

@property (strong, nonatomic) NSPointerArray *eventLayers;

@end

@implementation FSCalendarEventIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        self.contentView = view;
        
        self.eventLayers = [NSPointerArray weakObjectsPointerArray];
        for (int i = 0; i < FSCalendarMaximumNumberOfEvents; i++) {
            CALayer *layer = [CALayer layer];
            layer.backgroundColor = [UIColor clearColor].CGColor;
            [self.contentView.layer addSublayer:layer];
            [self.eventLayers addPointer:(__bridge void * _Nullable)(layer)];
        }
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat diameter = MIN(MIN(self.fs_width, self.fs_height),FSCalendarMaximumEventDotDiameter);
    self.contentView.fs_height = self.fs_height;
    self.contentView.fs_width = (self.numberOfEvents*2-1)*diameter;
    self.contentView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        
        CGFloat diameter = MIN(MIN(self.fs_width, self.fs_height),FSCalendarMaximumEventDotDiameter);
        for (int i = 0; i < self.eventLayers.count; i++) {
            CALayer *eventLayer = [self.eventLayers pointerAtIndex:i];
            eventLayer.hidden = i >= self.numberOfEvents;
            if (!eventLayer.hidden) {
                eventLayer.frame = CGRectMake(2*i*diameter, (self.fs_height-diameter)*0.5, diameter, diameter);
                if (eventLayer.cornerRadius != diameter/2) {
                    eventLayer.cornerRadius = diameter/2;
                }
            }
        }
    }
}

- (void)setColor:(id)color
{
    if (![_color isEqual:color]) {
        _color = color;
        
        if ([_color isKindOfClass:[UIColor class]]) {
            for (NSInteger i = 0; i < self.eventLayers.count; i++) {
                CALayer *layer = [self.eventLayers pointerAtIndex:i];
                layer.backgroundColor = [_color CGColor];
            }
        } else if ([_color isKindOfClass:[NSArray class]]) {
            NSArray<UIColor *> *colors = (NSArray *)_color;
            for (int i = 0; i < self.eventLayers.count; i++) {
                CALayer *eventLayer = [self.eventLayers pointerAtIndex:i];
                eventLayer.backgroundColor = colors[MIN(i,colors.count-1)].CGColor;
            }
        }
        
    }
}

- (void)setNumberOfEvents:(NSInteger)numberOfEvents
{
    if (_numberOfEvents != numberOfEvents) {
        _numberOfEvents = MIN(MAX(numberOfEvents,0),FSCalendarMaximumNumberOfEvents);
        [self setNeedsLayout];
    }
}

@end


@implementation FSCalendarBlankCell

- (void)configureAppearance {}

@end



