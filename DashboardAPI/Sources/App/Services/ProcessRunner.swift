//
//  ScriptRunner.swift
//  App
//
//  Created by Patrick Gatewood on 5/26/19.
//

import Foundation
@objc class ProcessRunner: NSObject {
    /**
     Runs a subprocess and returns its output
     
     - parameter launchPath: The executable to run
     - parameter args: Arguments to pass to the executable
     
     - returns: An optional String with contents of the process' standard output
     */
    @discardableResult
    static func shell(_ launchPath: String, _ args: [String]) -> String? {
        let process = Process()
        process.launchPath = launchPath
        process.arguments = args
        
        // Capture the process' output
        let pipe = Pipe()
        process.standardOutput = pipe
        
        // Run the process
        process.launch()
        process.waitUntilExit()
        
        if let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),  encoding: String.Encoding.utf8) {
            return output
        }
        return nil
    }
}
