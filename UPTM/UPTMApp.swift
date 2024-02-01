//
//  UPTMApp.swift
//  UPTM
//
//  Created by David Haselberger on 25.01.24.
//

import SwiftUI

@main
struct UPTMApp: App {
    @State private var tk: TimeKeeper = TimeKeeper()
    
    private static var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .hour, .minute ]
        formatter.zeroFormattingBehavior = [ .pad ]
        formatter.allowsFractionalUnits = true
        return formatter
    }()
    
    
    
    
    var body: some Scene {
        
        MenuBarExtra {
            Button(action: {
                self.tk.isWorking = !self.tk.isWorking;
                self.tk.isRunning.toggle()
            }) {
                if(self.tk.isRunning && !self.tk.isWorking){
                    HStack{
                        Text("Switch to Work")
                        Image(systemName: "pause")
                    }
                }else
                {
                    HStack{
                        Text("Continue")
                        Image(systemName: "play")
                    }
                }
                Image(systemName: self.tk.isRunning ? "pause":"play")
            }
            Divider()
            Button("Quit"){
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("Q")
        } label:{
            if(self.tk.isRunning){
                HStack{
                    Text(UPTMApp.formatter.string(from: tk.elapsedTime)!)
                        .font(.system(.body, design: .monospaced))
                    Image(systemName: "stopwatch.fill")
                }
            }else{
                HStack{
                    Text("WORK")
                        .font(.system(.body, design: .monospaced))
                    Image(systemName: "stopwatch")
                }
            }
        }.menuBarExtraStyle(.menu)
    }
    
    
}
