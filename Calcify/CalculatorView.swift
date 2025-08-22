import SwiftUI

struct CalculatorView: View {
    @ObservedObject var userDefaultsManager = UserDefaultsManager.shared
    @State private var displayValue = "0"
    @State private var currentOperation: Operation? = nil
    @State private var previousValue: Double? = nil
    @State private var newNumber = true
    @State private var passwordAttempt = ""
    
    enum Operation {
        case add, subtract, multiply, divide
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                // Display area - right above keyboard
                HStack {
                    Spacer()
                    Text(displayValue)
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.trailing, 24)
                }
                .frame(height: 120)
                .background(Color.black)
                
                // Calculator buttons - right below display
                VStack(spacing: 0) {
                    HStack(spacing: 1) {
                        CalculatorButton(title: "AC", color: .darkGray, action: clear, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "+/-", color: .darkGray, action: toggleSign, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "%", color: .darkGray, action: percentage, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "÷", color: .orange, action: { setOperation(.divide) }, size: geometry.size.width / 4 - 1)
                    }
                    
                    HStack(spacing: 1) {
                        CalculatorButton(title: "7", color: .darkGray, action: { appendNumber("7") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "8", color: .darkGray, action: { appendNumber("8") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "9", color: .darkGray, action: { appendNumber("9") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "×", color: .orange, action: { setOperation(.multiply) }, size: geometry.size.width / 4 - 1)
                    }
                    
                    HStack(spacing: 1) {
                        CalculatorButton(title: "4", color: .darkGray, action: { appendNumber("4") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "5", color: .darkGray, action: { appendNumber("5") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "6", color: .darkGray, action: { appendNumber("6") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "-", color: .orange, action: { setOperation(.subtract) }, size: geometry.size.width / 4 - 1)
                    }
                    
                    HStack(spacing: 1) {
                        CalculatorButton(title: "1", color: .darkGray, action: { appendNumber("1") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "2", color: .darkGray, action: { appendNumber("2") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "3", color: .darkGray, action: { appendNumber("3") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "+", color: .orange, action: { setOperation(.add) }, size: geometry.size.width / 4 - 1)
                    }
                    
                    HStack(spacing: 1) {
                        // Backspace button - delete last character
                        Button(action: {
                            deleteLastCharacter()
                        }) {
                            Image(systemName: "delete.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width / 4 - 1, height: geometry.size.width / 4 - 1)
                                .background(Color.darkGray)
                                .clipShape(Circle())
                        }
                        
                        CalculatorButton(title: "0", color: .darkGray, action: { appendNumber("0") }, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: ",", color: .darkGray, action: decimal, size: geometry.size.width / 4 - 1)
                        CalculatorButton(title: "=", color: .orange, action: calculate, size: geometry.size.width / 4 - 1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 25)
                .background(Color.black)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
    
    private func deleteLastCharacter() {
        if !passwordAttempt.isEmpty {
            // Delete last character of passwordAttempt
            passwordAttempt.removeLast()
            print("🗑️ Deleted 1 character, current passwordAttempt: '\(passwordAttempt)'")
        }
        
        if displayValue.count > 1 {
            // Delete last character of displayValue
            displayValue.removeLast()
        } else {
            // If only 1 character left, reset to "0"
            displayValue = "0"
            newNumber = true
        }
    }
    
    private func appendNumber(_ number: String) {
        // Always add to passwordAttempt for verification
        passwordAttempt += number
        
        // Display number on screen
        if newNumber {
            displayValue = number
            newNumber = false
        } else {
            if displayValue == "0" && number != "." {
                displayValue = number
            } else {
                displayValue += number
            }
        }
        
        // Check password every time a number is entered
        checkPassword()
        
        // Debug: print current passwordAttempt
        print("🔢 Current passwordAttempt: '\(passwordAttempt)'")
    }
    
    private func checkPassword() {
        print("🔐 Checking password: '\(passwordAttempt)'")
        print("🔐 Stored password: '\(userDefaultsManager.password)'")
        print("🔐 Password set: \(userDefaultsManager.hasSetPassword)")
        
        // Check if password has been set
        guard userDefaultsManager.hasSetPassword else {
            print("❌ Password not set!")
            return
        }
        
        if userDefaultsManager.verifyPassword(passwordAttempt) {
            print("✅ Password correct! Opening secret storage...")
            // Password correct - open secret storage
            passwordAttempt = ""
            displayValue = "0"
            newNumber = true
            NotificationCenter.default.post(name: .showSecretStorage, object: nil)
        } else {
            print("❌ Wrong password - keeping passwordAttempt to accumulate")
            // Wrong password - DON'T reset passwordAttempt, let it accumulate
            // passwordAttempt = "" // Remove this line
        }
    }
    
    private func clear() {
        displayValue = "0"
        currentOperation = nil
        previousValue = nil
        newNumber = true
        passwordAttempt = ""
    }
    
    private func toggleSign() {
        if let value = Double(displayValue) {
            displayValue = String(-value)
        }
    }
    
    private func percentage() {
        if let value = Double(displayValue) {
            displayValue = String(value / 100)
        }
    }
    
    private func decimal() {
        if !displayValue.contains(",") {
            displayValue += ","
            newNumber = false
        }
    }
    
    private func setOperation(_ operation: Operation) {
        if let value = Double(displayValue.replacingOccurrences(of: ",", with: ".")) {
            previousValue = value
            currentOperation = operation
            newNumber = true
        }
    }
    
    private func calculate() {
        guard let operation = currentOperation,
              let previous = previousValue,
              let current = Double(displayValue.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let result: Double
        
        switch operation {
        case .add:
            result = previous + current
        case .subtract:
            result = previous - current
        case .multiply:
            result = previous * current
        case .divide:
            if current == 0 {
                return // Không hiện thông báo lỗi
            }
            result = previous / current
        }
        
        displayValue = String(result).replacingOccurrences(of: ".", with: ",")
        currentOperation = nil
        previousValue = nil
        newNumber = true
    }
}

struct CalculatorButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    let size: CGFloat
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(color)
                .clipShape(Circle())
        }
    }
}

#Preview {
    CalculatorView()
}
