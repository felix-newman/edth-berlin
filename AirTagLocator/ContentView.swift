import SwiftUI
import ARKit

struct ContentView: View {
    @StateObject private var nearbyInteractionManager = NearbyInteractionManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            ARViewContainer(nearbyInteractionManager: nearbyInteractionManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // Status display
                    HStack {
                        Circle()
                            .fill(nearbyInteractionManager.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        Text(nearbyInteractionManager.statusMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    
                    // Distance display
                    if let distance = nearbyInteractionManager.distance {
                        Text(String(format: "Distance: %.2f m", distance))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(20)
                    }
                    
                    // Start/Stop button
                    Button(action: {
                        if nearbyInteractionManager.isConnected {
                            nearbyInteractionManager.stopSession()
                        } else {
                            nearbyInteractionManager.startSession()
                        }
                    }) {
                        Text(nearbyInteractionManager.isConnected ? "Stop Tracking" : "Start Tracking")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(nearbyInteractionManager.isConnected ? Color.red : Color.green)
                            .cornerRadius(25)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onReceive(nearbyInteractionManager.$errorMessage) { error in
            if let error = error {
                alertMessage = error
                showingAlert = true
            }
        }
    }
}

struct ARViewContainer: UIViewControllerRepresentable {
    let nearbyInteractionManager: NearbyInteractionManager
    
    func makeUIViewController(context: Context) -> ARViewController {
        let controller = ARViewController()
        controller.nearbyInteractionManager = nearbyInteractionManager
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        // Update if needed
    }
}

#Preview {
    ContentView()
}

