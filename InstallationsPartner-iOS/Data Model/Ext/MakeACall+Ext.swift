
import Foundation
import UIKit

func makeACall(with number: String) {
    guard let url = URL(string: "tel://\(number.onlyDigits())"),
          UIApplication.shared.canOpenURL(url) else { return }
    if #available(iOS 10, *) {
        UIApplication.shared.open(url)
    } else {
        UIApplication.shared.openURL(url)
    }
}

extension String {
    // MARK: Get remove all characters exept numbers
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
}
