import Foundation
import UIKit

//MARK: - Button Style
extension UIButton {
    func applyPanelButtonStyle() {

        self.layer.cornerRadius = self.frame.height / 2
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width:0, height:0)
    }
    
    func applyCircleStyle() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width:0, height:0)
    }

    func setChecked() {
        let mediumConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium)
        let mediumCheck = UIImage(systemName: "checkmark.square", withConfiguration: mediumConfig)
        self.setImage(mediumCheck, for: .normal)
        self.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
    
    func setUnchecked() {
        let mediumConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium)
        let mediumCheck = UIImage(systemName: "square", withConfiguration: mediumConfig)
        self.setImage(mediumCheck, for: .normal)
        self.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        self.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
    }
}


//MARK: - Button Badge
/* Usage
    @IBOutlet weak var button: UIButtonBadge!
    button.showBadge(blink: false, text: "swift")
    button.badgeView?.backgroundColor = .blue
    button.badgeLabel?.textColor = .orange
*/
//protocol
protocol BadgeContainer: class {
    var badgeView: UIView? { get set }
    var badgeLabel: UILabel? { get set }
    func showBadge(blink: Bool, text: String?, withSize: CGFloat)
    func hideBadge()
}

//default protocol implementation
extension BadgeContainer where Self: UIView {
    func showBadge(blink: Bool, text: String?, withSize: CGFloat = 8) {
        if badgeView != nil {
            if badgeView?.isHidden == false {
                return
            }
        } else {
            badgeView = UIView()
        }

        badgeView?.backgroundColor = .red
        guard let badgeViewUnwrapped = badgeView else {
            return
        }
        //adds the badge at the top
        addSubview(badgeViewUnwrapped)
        badgeViewUnwrapped.translatesAutoresizingMaskIntoConstraints = false

        var size = withSize
        if let textUnwrapped = text {
            if badgeLabel == nil {
                badgeLabel = UILabel()
            }
            
            guard let labelUnwrapped = badgeLabel else {
                return
            }
            
            labelUnwrapped.text = textUnwrapped
            labelUnwrapped.textColor = .white
            labelUnwrapped.font = .systemFont(ofSize: 14)
            labelUnwrapped.translatesAutoresizingMaskIntoConstraints = false

            badgeViewUnwrapped.addSubview(labelUnwrapped)
            let labelConstrainst = [labelUnwrapped.centerXAnchor.constraint(equalTo: badgeViewUnwrapped.centerXAnchor),                                    labelUnwrapped.centerYAnchor.constraint(equalTo: badgeViewUnwrapped.centerYAnchor)]
            NSLayoutConstraint.activate(labelConstrainst)
            
            size = CGFloat(2 * Int(size) + 2 * textUnwrapped.count)
        }
        
        let sizeConstraints = [badgeViewUnwrapped.widthAnchor.constraint(equalToConstant: size), badgeViewUnwrapped.heightAnchor.constraint(equalToConstant: size)]
        NSLayoutConstraint.activate(sizeConstraints)
        
        badgeViewUnwrapped.cornerRadius = size / 2
        
        let position = [badgeViewUnwrapped.topAnchor.constraint(equalTo: self.topAnchor, constant: -size / 4),
        badgeViewUnwrapped.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: size/4)]
        NSLayoutConstraint.activate(position)
        
        if blink {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 1.2
            animation.repeatCount = .infinity
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = .init(name: .easeOut)
            badgeViewUnwrapped.layer.add(animation, forKey: "badgeBlinkAnimation")
        }
    }
    
    func hideBadge() {
        badgeView?.layer.removeAnimation(forKey: "badgeBlinkAnimation")
        badgeView?.removeFromSuperview()
        badgeView = nil
        badgeLabel = nil
    }
}

//custom class
class UIButtonBadge: UIButton, BadgeContainer {
    var badgeTimer: Timer?
    var badgeView: UIView?
    var badgeLabel: UILabel?
}
//extension of UIView for proper positioning of visual children
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
