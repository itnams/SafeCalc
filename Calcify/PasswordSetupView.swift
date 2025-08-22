import SwiftUI

struct PasswordSetupView: View {
    @ObservedObject var userDefaultsManager = UserDefaultsManager.shared
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Thiết lập mật khẩu")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Nhập mật khẩu tối thiểu 4 ký tự số để bảo vệ dữ liệu của bạn")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 20) {
                    SecureField("Nhập mật khẩu", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: password) { newValue in
                            // Chỉ cho phép nhập số
                            password = newValue.filter { $0.isNumber }
                        }
                    
                    SecureField("Xác nhận mật khẩu", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: confirmPassword) { newValue in
                            // Chỉ cho phép nhập số
                            confirmPassword = newValue.filter { $0.isNumber }
                        }
                }
                .padding(.horizontal)
                
                Button(action: setupPassword) {
                    Text("Thiết lập mật khẩu")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidInput ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isValidInput)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .alert("Lỗi", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isValidInput: Bool {
        return password.count >= 4 && password == confirmPassword && !password.isEmpty
    }
    
    private func setupPassword() {
        guard password.count >= 4 else {
            alertMessage = "Mật khẩu phải có ít nhất 4 ký tự"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Mật khẩu xác nhận không khớp"
            showAlert = true
            return
        }
        
        userDefaultsManager.setPassword(password)
    }
}

#Preview {
    PasswordSetupView()
}
