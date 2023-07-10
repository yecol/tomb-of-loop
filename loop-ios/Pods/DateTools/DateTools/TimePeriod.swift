//
//  TimePeriod.swift
//  DateTools
//
//  Created by Grayson Webster on 8/17/16.
//  Copyright © 2016 Grayson Webster. All rights reserved.
//

import Foundation



/**
 # TimePeriod
 
 In DateTools, time periods are represented by the TimePeriod protocol. Required variables and method impleementations are bound below. An inheritable implementation of the TimePeriodProtocol is available through the TimePeriodClass
 
 [Visit our github page](https://github.com/MatthewYork/DateTools#time-periods) for more information.
 */
public protocol TimePeriodProtocol {
    
    // MARK: - Variables
    
    /**
     The start date for a TimePeriod representing the starting boundary of the time period
     */
    var beginning: Date? {get set}
    
    /**
     *  The end date for a TimePeriod representing the ending boundary of the time period
     */
    var end: Date? {get set}
}

public extension TimePeriodProtocol {
    
    
    // MARK: - Information
    
    var isMoment: Bool {
        return self.beginning == self.end
    }
    
    var years: Int {
        if self.beginning != nil && self.end != nil {
            return self.beginning!.yearsEarlierThan(self.end!)
        }
        return Int.max
    }
    
    var weeks: Int {
        if self.beginning != nil && self.end != nil {
            return self.beginning!.weeksEarlierThan(self.end!)
        }
        return Int.max
    }
    
    var days: Int {
        if self.beginning != nil && self.end != nil {
            return self.beginning!.daysEarlierThan(self.end!)
        }
        return Int.max
    }
    
    var hours: Int {
        if self.beginning != nil && self.end != nil {
            return self.beginning!.hoursEarlierThan(self.end!)
        }
        return Int.max
    }
    
    var minutes: Int {
        if self.beginning != nil && self.end != nil {
            return self.beginning!.minutesEarlierThan(self.end!)
        }
        return Int.max
    }
    
    var seconds: Int {
        if self.beginning != nil && self.end != nil {
            return self.beginning!.secondsEarlierThan(self.end!)
        }
        return Int.max
    }
    
    var chunk: TimeChunk {
        if beginning != nil && end != nil {
            return beginning!.chunkBetween(date: end!)
        }
        return TimeChunk(seconds: seconds, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    var duration: TimeInterval {
        if self.beginning != nil && self.end != nil {
            return abs(self.beginning!.timeIntervalSince(self.end!))
        }
        #if os(Linux)
            return TimeInterval(Double.greatestFiniteMagnitude)
        #else
            return TimeInterval(DBL_MAX)
        #endif
    }
    
    
    // MARK: - Time Period Relationships
    
    func relation(to period: TimePeriodProtocol) -> Relation {
        //Make sure that all start and end points exist for comparison
        if (self.beginning != nil && self.end != nil && period.beginning != nil && period.end != nil) {
            //Make sure time periods are of positive durations
            if (self.beginning!.earlier(than: self.end!) && period.beginning!.earlier(than: period.end!)) {
                
                //Make comparisons
                if (period.end!.earlier(than: self.beginning!)) {
                    return .after
                }
                else if (period.end!.equals(self.beginning!)){
                    return .startTouching;
                }
                else if (period.beginning!.earlier(than: self.beginning!) && period.end!.earlier(than: self.end!)){
                    return .startInside;
                }
                else if (period.beginning!.equals(self.beginning!) && period.end!.later(than: self.end!)){
                    return .insideStartTouching;
                }
                else if (period.beginning!.equals(self.beginning!) && period.end!.earlier(than: self.end!)){
                    return .enclosingStartTouching;
                }
                else if (period.beginning!.later(than: self.beginning!) && period.end!.earlier(than: self.end!)){
                    return .enclosing;
                }
                else if (period.beginning!.later(than: self.beginning!) && period.end!.equals(self.end!)){
                    return .enclosingEndTouching;
                }
                else if (period.beginning!.equals(self.beginning!) && period.end!.equals(self.end!)){
                    return .exactMatch;
                }
                else if (period.beginning!.earlier(than: self.beginning!) && period.end!.later(than: self.end!)){
                    return .inside;
                }
                else if (period.beginning!.earlier(than: self.beginning!) && period.end!.equals(self.end!)){
                    return .insideEndTouching;
                }
                else if (period.beginning!.earlier(than: self.end!) && period.end!.later(than: self.end!)){
                    return .endInside;
                }
                else if (period.beginning!.equals(self.end!) && period.end!.later(than: self.end!)){
                    return .endTouching;
                }
                else if (period.beginning!.later(than: self.end!)){
                    return .before;
                }
            }
        }
        
        return .none;
    }
    
    func equals(period: TimePeriodProtocol) -> Bool {
        return self.beginning == period.beginning && self.end == period.end
    }
    
    func inside(of period: TimePeriodProtocol) -> Bool {
        return period.beginning!.earlierThanOrEqual(to: self.beginning!) && period.end!.laterThanOrEqual(to: self.end!)
    }
    
    func contains(date: Date, interval: Interval) -> Bool {
        if (interval == .open) {
            return self.beginning!.earlier(than: date) && self.end!.later(than: date)
        }
        else if (interval == .closed){
            return (self.beginning!.earlierThanOrEqual(to: date) && self.end!.laterThanOrEqual(to: date))
        }
        
        return false
    }
    
    func contains(period: TimePeriodProtocol) -> Bool {
        return self.beginning!.earlierThanOrEqual(to: period.beginning!) && self.end!.laterThanOrEqual(to: period.end!)
    }
    
    func overlaps(with period: TimePeriodProtocol) -> Bool {
        //Outside -> Inside
        if (period.beginning!.earlier(than: self.beginning!) && period.end!.later(than: self.beginning!)) {
            return true;
        }
            //Enclosing
        else if (period.beginning!.laterThanOrEqual(to: self.beginning!) && period.end!.earlierThanOrEqual(to: self.end!)){
            return true;
        }
            //Inside -> Out
        else if(period.beginning!.earlier(than: self.end!) && period.end!.later(than: self.end!)){
            return true;
        }
        return false;
    }
    
    func intersects(with period: TimePeriodProtocol) -> Bool {
        return self.relation(to: period) != .after && self.relation(to: period) != .before
    }
    
    func hasGap(between period: TimePeriodProtocol) -> Bool {
        return self.isBefore(period: period) || self.isAfter(period: period)
    }
    
    func gap(between period: TimePeriodProtocol) -> TimeInterval {
        if (self.end!.earlier(than: period.beginning!)) {
            return abs(self.end!.timeIntervalSince(period.beginning!));
        }
        else if (period.end!.earlier(than: self.beginning!)){
            return abs(period.end!.timeIntervalSince(self.beginning!));
        }
        
        return 0
    }
    
    func gap(between period: TimePeriodProtocol) -> TimeChunk {
        return 0.days
    }
    
    func isAfter(period: TimePeriodProtocol) -> Bool {
        return self.relation(to: period) == .after
    }
    
    func isBefore(period: TimePeriodProtocol) -> Bool {
        return self.relation(to: period) == .before
    }
    
    // MARK: - Shifts
    
    //MARK: In Place
    mutating func shift(by interval: TimeInterval) {
        self.beginning?.addTimeInterval(interval)
        self.end?.addTimeInterval(interval)
    }
    
    mutating func shift(by chunk: TimeChunk) {
        self.beginning = self.beginning?.add(chunk)
        self.end = self.end?.add(chunk)
    }
    
    // MARK: - Lengthen / Shorten
    
    // MARK: In Place
    // Do not lengthen by month at anchor center. Month cannot be divided reliably.
    
    mutating func lengthen(by interval: TimeInterval, at anchor: Anchor) {
        switch anchor {
        case .beginning:
            self.end = self.end?.addingTimeInterval(interval)
            break
        case .center:
            self.beginning = self.beginning?.addingTimeInterval(-interval/2.0)
            self.end = self.end?.addingTimeInterval(interval/2.0)
            break
        case .end:
            self.beginning = self.beginning?.addingTimeInterval(-interval)
            break
        }
    }
    
    mutating func lengthen(by chunk: TimeChunk, at anchor: Anchor) {
        switch anchor {
        case .beginning:
            self.end = self.end?.add(chunk)
            break
        case .center:
            //timePeriod.beginning = beginning?.addingTimeInterval(-interval/2)
            //timePeriod.end = end?.addingTimeInterval(interval/2)
            break
        case .end:
            self.beginning = self.beginning?.subtract(chunk)
            break
        }
    }
    
    mutating func shorten(by interval: TimeInterval, at anchor: Anchor) {
        switch anchor {
        case .beginning:
            self.end = self.end?.addingTimeInterval(-interval)
            break
        case .center:
            self.beginning = self.beginning?.addingTimeInterval(interval/2.0)
            self.end = self.end?.addingTimeInterval(-interval/2.0)
            break
        case .end:
            self.beginning = self.beginning?.addingTimeInterval(interval)
            break
        }
    }
    
    mutating func shorten(by chunk: TimeChunk, at anchor: Anchor) {
        switch anchor {
        case .beginning:
            self.end = self.end?.subtract(chunk)
            break
        case .center:
            //timePeriod.beginning = beginning?.addingTimeInterval(-interval/2)
            //timePeriod.end = end?.addingTimeInterval(interval/2)
            break
        case .end:
            self.beginning = self.beginning?.add(chunk)
            break
        }
    }
}

/**
    # TimePeriod
    
    In DateTools, time periods are represented by the case TimePeriod class and come with a suite of initializaiton, manipulation, and comparison methods to make working with them a breeze.
 
    [Visit our github page](https://github.com/MatthewYork/DateTools#time-periods) for more information.
 */
open class TimePeriod: TimePeriodProtocol {
    
    /**
     The start date for a TimePeriod representing the starting boundary of the time period
     */
    public var beginning: Date?
    
    /**
     *  The end date for a TimePeriod representing the ending boundary of the time period
     */
    public var end: Date?
    
    // MARK: - Initializers
    
    init() {
        
    }
    
    init(beginning: Date?, end: Date?) {
        self.beginning = beginning
        self.end = end
    }
    
    init(beginning: Date, duration: TimeInterval) {
        self.beginning = beginning
        self.end = beginning + duration
    }
    
    init(end: Date, duration: TimeInterval) {
        self.end = end
        self.beginning = end.addingTimeInterval(-duration)
    }
    
    init(beginning: Date, duration: TimeChunk) {
        self.beginning = beginning
        self.end = beginning + duration
    }
    
    init(end: Date, duration: TimeChunk) {
        self.end = end
        self.beginning = end - duration
    }
    
    init(chunk: TimeChunk) {
        self.beginning = Date()
        self.end = self.beginning?.add(chunk)
    }
    
    //Mark: New
    func shifted(by interval: TimeInterval) -> TimePeriod {
        let timePeriod = TimePeriod()
        timePeriod.beginning = self.beginning?.addingTimeInterval(interval)
        timePeriod.end = self.end?.addingTimeInterval(interval)
        return timePeriod
    }
    
    func shifted(by chunk: TimeChunk) -> TimePeriod {
        let timePeriod = TimePeriod()
        timePeriod.beginning = self.beginning?.add(chunk)
        timePeriod.end = self.end?.add(chunk)
        return timePeriod
    }
    
    // MARK: - Lengthen / Shorten
    
    // MARK: New
    
    func lengthened(by interval: TimeInterval, at anchor: Anchor) -> TimePeriod {
        let timePeriod = TimePeriod()
        switch anchor {
        case .beginning:
            timePeriod.beginning = self.beginning
            timePeriod.end = self.end?.addingTimeInterval(interval)
            break
        case .center:
            timePeriod.beginning = self.beginning?.addingTimeInterval(-interval)
            timePeriod.end = self.end?.addingTimeInterval(interval)
            break
        case .end:
            timePeriod.beginning = self.beginning?.addingTimeInterval(-interval)
            timePeriod.end = self.end
            break
        }
        
        return timePeriod
    }
    
    func lengthened(by chunk: TimeChunk, at anchor: Anchor) -> TimePeriod {
        let timePeriod = TimePeriod()
        switch anchor {
        case .beginning:
            timePeriod.beginning = beginning
            timePeriod.end = end?.add(chunk)
            break
        case .center:
            //timePeriod.beginning = beginning?.addingTimeInterval(-interval/2)
            //timePeriod.end = end?.addingTimeInterval(interval/2)
            break
        case .end:
            timePeriod.beginning = beginning?.add(-chunk)
            timePeriod.end = end
            break
        }
        
        return timePeriod
    }
    
    func shortened(by interval: TimeInterval, at anchor: Anchor) -> TimePeriod {
        let timePeriod = TimePeriod()
        switch anchor {
        case .beginning:
            timePeriod.beginning = beginning
            timePeriod.end = end?.addingTimeInterval(-interval)
            break
        case .center:
            timePeriod.beginning = beginning?.addingTimeInterval(-interval/2)
            timePeriod.end = end?.addingTimeInterval(interval/2)
            break
        case .end:
            timePeriod.beginning = beginning?.addingTimeInterval(interval)
            timePeriod.end = end
            break
        }
        
        return timePeriod
    }
    
    func shortened(by chunk: TimeChunk, at anchor: Anchor) -> TimePeriod {
        let timePeriod = TimePeriod()
        switch anchor {
        case .beginning:
            timePeriod.beginning = beginning
            timePeriod.end = end?.subtract(chunk)
            break
        case .center:
            //timePeriod.beginning = beginning?.addingTimeInterval(-interval/2)
            //timePeriod.end = end?.addingTimeInterval(interval/2)
            break
        case .end:
            timePeriod.beginning = beginning?.add(-chunk)
            timePeriod.end = end
            break
        }
        
        return timePeriod
    }
    
    
    // MARK: - Operator Overloads
    
    // Default anchor = end
    static func +(leftAddend: TimePeriod, rightAddend: TimeInterval) -> TimePeriod {
        return leftAddend.lengthened(by: rightAddend, at: .beginning)
    }
    
    static func +(leftAddend: TimePeriod, rightAddend: TimeChunk) -> TimePeriod {
        return leftAddend.lengthened(by: rightAddend, at: .beginning)
    }
    
    // Default anchor = end
    static func -(minuend: TimePeriod, subtrahend: TimeInterval) -> TimePeriod {
        return minuend.shortened(by: subtrahend, at: .beginning)
    }
    
    static func -(minuend: TimePeriod, subtrahend: TimeChunk) -> TimePeriod {
        return minuend.shortened(by: subtrahend, at: .beginning)
    }
    
    static func ==(left: TimePeriod, right: TimePeriodProtocol) -> Bool {
        return left.equals(period: right)
    }
    
}
