import UIKit

internal extension UIImage {
    convenience init?(fallbackSystemImage name: String) {
        if #available(iOS 13.0, *) {
            self.init(systemName: name)
        } else {
            self.init(named: name)
        }
    }

    // Taken from: https://stackoverflow.com/a/47402811
    func rotate(radians: CGFloat, flip: Bool) -> UIImage? {
        var newSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians)).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = newSize.width.rounded(.down)
        newSize.height = newSize.height.rounded(.down)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        let context = UIGraphicsGetCurrentContext()

        // Move origin to middle
        context?.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context?.rotate(by: radians)
        // Conditionally flip the context
        if flip {
            context?.scaleBy(x: -1.0, y: 1.0)
        }

        // Draw the image at its center
        self.draw(in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
