import Foundation
import NearbyInteraction
import MultipeerConnectivity
import Combine

class NearbyInteractionManager: NSObject, ObservableObject {
    @Published var distance: Float?
    @Published var direction: simd_float3?
    @Published var isConnected = false
    @Published var statusMessage = "Not connected"
    @Published var errorMessage: String?
    
    private var niSession: NISession?
    private var peerDiscoveryToken: NIDiscoveryToken?
    private var mcSession: MCSession?
    private var mcAdvertiserAssistant: MCNearbyServiceAdvertiser?
    private var mcBrowser: MCNearbyServiceBrowser?
    
    private let serviceType = "airtag-locate"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    override init() {
        super.init()
        setupNearbyInteraction()
    }
    
    private func setupNearbyInteraction() {
        // Check if Nearby Interaction is supported
        guard NISession.isSupported else {
            statusMessage = "Nearby Interaction not supported"
            errorMessage = "This device does not support Nearby Interaction"
            return
        }
        
        niSession = NISession()
        niSession?.delegate = self
        
        // Get the discovery token
        peerDiscoveryToken = niSession?.discoveryToken
    }
    
    func startSession() {
        guard NISession.isSupported else {
            errorMessage = "Nearby Interaction is not supported on this device"
            return
        }
        
        statusMessage = "Searching for AirTags..."
        
        // Setup multipeer connectivity for demo purposes
        // Note: Real AirTag integration requires Apple's Find My network integration
        setupMultipeerConnectivity()
        
        // For demonstration, we'll simulate AirTag detection
        // In a real app, you would integrate with Apple's Find My network
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.simulateAirTagConnection()
        }
    }
    
    func stopSession() {
        niSession?.invalidate()
        mcSession?.disconnect()
        mcAdvertiserAssistant?.stopAdvertisingPeer()
        mcBrowser?.stopBrowsingForPeers()
        
        isConnected = false
        distance = nil
        direction = nil
        statusMessage = "Not connected"
    }
    
    private func setupMultipeerConnectivity() {
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
        
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        mcAdvertiserAssistant?.delegate = self
        mcAdvertiserAssistant?.startAdvertisingPeer()
        
        mcBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        mcBrowser?.delegate = self
        mcBrowser?.startBrowsingForPeers()
    }
    
    private func simulateAirTagConnection() {
        // This simulates finding an AirTag
        // In production, you'd use real NISession with actual AirTag tokens
        isConnected = true
        statusMessage = "AirTag detected"
        
        // Simulate distance updates
        startSimulatingDistance()
    }
    
    private func startSimulatingDistance() {
        // Simulate varying distance for demonstration
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, self.isConnected else {
                timer.invalidate()
                return
            }
            
            // Simulate distance between 0.5 and 5 meters
            let baseDistance: Float = 2.0
            let variation = Float.random(in: -0.5...0.5)
            self.distance = baseDistance + variation
            
            // Simulate direction (in front of user)
            let angle = Float.random(in: -0.2...0.2)
            self.direction = simd_float3(sin(angle), 0, -cos(angle))
        }
    }
}

// MARK: - NISessionDelegate
extension NearbyInteractionManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let object = nearbyObjects.first else { return }
        
        if let distance = object.distance {
            self.distance = distance
        }
        
        if let direction = object.direction {
            self.direction = direction
        }
        
        isConnected = true
        statusMessage = "Tracking AirTag"
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        distance = nil
        direction = nil
        
        switch reason {
        case .timeout:
            statusMessage = "Lost connection (timeout)"
        case .peerEnded:
            statusMessage = "Peer ended session"
        @unknown default:
            statusMessage = "Lost connection"
        }
    }
    
    func sessionWasSuspended(_ session: NISession) {
        statusMessage = "Session suspended"
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        statusMessage = "Session resumed"
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        statusMessage = "Session error"
        errorMessage = error.localizedDescription
        isConnected = false
    }
}

// MARK: - MCSessionDelegate
extension NearbyInteractionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected to peer: \(peerID.displayName)")
            if let token = peerDiscoveryToken,
               let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) {
                try? session.send(data, toPeers: [peerID], with: .reliable)
            }
        case .connecting:
            print("Connecting to peer: \(peerID.displayName)")
        case .notConnected:
            print("Not connected to peer: \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            let config = NINearbyPeerConfiguration(peerToken: token)
            niSession?.run(config)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NearbyInteractionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mcSession)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NearbyInteractionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: mcSession!, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
}

