// fixed canvas size

import SwiftUI
import PencilKit

struct ContentView: View {
    @Environment(\.undoManager) var undoManager
    @ObservedObject var vm = CanvasViewModel(undo: {}, redo: {})
    @State var showingSheet = false
    
    var body: some View {
        ZStack {
            bgView()
            
            GesturesView(vm: vm)
                .rotationEffect(Angle(radians: vm.rotation))
            
            VStack {
                HStack {
                    Button(action: {
                        vm.clear()
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        undoManager?.undo()
                    }) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .foregroundColor(.primary)
                    }

                    Button(action: {
                        undoManager?.redo()
                    }) {
                        Image(systemName: "arrow.uturn.forward.circle.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        vm.restore()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.primary)
                    }
                    
                    Spacer() // divider
                    
                    Menu("\(Image(systemName: "paintpalette.fill"))") {
                        Picker("", selection: $vm.bgColor.animation()) {
                            Text("Black").tag(0)
                            Text("Gray").tag(1)
                            Text("White").tag(2)
                        }
                    }.foregroundColor(.primary)
                    
                    if UIDevice.current.userInterfaceIdiom != .phone {
                        Menu("\(Image(systemName: "hand.tap.fill"))") {
                            Label("Two Finger Tap: Undo", systemImage: "arrow.uturn.backward.circle.fill")
                            Label("Three Finger Tap: Redo", systemImage: "arrow.uturn.forward.circle.fill")
                            Label("Four Finger Tap: Clear", systemImage: "trash.circle.fill")
                        }.foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        vm.toolPickerIsVisible.toggle()
                    }) {
                        Image(systemName: "eye.slash")
                            .foregroundColor(.primary)
                    }

                    Button(action: {
                        vm.saveCurrent()
                    }) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                .font(.title2)
                
                Spacer()
            }
            
            DrawingView(vm: vm)
                .frame(width: vm.frameWidth, height: vm.frameHeight)
                .cornerRadius(10)
                .scaleEffect(vm.scale)
                .offset(x: vm.xOffset, y: vm.yOffset)
                .rotationEffect(Angle(radians: vm.rotation))
        }
        .onAppear {
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                vm.frameWidth = UIScreen.main.bounds.height * 0.9
                vm.frameHeight = UIScreen.main.bounds.height * 0.9
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            vm.undo = {undoManager?.undo()}
            vm.redo = {undoManager?.redo()}
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    func bgView() -> some View {
        return (
            ZStack {
                Color(UIColor.systemGray5)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(0..<150) { _ in
                            Divider()
                        }
                    }
                }
                .ignoresSafeArea()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<150) { _ in
                            Divider()
                        }
                    }
                }
                .ignoresSafeArea()
            }
        )
    }
}
