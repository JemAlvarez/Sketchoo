//

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
    @ObservedObject var vm: CanvasViewModel
    
    var twoPanGesture = UIPanGestureRecognizer()
    var twoTapGesture = UITapGestureRecognizer()
    var threeTapGesture = UITapGestureRecognizer()
    var fourTapGesture = UITapGestureRecognizer()
    var pinchGesture = UIPinchGestureRecognizer()
    var rotationGesture = UIRotationGestureRecognizer()
    
    func makeUIView(context: Context) -> PKCanvasView {
        twoPanGesture.addTarget(context.coordinator, action: #selector(Coordinator.panGestureSelector))
        twoTapGesture.addTarget(context.coordinator, action: #selector(Coordinator.twoTapSelector))
        threeTapGesture.addTarget(context.coordinator, action: #selector(Coordinator.threeTapSelector))
        fourTapGesture.addTarget(context.coordinator, action: #selector(Coordinator.fourTapSelector))
        pinchGesture.addTarget(context.coordinator, action: #selector(Coordinator.pinchGestureSelector))
        rotationGesture.addTarget(context.coordinator, action: #selector(Coordinator.rotationGestureSelector))
        
        twoTapGesture.numberOfTouchesRequired = 2
        threeTapGesture.numberOfTouchesRequired = 3
        fourTapGesture.numberOfTouchesRequired = 4
        twoPanGesture.minimumNumberOfTouches = 2
        
        twoPanGesture.delegate = context.coordinator
        pinchGesture.delegate = context.coordinator
        rotationGesture.delegate = context.coordinator
        
        vm.canvas.addGestureRecognizer(twoPanGesture)
        if UIDevice.current.userInterfaceIdiom != .phone {
            vm.canvas.addGestureRecognizer(twoTapGesture)
            vm.canvas.addGestureRecognizer(threeTapGesture)
            vm.canvas.addGestureRecognizer(fourTapGesture)
        }
        vm.canvas.addGestureRecognizer(pinchGesture)
        vm.canvas.addGestureRecognizer(rotationGesture)
        
        vm.canvas.delegate = context.coordinator
        
        vm.canvas.backgroundColor = .systemGray2
        
        showToolPicker()
        
        vm.canvas.isScrollEnabled = false
        vm.canvas.contentSize = CGSize(width: vm.frameWidth, height: vm.frameHeight)
        
        return vm.canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if !vm.toolPickerIsVisible {
            hideToolPicker()
        } else {
            showToolPicker()
        }
        
        switch vm.bgColor {
        case 0:
            vm.canvas.backgroundColor = .black
        case 2:
            vm.canvas.backgroundColor = .white
        default:
            vm.canvas.backgroundColor = .systemGray2
        }
    }
    
    func showToolPicker() {
        vm.toolPicker.setVisible(true, forFirstResponder: vm.canvas)
        vm.toolPicker.addObserver(vm.canvas)
        vm.canvas.becomeFirstResponder()
    }
    
    func hideToolPicker() {
        vm.toolPicker.setVisible(false, forFirstResponder: vm.canvas)
        vm.toolPicker.removeObserver(vm.canvas)
        vm.canvas.resignFirstResponder()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(canvasView: $vm.canvas, canvasDrawingDidChange: canvasDrawingDidChange, twoTap: vm.twoTap, threeTap: vm.threeTap, fourTap: vm.fourTap, panGesture: vm.panGesture, vm: vm, twoPanGesture: twoPanGesture, pinchGesture: pinchGesture, pinchGestureFunc: vm.pinchGesture, rotationGestureFunc: vm.rotationGesture, rotationGesture: rotationGesture, onSave: vm.onSave)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate, UIGestureRecognizerDelegate {
        var canvasView: Binding<PKCanvasView>
        var twoTap: (() -> Void)
        var threeTap: (() -> Void)
        var fourTap: (() -> Void)
        var canvasDrawingDidChange: () -> Void
        var panGesture: (() -> Void)
        var vm: CanvasViewModel
        var twoPanGesture: UIPanGestureRecognizer
        var pinchGesture: UIPinchGestureRecognizer
        var pinchGestureFunc: () -> Void
        var rotationGestureFunc: () -> Void
        var rotationGesture: UIRotationGestureRecognizer
        var onSave: () -> Void
        
        init(canvasView: Binding<PKCanvasView>, canvasDrawingDidChange: @escaping () -> Void, twoTap: @escaping (() -> Void), threeTap: @escaping (() -> Void), fourTap: @escaping (() -> Void), panGesture: @escaping () -> Void, vm: CanvasViewModel, twoPanGesture: UIPanGestureRecognizer, pinchGesture: UIPinchGestureRecognizer, pinchGestureFunc: @escaping () -> Void, rotationGestureFunc: @escaping () -> Void, rotationGesture: UIRotationGestureRecognizer, onSave: @escaping () -> Void) {
            self.canvasView = canvasView
            self.twoTap = twoTap
            self.threeTap = threeTap
            self.fourTap = fourTap
            self.canvasDrawingDidChange = canvasDrawingDidChange
            self.panGesture = panGesture
            self.vm = vm
            self.twoPanGesture = twoPanGesture
            self.pinchGesture = pinchGesture
            self.pinchGestureFunc = pinchGestureFunc
            self.rotationGesture = rotationGesture
            self.rotationGestureFunc = rotationGestureFunc
            self.onSave = onSave
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            self.canvasDrawingDidChange()
        }
        
        @objc func twoTapSelector(gesture:UITapGestureRecognizer) {
            self.twoTap()
        }
        
        @objc func threeTapSelector(gesture:UITapGestureRecognizer) {
            self.threeTap()
        }
        
        @objc func fourTapSelector(gesture:UITapGestureRecognizer) {
            self.fourTap()
        }
        
        @objc func panGestureSelector(gesture: UIPanGestureRecognizer) {
            vm.panGestureTranslation = twoPanGesture.translation(in: vm.gesturesView)
            
            if self.twoPanGesture.state == .ended {
                vm.panGestureEnded = true
            }
            
            self.panGesture()
        }
        
        @objc func pinchGestureSelector(gesture: UIPinchGestureRecognizer) {
            vm.pinchScale = pinchGesture.scale
            
            if self.pinchGesture.state == .ended {
                vm.pinchGestureEnded = true
            }
            
            self.pinchGestureFunc()
        }
        
        @objc func rotationGestureSelector(gesture: UIRotationGestureRecognizer) {
            vm.currentRotation = rotationGesture.rotation
            
            if self.rotationGesture.state == .ended {
                vm.rotationGestureEnded = true
            }
            
            vm.rotationGesture()
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
    
    func canvasDrawingDidChange() {
        vm.toolPickerIsVisible = true
        
        if !vm.canvas.drawing.bounds.isEmpty {
            vm.onSave()
        }
    }
}

extension PKCanvasView {
    open override var editingInteractionConfiguration: UIEditingInteractionConfiguration {
        return .none
    }
}
