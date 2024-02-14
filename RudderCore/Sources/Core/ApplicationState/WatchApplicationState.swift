//
//  WatchApplicationState.swift
//  Rudder
//
//  Created by Pallab Maiti on 29/01/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation
import RudderInternal

#if os(watchOS)

import WatchKit

class WatchApplicationState: ApplicationStateProtocol {
    let wkExtension: WKExtension
    let userDefaults: UserDefaultsWorkerProtocol

    var trackApplicationStateMessage: ((ApplicationStateMessage) -> Void) = { _  in }
    var refreshSessionIfNeeded: (() -> Void) = { }

    init(wkExtension: WKExtension, userDefaults: UserDefaultsWorkerProtocol) {
        self.wkExtension = wkExtension
        self.userDefaults = userDefaults
    }
        
    func willEnterForeground(notification: NSNotification) {
        refreshSessionIfNeeded()
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        trackApplicationStateMessage(ApplicationStateMessage(
            state: .opened,
            properties: getLifeCycleProperties(
                currentVersion: currentVersion,
                currentBuild: currentBuild,
                fromBackground: true
            )
        ))
    }
    
    func didFinishLaunching(notification: NSNotification) {
        let previousVersion: String? = userDefaults.read( .version)
        let previousBuild: String? = userDefaults.read( .build)
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if previousVersion == nil {
            trackApplicationStateMessage(ApplicationStateMessage(
                state: .installed,
                properties: getLifeCycleProperties(
                    currentVersion: currentVersion,
                    currentBuild: currentBuild
                )
            ))
        } else if currentVersion != previousVersion {
            trackApplicationStateMessage(ApplicationStateMessage(
                state: .updated,
                properties: getLifeCycleProperties(
                    previousVersion: previousVersion,
                    previousBuild: previousBuild,
                    currentVersion: currentVersion,
                    currentBuild: currentBuild
                )
            ))
        }
        
        trackApplicationStateMessage(ApplicationStateMessage(
            state: .opened,
            properties: getLifeCycleProperties(
                currentVersion: currentVersion,
                currentBuild: currentBuild,
                fromBackground: false
            )
        ))
        
        userDefaults.write(.version, value: currentVersion)
        userDefaults.write(.build, value: currentBuild)
    }
}

extension Notification.Name {
    func convert() -> NotificationName {
        switch self {
        case WKExtension.applicationDidEnterBackgroundNotification:
            return .didEnterBackground
        case WKExtension.applicationWillEnterForegroundNotification:
            return .willEnterForeground
        case WKExtension.applicationDidFinishLaunchingNotification:
            return .didFinishLaunching
        case WKExtension.applicationDidBecomeActiveNotification:
            return .didBecomeActive
        default:
            return .unknown
        }
    }
}

extension ApplicationState {
    static func current(
        notificationCenter: NotificationCenter,
        wkExtension: WKExtension = WKExtension.shared(),
        userDefaults: UserDefaultsWorkerProtocol,
        notifications: [Notification.Name] = [
            WKExtension.applicationDidFinishLaunchingNotification,
            WKExtension.applicationWillEnterForegroundNotification,
            WKExtension.applicationDidEnterBackgroundNotification,
            WKExtension.applicationDidBecomeActiveNotification
        ]
    ) -> Self {
        self.init(
            notificationCenter: notificationCenter,
            application: WatchApplicationState(
                wkExtension: wkExtension,
                userDefaults: userDefaults
            ),
            notifications: notifications
        )
    }
}
#endif
