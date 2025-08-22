import Foundation

class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    
    private let hasSetPasswordKey = "hasSetPassword"
    private let passwordKey = "userPassword"
    
    @Published var hasSetPassword: Bool {
        didSet {
            UserDefaults.standard.set(hasSetPassword, forKey: hasSetPasswordKey)
        }
    }
    
    @Published var password: String {
        didSet {
            UserDefaults.standard.set(password, forKey: passwordKey)
        }
    }
    
    private init() {
        self.hasSetPassword = UserDefaults.standard.bool(forKey: hasSetPasswordKey)
        self.password = UserDefaults.standard.string(forKey: passwordKey) ?? ""
    }
    
    func setPassword(_ newPassword: String) {
        password = newPassword
        hasSetPassword = true
    }
    
    func verifyPassword(_ inputPassword: String) -> Bool {
        return inputPassword == password
    }
    
    func clearPassword() {
        password = ""
        hasSetPassword = false
    }
}
