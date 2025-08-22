//
//  ContentView.swift
//  Calcify
//
//  Created by Nam Nguyễn on 22/8/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userDefaultsManager = UserDefaultsManager.shared
    @State private var showingSecretStorage = false
    
    var body: some View {
        Group {
            if !userDefaultsManager.hasSetPassword {
                // Lần đầu vào app - hiển thị màn hình thiết lập password
                PasswordSetupView()
            } else {
                // Đã có password - hiển thị calculator
                CalculatorView()
                    .onReceive(NotificationCenter.default.publisher(for: .showSecretStorage)) { _ in
                        showingSecretStorage = true
                    }
            }
        }
        .sheet(isPresented: $showingSecretStorage) {
            SecretStorageView()
        }
    }
}

// Notification để trigger việc hiển thị SecretStorageView
extension Notification.Name {
    static let showSecretStorage = Notification.Name("showSecretStorage")
}

#Preview {
    ContentView()
}
