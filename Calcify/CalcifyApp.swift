//
//  CalcifyApp.swift
//  Calcify
//
//  Created by Nam Nguyễn on 22/8/25.
//

import SwiftUI

@main
struct CalcifyApp: App {
    // Khởi tạo UserDefaultsManager khi app khởi động
    @StateObject private var userDefaultsManager = UserDefaultsManager.shared
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userDefaultsManager)
                .environmentObject(dataManager)
        }
    }
}
