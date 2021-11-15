//
//  DebugLogFileManager.swift
//  
//
//  Created by Dominik Mocher on 03.11.21.
//

import CocoaLumberjackSwift
import Foundation

class DebugLogFileManager: DDLogFileManagerDefault {
    private let dateFormat = "YYYY-MM-ddThh:mm:ss"
    private let logPrefix = "log_"
    private let logSuffix = ".txt"


    override init(logsDirectory: String?) {
        super.init(logsDirectory: logsDirectory)
    }

    override var newLogFileName: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return "\(logPrefix)\(dateFormatter.string(from: date))\(logSuffix)"
    }
}
