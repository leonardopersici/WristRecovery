//
//  StopWatch.swift
//  WristRecovery
//
//  Created by leonardo persici on 29/03/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

class Stopwatch {
    private var startTime: Date?
    private var accumulatedTime:TimeInterval = 0
    func start() -> Void {
        self.startTime = Date()
    }
    func stop() -> Void {
        self.accumulatedTime = self.elapsedTime()
        self.startTime = nil
    }
    func reset() -> Void {
        self.accumulatedTime = 0
        self.startTime = nil
    }
    func elapsedTime() -> TimeInterval {
        return -(self.startTime?.timeIntervalSinceNow ?? 0)+self.accumulatedTime
    }
}
