# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        AirTagLocator                         │
│                         iOS App                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┴─────────────────────┐
        │                                           │
        ▼                                           ▼
┌──────────────┐                           ┌──────────────┐
│ ContentView  │                           │ ARViewController│
│  (SwiftUI)   │◄──────────────────────────│   (UIKit)    │
└──────────────┘                           └──────────────┘
        │                                           │
        │                                           │
        ▼                                           ▼
┌──────────────────────┐                  ┌──────────────────┐
│ NearbyInteraction    │                  │ AirTagVisualizer │
│     Manager          │                  │                  │
│                      │                  │  - Bounding Box  │
│  - NISession         │                  │  - Image Overlay │
│  - Distance/Direction│                  │  - 3D Rendering  │
└──────────────────────┘                  └──────────────────┘
        │                                           │
        │                                           │
        ▼                                           ▼
┌──────────────────────┐                  ┌──────────────────┐
│ Apple Frameworks     │                  │   RealityKit     │
│                      │                  │                  │
│  - NearbyInteraction │                  │  - ModelEntity   │
│  - MultipeerConnectivity                │  - AnchorEntity  │
│  - U1 Chip           │                  │  - Materials     │
└──────────────────────┘                  └──────────────────┘
```

## Component Details

### 1. ContentView (UI Layer)
**Purpose**: Main user interface  
**Technology**: SwiftUI  
**Responsibilities**:
- Display connection status
- Show distance to AirTag
- Start/Stop tracking controls
- Error alerts

**Key Features**:
- Reactive UI with `@StateObject`
- Real-time distance updates
- Status indicator (green/red)

---

### 2. ARViewController (AR Layer)
**Purpose**: Manages AR session and camera  
**Technology**: ARKit + UIKit  
**Responsibilities**:
- Initialize ARKit session
- Configure world tracking
- Coordinate between NI and visualization
- Handle AR lifecycle

**Configuration**:
```swift
- World tracking
- Plane detection (horizontal + vertical)
- Environment texturing
- Person segmentation (if available)
```

---

### 3. NearbyInteractionManager (Localization Layer)
**Purpose**: Detect and track AirTags  
**Technology**: Nearby Interaction + MultipeerConnectivity  
**Responsibilities**:
- Manage NISession
- Discover nearby devices
- Exchange discovery tokens
- Publish distance and direction

**Published Properties**:
- `distance: Float?` - Distance in meters
- `direction: simd_float3?` - 3D direction vector
- `isConnected: Bool` - Connection status
- `statusMessage: String` - User-facing status

**Flow**:
```
1. Create NISession
2. Get discovery token
3. Setup MultipeerConnectivity
4. Exchange tokens with peers
5. Start NISession with peer token
6. Receive distance/direction updates
7. Publish to subscribers
```

---

### 4. AirTagVisualizer (Rendering Layer)
**Purpose**: Render 3D AR content  
**Technology**: RealityKit  
**Responsibilities**:
- Create bounding box geometry
- Generate image overlay
- Update positions in 3D space
- Handle camera-facing orientation

**Components**:

#### Bounding Box
- **Size**: 10cm cube (configurable)
- **Material**: Cyan unlit material
- **Wireframe**: 12 cylinder edges
- **Edge thickness**: 3mm

#### Image Overlay
- **Size**: 8cm plane
- **Content**: Location pin icon
- **Position**: 15cm above bounding box
- **Behavior**: Always faces camera

**Update Loop**: 30 FPS
```swift
Timer(1/30 seconds) {
    1. Get distance from NearbyInteractionManager
    2. Get direction from NearbyInteractionManager
    3. Calculate 3D position
    4. Update bounding box position
    5. Update image position (with offset)
    6. Rotate image to face camera
}
```

---

## Data Flow

### Initialization
```
App Launch
    ↓
AirTagLocatorApp
    ↓
ContentView created
    ↓
NearbyInteractionManager initialized
    ↓
ARViewController created
    ↓
AirTagVisualizer initialized
```

### Tracking Flow
```
User taps "Start Tracking"
    ↓
NearbyInteractionManager.startSession()
    ↓
Setup MultipeerConnectivity
    ↓
Discover peers
    ↓
Exchange NIDiscoveryTokens
    ↓
NISession.run(config)
    ↓
NISessionDelegate receives updates
    ↓
Publish distance & direction
    ↓
ARViewController receives updates
    ↓
AirTagVisualizer.updatePosition()
    ↓
RealityKit renders frame
    ↓
User sees AR visualization
```

### Update Cycle
```
NISession Update (varies, ~10Hz)
    ↓
NearbyInteractionManager publishes
    ↓
ContentView updates UI (distance text)
    ↓
ARViewController timer (30Hz)
    ↓
AirTagVisualizer calculates position
    ↓
RealityKit updates scene
    ↓
ARKit renders frame (60Hz)
```

---

## Key Technologies

### ARKit
- **World Tracking**: 6DOF camera tracking
- **Plane Detection**: Surface understanding
- **Environment Texturing**: Realistic lighting
- **Frame Rate**: 60 FPS

### RealityKit
- **Entity Component System**: Modern 3D architecture
- **Anchors**: World-space positioning
- **Materials**: PBR and unlit rendering
- **Mesh Generation**: Procedural geometry

### Nearby Interaction
- **U1 Chip**: Ultra-wideband radio
- **Accuracy**: ±10cm typical
- **Range**: ~10m indoors
- **Update Rate**: ~10Hz

### MultipeerConnectivity
- **Purpose**: Token exchange (demo)
- **Transport**: Bluetooth + WiFi
- **Security**: Encrypted connections

---

## Performance Characteristics

| Component | Update Rate | CPU Usage | GPU Usage |
|-----------|-------------|-----------|-----------|
| NISession | ~10 Hz | Low | None |
| ARKit | 60 Hz | Medium | High |
| Visualizer | 30 Hz | Low | Medium |
| UI | As needed | Low | Low |

---

## Memory Footprint

- **ARKit Session**: ~50-100 MB
- **RealityKit Entities**: ~5-10 MB
- **NISession**: ~5 MB
- **Total**: ~60-115 MB typical

---

## Threading Model

```
Main Thread:
  - SwiftUI updates
  - UI interactions
  - State changes

ARKit Thread:
  - Camera processing
  - World tracking
  - Frame rendering

NI Thread:
  - Distance calculations
  - Direction updates
  - Delegate callbacks

Background Threads:
  - MultipeerConnectivity
  - Network operations
```

---

## Extension Points

### Easy Customizations
1. **Colors**: Change material tints in `AirTagVisualizer`
2. **Sizes**: Adjust box/image dimensions
3. **Images**: Replace icon in `createAirTagSymbolImage()`
4. **UI**: Modify SwiftUI layout in `ContentView`

### Advanced Modifications
1. **Multiple AirTags**: Track array of objects
2. **Custom Geometry**: Replace box with other shapes
3. **Animations**: Add scale/rotation effects
4. **Haptics**: Add feedback on distance changes
5. **Sound**: Audio cues for guidance

---

## Production Considerations

### For Real AirTag Integration

1. **Apple MFi Program**
   - Required for Find My network access
   - Hardware certification needed
   - Legal agreements

2. **Security**
   - Encrypted token exchange
   - User privacy protection
   - Secure storage of credentials

3. **Battery Optimization**
   - Reduce update rates when idle
   - Pause AR when backgrounded
   - Efficient rendering

4. **Error Handling**
   - Network failures
   - Permission denials
   - Device compatibility

---

## Testing Strategy

### Unit Tests
- NearbyInteractionManager state management
- Distance calculations
- Direction vector math

### Integration Tests
- AR session lifecycle
- NI session coordination
- UI state synchronization

### Device Tests
- iPhone 11, 12, 13, 14, 15
- Different lighting conditions
- Various distances (0.5m - 10m)
- Occlusion scenarios

---

## Debug Tips

### Enable Verbose Logging
```swift
// In NearbyInteractionManager
print("NISession state: \(session)")
print("Distance: \(distance), Direction: \(direction)")
```

### Visualize Debug Info
```swift
// In AirTagVisualizer
// Add text labels showing distance/direction
```

### ARKit Debug Options
```swift
arView.debugOptions = [
    .showWorldOrigin,
    .showFeaturePoints,
    .showAnchorOrigins
]
```

---

## Further Reading

- [ARKit Documentation](https://developer.apple.com/documentation/arkit)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [Nearby Interaction Guide](https://developer.apple.com/documentation/nearbyinteraction)
- [WWDC Sessions on Spatial Computing](https://developer.apple.com/videos/)

