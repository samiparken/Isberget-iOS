import Foundation
import UIKit

class CustomerAnswerCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerImageView: UIImageView!

    //data
    var answerSet = [String:Any]()

//MARK: - Init
    func initCell() {
        setQuestion()
        
        let isHeader = (answerSet["isHeader"] as? Bool) ?? false
        if (isHeader) {
            setTitle()
            answerLabel.isHidden = true
            imageView?.isHidden = true
            return
        }
            
        let isImage = (answerSet["IsImage"] as? Bool) ?? false
        if isImage {
            setImage()
            answerLabel.isHidden = true
            answerImageView.isHidden = false
        } else {
            setLabel()
            answerLabel.isHidden = false
            answerImageView.isHidden = true            
        }
    }
    
    
    //for Dynamic Image Ratio
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                answerImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                answerImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    
//MARK: - Methods
    func setTitle() {
        let headerText = (answerSet["headerText"] as? String) ?? ""
        questionLabel.text = headerText
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        answerLabel.text = nil
        answerImageView.image = nil
    }
    
    func setQuestion() {
        guard let question = (answerSet["Question"] as? String) else { return }
        questionLabel.text = question
        questionLabel.textAlignment = .left
        questionLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    func setLabel() {
        let answer = (answerSet["Answer"] as? String) ?? ""
        answerLabel.text = answer
        answerImageView.image = nil
    }

    func setImage() {
        let answer = (answerSet["Answer"] as? String) ?? ""
        
        let splits = answer.split(separator: ",")

        if (splits.count > 1) {
            let answerImage = convertBase64StringToImage(imageBase64String: String(splits[1]))
            setImageWithDynamicRatio(answerImage)
        }
    }
    
    func setImageWithDynamicRatio(_ image : UIImage) {
        let aspect = image.size.width / image.size.height

        let constraint = NSLayoutConstraint(item: answerImageView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: answerImageView, attribute: NSLayoutConstraint.Attribute.height, multiplier: aspect, constant: 0.0)
        constraint.priority = UILayoutPriority(rawValue: 999)

        aspectConstraint = constraint
        answerImageView.image = image
    }
}
