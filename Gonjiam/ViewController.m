//
//  ViewController.m
//  Gonjiam
//
//  Created by vapor on 2022/10/27.
//

#import "ViewController.h"

/*
 https://m.hwadamsup.com/reservation/reserveMain.do
 
 마우스위치 획득방법
 - 키보드 엔터 클릭시, 현재 마우스 위치가 콘솔창에 나타남.
 
 setUpDefaultSettings
 - 이용시간페이지에서(특정 날짜 지정하고 다음 페이지)  첫번째 시간 row 마우스위치 획득.
 - 이용시간페이지에서  최하단 "이전" 마우스위치 획득.
 - 이용시간페이지에서  최하단 "다음" 마우스위치 획득.
 - 이용권선택페이지에서 (이용시간페이지 다음 페이지) 성인 + 버튼 마우스위치 획득.
 
 startMacro
 - 특정날짜 지정하고, 이용시간페이지에서 키보드오른쪽 클릭하여 시작.
 - 08:00 ~ 16:40 총 26개 row 탐색.
 
 chrome  +67%
 
 */
@interface ViewController ()

@property (nonatomic) id eventMonitor;
@property BOOL isFinished;

@property int neededMemberCount;
@property int rowCount;

// mouse point
@property CGPoint startRowPoint;
@property CGPoint backPoint;
@property CGPoint nextPoint;
@property CGPoint plusMemberPoint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpDefaultSettings];
    
    [self observeKeyEvent];
}

- (void)setUpDefaultSettings
{
    self.neededMemberCount = 1;
    self.rowCount = 26;
    self.startRowPoint = CGPointMake(810, 355);
    self.backPoint = CGPointMake(448.355469, 1089.207031);
    self.nextPoint = CGPointMake(1131, 1089.207031);
    self.plusMemberPoint = CGPointMake(1704, 413.593750);
}

- (void)observeKeyEvent
{
    self.eventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                                               handler:^(NSEvent *event) {
        if (event.keyCode == 124) {  // right arrow
            self.isFinished = NO;
            [self startMacro];
        } else if (event.keyCode == 53) { // esc
            self.isFinished = YES;
        } else if (event.keyCode == 36) { //36 enter
//            [self findMouseLocation];
            [self testGetColor];
        }
    }];
    CGMainDisplayID();
}

- (void)startMacro {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            [NSThread sleepForTimeInterval:0.2];
            CGFloat nextY = self.startRowPoint.y; //355;
            CGFloat fixedX = self.startRowPoint.x;
            for (int idx = 0; idx < self.rowCount; idx++) {  // max 930
                if (self.isFinished) {
                    break;
                }
                
                CGPoint point = NSMakePoint(fixedX, nextY);
                if ([self isReservable:point]) {
                    CGPoint nextPoint = NSMakePoint(fixedX, nextY+2);
                    if ([self isReservable:nextPoint]) { // one more check
                        [self clickAt:nextPoint];
                        
                        [NSThread sleepForTimeInterval:0.4];
                        [self clickNext];
                        [NSThread sleepForTimeInterval:0.4];
                        
                        // member counting page
                        int member = 0;
                        while (member < self.neededMemberCount) {
                            [self clickMemberPlus];
                            [NSThread sleepForTimeInterval:0.1];
                            member ++;
                        }
                        [self clickNext];
                                    
                        // done
                        self.isFinished = YES;
                    }
                }
                NSLog(@"%d", (int)nextY);
                [NSThread sleepForTimeInterval:0.01];
                
                nextY += 25.79;
            }
            
            if (self.isFinished) {
                break;
            }
            
            [NSThread sleepForTimeInterval:0.1];
            [self clickBack];
            
            [NSThread sleepForTimeInterval:0.1];
            [self clickNext];
        }
            
    });
}

- (void)clickAt:(CGPoint)location
{
    CGEventRef mouseDown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, location, 0);
    CGEventRef mouseUp = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, location, 0);
    CGEventPost(kCGHIDEventTap, mouseDown);
    CGEventPost(kCGHIDEventTap, mouseUp);
}

- (BOOL)isReservable:(CGPoint)location {
    CGImageRef image = CGDisplayCreateImageForRect(CGMainDisplayID(), CGRectMake(location.x, location.y, 1, 1));
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    CGImageRelease(image);
    NSColor *color = [bitmap colorAtX:0 y:0];

    // NSColor *grayColor = [NSColor colorWithCalibratedRed:0.933333 green:0.933333 blue:0.933333 alpha:1];
    NSColor *successColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
    NSLog(@"\n * Test mouse point : %f, %f  \n * Color is : %@ \n * Can be reserved ??? \n", location.x, location.y, color.description);
    if ([color.description isEqualToString:successColor.description]) {
        NSLog(@" ---  YES🎉🎉🎉🎉!!!!!!");
        return YES;
    } else {
        NSLog(@" --- No......");
        return NO;
    }
}

- (void)clickBack {
    CGPoint location = self.backPoint;
    CGEventRef mouseDown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, location, 0);
    CGEventRef mouseUp = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, location, 0);
    CGEventPost(kCGHIDEventTap, mouseDown);
    CGEventPost(kCGHIDEventTap, mouseUp);
}

- (void)clickNext {
    CGPoint location = self.nextPoint;
    CGEventRef mouseDown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, location, 0);
    CGEventRef mouseUp = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, location, 0);
    CGEventPost(kCGHIDEventTap, mouseDown);
    CGEventPost(kCGHIDEventTap, mouseUp);
}

- (void)clickMemberPlus {
    CGPoint location = self.plusMemberPoint;
    CGEventRef mouseDown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, location, 0);
    CGEventRef mouseUp = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, location, 0);
    CGEventPost(kCGHIDEventTap, mouseDown);
    CGEventPost(kCGHIDEventTap, mouseUp);
}





#pragma mark - TEST

- (void)findMouseLocation
{
    CGEventRef event = CGEventCreate(NULL);
    CGPoint location = CGEventGetLocation(event);
    CFRelease(event);
    NSLog(@" Mouse point : %f,  %f", location.x, location.y);
}

// get Color by current mouse point
- (void)testGetColor {
    CGEventRef event = CGEventCreate(NULL);
    CGPoint location = CGEventGetLocation(event);
    CFRelease(event);

    CGImageRef image = CGDisplayCreateImageForRect(CGMainDisplayID(), CGRectMake(location.x, location.y, 1, 1));
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    CGImageRelease(image);
    NSColor *color = [bitmap colorAtX:0 y:0];
    
    // NSColor *grayColor = [NSColor colorWithCalibratedRed:0.933333 green:0.933333 blue:0.933333 alpha:1];
    NSColor *successColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
    
    NSLog(@"\n * Test mouse point : %f, %f  \n * Color is : %@ \n * Can be reserved ??? \n", location.x, location.y, color.description);
    if ([color.description isEqualToString:successColor.description]) {
        NSLog(@" ---  YES🎉🎉🎉🎉!!!!!!");
    } else {
        NSLog(@" --- No......");
    }
}
@end
