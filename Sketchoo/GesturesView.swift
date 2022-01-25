//

import SwiftUI
import PencilKit

struct GesturesView: UIViewRepresentable {
    @ObservedObject var vm: CanvasViewModel
    
    var twoPanGesture = UIPanGestureRecognizer()
    var twoTapGesture = UITapGestureRecognizer()
    var threeTapGesture = UITapGestureRecognizer()
    var fourTapGesture = UITapGestureRecognizer()
    var pinchGesture = UIPinchGestureRecognizer()
    var rotationGesture = UIRotationGestureRecognizer()
    
    func makeUIView(context: Context) -> UIView {
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
        
        vm.gesturesView.addGestureRecognizer(twoPanGesture)
        if UIDevice.current.userInterfaceIdiom != .phone {
            vm.gesturesView.addGestureRecognizer(twoTapGesture)
            vm.gesturesView.addGestureRecognizer(threeTapGesture)
            vm.gesturesView.addGestureRecognizer(fourTapGesture)
        }
        vm.gesturesView.addGestureRecognizer(pinchGesture)
        vm.gesturesView.addGestureRecognizer(rotationGesture)
        
        return vm.gesturesView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(twoTap: vm.twoTap, threeTap: vm.threeTap, fourTap: vm.fourTap, panGesture: vm.panGesture, vm: vm, twoPanGesture: twoPanGesture, pinchGesture: pinchGesture, pinchGestureFunc: vm.pinchGesture, rotationGestureFunc: vm.rotationGesture, rotationGesture: rotationGesture)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var twoTap: (() -> Void)
        var threeTap: (() -> Void)
        var fourTap: (() -> Void)
        var panGesture: (() -> Void)
        var vm: CanvasViewModel
        var twoPanGesture: UIPanGestureRecognizer
        var pinchGesture: UIPinchGestureRecognizer
        var pinchGestureFunc: () -> Void
        var rotationGestureFunc: () -> Void
        var rotationGesture: UIRotationGestureRecognizer
        
        init(twoTap: @escaping (() -> Void), threeTap: @escaping (() -> Void), fourTap: @escaping (() -> Void), panGesture: @escaping () -> Void, vm: CanvasViewModel, twoPanGesture: UIPanGestureRecognizer, pinchGesture: UIPinchGestureRecognizer, pinchGestureFunc: @escaping () -> Void, rotationGestureFunc: @escaping () -> Void, rotationGesture: UIRotationGestureRecognizer) {
            self.twoTap = twoTap
            self.threeTap = threeTap
            self.fourTap = fourTap
            self.panGesture = panGesture
            self.vm = vm
            self.twoPanGesture = twoPanGesture
            self.pinchGesture = pinchGesture
            self.pinchGestureFunc = pinchGestureFunc
            self.rotationGesture = rotationGesture
            self.rotationGestureFunc = rotationGestureFunc
        }
        
        @objc func panGestureSelector(gesture: UIPanGestureRecognizer) {
            vm.panGestureTranslation = twoPanGesture.translation(in: vm.gesturesView)
            
            if self.twoPanGesture.state == .ended {
                vm.panGestureEnded = true
            }
            
            self.panGesture()
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
}
