//

import SwiftUI
import PencilKit

class CanvasViewModel: ObservableObject {
    @Published var bgColor = 1
    @Published var frameWidth = UIScreen.main.bounds.width * 0.9
    @Published var frameHeight = UIScreen.main.bounds.width * 0.9
    
    @Published var savedDrawing = PKDrawing()
    @Published var savedImage = UIImage()
    
    @Published var canvas = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    @Published var toolPickerIsVisible = true
    @Published var gesturesView = UIView()
    
    @Published var yOffset: CGFloat = 0
    @Published var xOffset: CGFloat = 0
    
    @Published var panGestureTranslation: CGPoint = .zero
    @Published var panGestureEnded = false
    
    @Published var pinchScale: CGFloat = 1
    @Published var pinchGestureEnded = false
    @Published var scale: CGFloat = 1
    
    @Published var rotation: CGFloat = 0
    @Published var currentRotation: CGFloat = 0
    @Published var rotationGestureEnded = false
    
    var newPosition: CGPoint = .zero
    var newScale: CGFloat = 1
    var newRotation: CGFloat = 0
    
    var undo: () -> Void
    var redo: () -> Void
    
    init(undo: @escaping () -> Void, redo: @escaping () -> Void) {
        self.undo = undo
        self.redo = redo
    }
    
    func twoTap() {
        undo()
    }
    
    func threeTap() {
        redo()
    }
    
    func fourTap() {
        clear()
    }
    
    func clear() {
        canvas.drawing = PKDrawing()
    }
    
    func panGesture() {
        xOffset = newPosition.x + panGestureTranslation.x
        yOffset = newPosition.y + panGestureTranslation.y
        
        if panGestureEnded {
            if yOffset > -10 && yOffset < 10 && xOffset > -10 && xOffset < 10 {
                yOffset = 0
                xOffset = 0
            }
            
            newPosition.x = xOffset
            newPosition.y = yOffset
            
            panGestureEnded = false
        }
    }
    
    func pinchGesture() {
        scale = newScale * pinchScale
        
        if pinchGestureEnded {
            if scale > 0.85 && scale < 0.95 {
                scale = 1
            }
                
            newScale = scale
            
            pinchGestureEnded = false
        }
    }
    
    func rotationGesture() {
        rotation = newRotation + currentRotation
        
        if rotationGestureEnded {
            if rotation > -0.05 && rotation < 0.05 {
                rotation = 0
            }
            
            newRotation = rotation
            
            rotationGestureEnded = false
        }
    }
    
    func onSave() {
        savedImage = canvas.drawing.image(from: canvas.bounds, scale: UIScreen.main.scale)
        savedDrawing = canvas.drawing
    }
    
    func saveCurrent() {
        if !canvas.drawing.bounds.isEmpty {
            let img = canvas.asImage()
            
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        }
    }
    
    func restore() {
        if !savedDrawing.bounds.isEmpty {
            canvas.drawing = savedDrawing
        }
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
