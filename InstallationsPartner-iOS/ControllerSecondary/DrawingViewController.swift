import UIKit

protocol DrawingViewControllerDelegate {
    func updateSignature(_ image: UIImage)
}

class DrawingViewController: UIViewController {
    
    var delegate: DrawingViewControllerDelegate?

    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var canvas: CanvasView!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.delegate = self
        
        initDrawing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        initCanvas()
        initTitleLabel()
        initButtons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    //MARK: - Init
    func initDrawing() {
        let size = CGSize(width: canvas.frame.width, height: canvas.frame.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    }
    
    func initCanvas() {
        canvasView.applyShadowAndRadius()
        
    }
    
    func initTitleLabel() {
        
        let titleLabel = UILabel(frame: CGRect(x: view.frame.width/2 - 25, y: 80, width: view.frame.width, height: view.frame.height/2))
        titleLabel.transform = CGAffineTransform(rotationAngle: 3.14/2)
        titleLabel.text = "Signera med din underskrift här"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)

        view.addSubview(titleLabel)
    }
    
    func initButtons() {
        confirmButton.transform = CGAffineTransform(rotationAngle: 3.14/2)
        deleteButton.transform = CGAffineTransform(rotationAngle: 3.14/2)
        
        confirmButton.applyPanelButtonStyle()
        deleteButton.applyPanelButtonStyle()
        closeButton.applyPanelButtonStyle()
        
        confirmDisabled()
    }
    
//MARK: - Methods

    private func confirmEnabled() {
        confirmButton.backgroundColor = #colorLiteral(red: 0, green: 0.854619801, blue: 0.440415442, alpha: 1)
        confirmButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        confirmButton.isEnabled = true
        
        deleteButton.backgroundColor = #colorLiteral(red: 0.1095948145, green: 0.3001712561, blue: 0.6087573171, alpha: 1)
        deleteButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        deleteButton.isEnabled = true
    }
    private func confirmDisabled() {
        confirmButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        confirmButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        confirmButton.isEnabled = false
        
        deleteButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        deleteButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        deleteButton.isEnabled = false
    }

    
//MARK: - UI Actions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        canvas.clearCanvasView()
        confirmDisabled()
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        let signatureImage = canvas.convertDrawingToImage()
        self.delegate?.updateSignature(signatureImage)

        dismiss(animated: false, completion: nil)
    }
}

extension DrawingViewController: CanvasViewDelegate {
    func beganDrawing() {
        confirmEnabled()
    }
}
