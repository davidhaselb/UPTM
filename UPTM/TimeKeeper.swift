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
    private var dailyUptime: [Date: TimeInterval] = [:]
    private let fileURL: URL
    
    
    init()
    {
        startTime = Date()
        self.fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("uptimeData.json")
                self.loadUptimeData()
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: nil, using: manageTime)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil, using: manageTime)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil, using: manageTime)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: nil, using: manageTime)
        self.start()
    }
    
    private func saveUptimeData() {
            do {
                let data = try JSONEncoder().encode(dailyUptime)
                try data.write(to: fileURL)
            } catch {
                print("Failed to save uptime data: \(error)")
            }
        }

        private func loadUptimeData() {
            do {
                let data = try Data(contentsOf: fileURL)
                dailyUptime = try JSONDecoder().decode([Date: TimeInterval].self, from: data)
            } catch {
                print("Failed to load uptime data: \(error)")
            }
        }

        func updateDailyUptime() {
            let today = calendar.startOfDay(for: Date())
            if let uptime = dailyUptime[today] {
                dailyUptime[today] = uptime + getElapsedTime()
            } else {
                dailyUptime[today] = getElapsedTime()
            }

            // Keep only the last 5 days
            let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: today)!
            dailyUptime = dailyUptime.filter { $0.key >= fiveDaysAgo }
            saveUptimeData()
        }

        func getLastFiveDaysUptime() -> [Date: TimeInterval] {
            return dailyUptime
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
