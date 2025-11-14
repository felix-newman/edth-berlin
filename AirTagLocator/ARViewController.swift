import UIKit
import ARKit
import RealityKit

class ARViewController: UIViewController {
    var arView: ARView!
    var nearbyInteractionManager: NearbyInteractionManager?
    var airTagVisualizer: AirTagVisualizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARView()
        setupVisualizer()
    }
    
    private func setupARView() {
        arView = ARView(frame: view.bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(arView)
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        arView.session.run(configuration)
    }
    
    private func setupVisualizer() {
        airTagVisualizer = AirTagVisualizer(arView: arView)
        
        // Start update loop
        startVisualizationUpdates()
    }
    
    private func startVisualizationUpdates() {
        Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  let distance = self.nearbyInteractionManager?.distance,
                  let direction = self.nearbyInteractionManager?.direction else {
                return
            }
            
            // Update visualization based on AirTag position
            self.airTagVisualizer?.updateAirTagPosition(distance: distance, direction: direction)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
}

