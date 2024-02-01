import Combine
import AppKit
import Foundation
@Observable  class TimeKeeper: ObservableObject {
    private var startTime: Date
    private var accumulatedTime:TimeInterval = 0
    private var timer: Cancellable?
    let calendar = Calendar.current
    var isWorking = false {
        didSet {
            if self.isWorking {
                self.stop()
            } else {
                self.start()
            }
        }
    }
    var isRunning = true {
        didSet {
            if self.isRunning {
                self.start()
            } else {
                self.stop()
            }
        }
    }
    private(set) var elapsedTime: TimeInterval = 0
  
    init()
    {
        startTime = Date()
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: nil, using: manageTime)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil, using: manageTime)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil, using: manageTime)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: nil, using: manageTime)
        self.start()
    }
    
    private func manageTime(n: Notification) -> Void {
        if((n.name == NSWorkspace.screensDidSleepNotification)||(n.name == NSWorkspace.willSleepNotification)){
            self.stop();
        }
        
        if((n.name == NSWorkspace.screensDidWakeNotification)||(n.name == NSWorkspace.didWakeNotification)){
            let today = calendar.dateInterval(of: .day, for: self.startTime)
            let nextDate = Date()
            let dateDay = calendar.dateInterval(of: .day, for: nextDate)
            if(today == dateDay)
            {
                self.start();
            }else
            {
                self.reset();
            }
        }
    }
    
    private func start() -> Void {
        self.startTime = Date()
        if(isWorking == false){
            self.timer?.cancel()
            self.timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                       self.elapsedTime = self.getElapsedTime()
            }
        }
    }
    
    private func stop() -> Void {
        self.timer?.cancel()
        self.timer = nil
        self.accumulatedTime = self.elapsedTime
        //self.startTime = nil
    }
    
    func reset() -> Void {
        self.accumulatedTime = 0
        self.elapsedTime = 0
        self.startTime = Date()
        //self.isRunning = false
    }
    
    private func getElapsedTime() -> TimeInterval {
        return -(self.startTime.timeIntervalSinceNow )+self.accumulatedTime
    }
}
