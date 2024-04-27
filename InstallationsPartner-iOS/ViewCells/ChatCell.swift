import Foundation
import UIKit

class ChatCell: UITableViewCell {
            
    @IBOutlet weak var dateHeaderLabel: UILabel!
    
    @IBOutlet weak var outMessagePadding: UIView!
    @IBOutlet weak var inMessagePadding: UIView!
    
    @IBOutlet weak var bubbleMessageView: UIView!
    @IBOutlet weak var bubbleMessageLabel: UILabel!

    @IBOutlet weak var bubbleImageView: UIView!
    @IBOutlet weak var bubbleImage: UIImageView!
        
    @IBOutlet weak var timestampLabel: UILabel!        
    
    //data
    var message = [String:Any]()
    var isDateHeader: Bool = false
    var isTimestamp: Bool = false
    var isCustomer: Bool = false
    var isImage: Bool = false
    var base64Image: String = ""
    var text: String = ""
    var timestamp: Date = Date()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //for Dynamic Image Ratio
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                bubbleImage.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                bubbleImage.addConstraint(aspectConstraint!)
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
//MARK: - Init
    func initCell() {
        fetchData()

        initDateHeader()
        initTimestamp()
        initLayout()
        initContent()
    }
        
    func fetchData() {
        isCustomer = (message[K.Chat.Message.isCustomer] as? Bool) ?? false
        base64Image = (message[K.Chat.Message.image] as? String) ?? ""
        isImage = base64Image != "" ? true : false
        text = (message[K.Chat.Message.text] as? String) ?? ""
                        
        let timestampString = (message[K.Chat.Message.timestamp] as? String) ?? ""
        timestamp = stringToDate(with: timestampString)
    }
    
    func initDateHeader() {
        if isDateHeader {
            dateHeaderLabel.isHidden = false
            dateHeaderLabel.text = dateToString_ymd(with: timestamp)
        } else {
            dateHeaderLabel.isHidden = true
        }
    }
    
    func initTimestamp() {
        
        if isTimestamp {
            timestampLabel.isHidden = false
            let timestampString = dateToString_hm(with: timestamp)
            timestampLabel.text = "  " + timestampString + "  "
        } else {
            timestampLabel.isHidden = true
        }
    }
    
    func initContent() {
        
        bubbleImage.image = UIImage()
        bubbleMessageLabel.text = ""
        
        if isImage { setImage() }
        else { setText() }
    }
    
    func initLayout() {
        
        if isCustomer {
            inMessagePadding.isHidden = false
            outMessagePadding.isHidden = true
            timestampLabel.textAlignment = .left
        } else {
            inMessagePadding.isHidden = true
            outMessagePadding.isHidden = false
            timestampLabel.textAlignment = .right
        }
                
        if isImage {
            bubbleImageView.cornerRadius = 10
            bubbleImageView.backgroundColor = isCustomer ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : #colorLiteral(red: 0.2506503761, green: 0.5161324143, blue: 0.8887386918, alpha: 1)
        } else {
            bubbleMessageView.cornerRadius = 10
            bubbleMessageView.backgroundColor = isCustomer ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : #colorLiteral(red: 0.08282978225, green: 0.5163705549, blue: 0.8878770471, alpha: 1)
            bubbleMessageLabel.textColor = isCustomer ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }

    }

//MARK: - Methods
    
    func showText() {
        bubbleMessageView.isHidden = false
        bubbleImageView.isHidden = true
    }
    
    func showImage() {
        bubbleMessageView.isHidden = true
        bubbleImageView.isHidden = false
    }
    
    func setText() {
        showText()
        bubbleMessageLabel.text = self.text
    }
    
    func setImage() {
        showImage()
        
        let splits = self.base64Image.split(separator: ",")
        if (splits.count > 1) {
            let image = convertBase64StringToImage(imageBase64String: String(splits[1]))
            setImageWithDynamicRatio(image)
        }
    }
        
    func setImageWithDynamicRatio(_ image : UIImage) {
        let aspect = image.size.width / image.size.height

        let constraint = NSLayoutConstraint(item: bubbleImage!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bubbleImage, attribute: NSLayoutConstraint.Attribute.height, multiplier: aspect, constant: 0.0)
        constraint.priority = UILayoutPriority(rawValue: 999)

        aspectConstraint = constraint
        bubbleImage.image = image
    }
}
