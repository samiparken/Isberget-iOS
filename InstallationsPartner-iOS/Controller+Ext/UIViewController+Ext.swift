import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, defaultButtonText: String = "OK", actions: [UIAlertAction] = []) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: defaultButtonText, style: .default))
        
        for action in actions {
            alert.addAction(action)
        }
        
        if #available(iOS 13.0, *) {
            if var topController = UIApplication.shared.keyWindow?.rootViewController  {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                DispatchQueue.main.async {
                    topController.present(alert, animated: true, completion: nil)
                }                
            }
        }
    }
}
