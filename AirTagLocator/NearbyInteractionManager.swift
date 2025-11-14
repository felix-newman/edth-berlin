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
        
        statusMessage = "Searching for nearby devices..."
        
        // Setup multipeer connectivity to discover other iPhones
        setupMultipeerConnectivity()
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
}

// MARK: - NISessionDelegate
extension NearbyInteractionManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let object = nearbyObjects.first else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let distance = object.distance {
                self.distance = distance
            }
            
            if let direction = object.direction {
                self.direction = direction
            }
            
            self.isConnected = true
            self.statusMessage = "Tracking device"
        }
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.distance = nil
            self.direction = nil
            
            switch reason {
            case .timeout:
                self.statusMessage = "Lost connection (timeout)"
            case .peerEnded:
                self.statusMessage = "Peer ended session"
            @unknown default:
                self.statusMessage = "Lost connection"
            }
        }
    }
    
    func sessionWasSuspended(_ session: NISession) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = "Session suspended"
        }
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = "Session resumed"
        }
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.statusMessage = "Session error"
            self.errorMessage = error.localizedDescription
            self.isConnected = false
        }
    }
}

// MARK: - MCSessionDelegate
extension NearbyInteractionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("✅ Connected to peer: \(peerID.displayName)")
            DispatchQueue.main.async { [weak self] in
                self?.statusMessage = "Connected to \(peerID.displayName)"
            }
            
            // Send our discovery token to the peer
            if let token = peerDiscoveryToken,
               let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) {
                try? session.send(data, toPeers: [peerID], with: .reliable)
            }
            
        case .connecting:
            print("🔄 Connecting to peer: \(peerID.displayName)")
            DispatchQueue.main.async { [weak self] in
                self?.statusMessage = "Connecting to \(peerID.displayName)..."
            }
            
        case .notConnected:
            print("❌ Not connected to peer: \(peerID.displayName)")
            DispatchQueue.main.async { [weak self] in
                self?.statusMessage = "Disconnected from \(peerID.displayName)"
                self?.isConnected = false
            }
            
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Received discovery token from peer - start NISession
        if let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            print("📡 Received discovery token from \(peerID.displayName), starting NISession")
            
            let config = NINearbyPeerConfiguration(peerToken: token)
            niSession?.run(config)
            
            DispatchQueue.main.async { [weak self] in
                self?.statusMessage = "Starting distance tracking..."
            }
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

