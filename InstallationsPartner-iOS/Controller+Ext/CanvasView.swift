import UIKit

struct TouchPointAndColor {
    var color: UIColor?
    var width: CGFloat?
    var opcacity: CGFloat?
    var points: [CGPoint]?
    
    init(color: UIColor, points: [CGPoint]) {
        self.color = color
        self.points = points
    }
}

protocol CanvasViewDelegate {
    func beganDrawing()
}

class CanvasView: UIView {
    
    var delegate: CanvasViewDelegate?

    var lines = [TouchPointAndColor]()
    var strokeWidth: CGFloat = 5.0
    var strokeColor: UIColor = .black
    var strokeOpacity: CGFloat = 1.0
    var isBegan: Bool = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        lines.forEach { (line) in
            for (i,p) in (line.points?.enumerated())! {
                let newP = CGPoint(x: p.x - 20, y: p.y - 50)
                if i == 0 {
                    context.move(to: newP)
                } else {
                    context.addLine(to: newP)
                }
            }
            context.setStrokeColor(line.color?.withAlphaComponent(line.opcacity ?? 1.0).cgColor ?? UIColor.black.cgColor)
            context.setLineWidth(line.width ?? 1.0)
        }
        context.setLineCap(.round)
        context.strokePath()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(!isBegan) {
            isBegan = true
            self.delegate?.beganDrawing()
        }
        lines.append(TouchPointAndColor(color: UIColor(), points: [CGPoint]()))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: nil) else { return }
        
        guard var lastPoint = lines.popLast() else {return}
        lastPoint.points?.append(touch)
        lastPoint.color = strokeColor
        lastPoint.width = strokeWidth
        lastPoint.opcacity = strokeOpacity
        lines.append(lastPoint)
        setNeedsDisplay()
    }
    
    func clearCanvasView() {
        isBegan = false
        lines.removeAll()
        setNeedsDisplay()
    }

    func convertDrawingToImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {return UIImage()}
        UIGraphicsEndImageContext()
                
        return image
    }
    
}
