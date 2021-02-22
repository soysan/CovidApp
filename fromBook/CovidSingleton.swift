import Foundation

class CovidSingleton {
    
    private init() {}
    static let shared = CovidSingleton()
    var prefecture:[CovidInfo.Prefecture] = []
    
}
