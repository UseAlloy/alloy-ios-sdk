import UIKit

internal extension UIView{
    /// Mask a view by removing the visible area of `view`.
    func maskRemove(_ view: UIView) {
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addPath(UIBezierPath(roundedRect: view.frame, cornerRadius: view.layer.cornerRadius).cgPath)
        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        mask.path = path
        layer.mask = mask
    }
}
