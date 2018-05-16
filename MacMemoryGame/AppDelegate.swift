//
//  AppDelegate.swift
//  MacMemoryGame
//
//  Created by Janne Käki on 15/05/2018.
//  Copyright © 2018 Awesomeness Factory Oy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.contentViewController = ViewController()
        window.setContentSize(NSSize(width: 326, height: 326))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

