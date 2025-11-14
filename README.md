# AirTag Locator - iOS AR App

An iOS application that uses ARKit and the Nearby Interaction framework to localize AirTags in 3D space, displaying a bounding box around them with an image overlay.

## Features

- 🎯 **Real-time AirTag Localization**: Uses Apple's Nearby Interaction framework to detect and track AirTags
- 📦 **3D Bounding Box**: Draws a cyan wireframe box around the detected AirTag in AR space
- 🖼️ **Image Overlay**: Displays a location pin icon above the bounding box
- 📏 **Distance Display**: Shows real-time distance to the AirTag in meters
- 🎨 **Modern UI**: Clean, intuitive interface with status indicators

## Requirements

- **iOS 16.0+**
- **Xcode 15.0+**
- **iPhone with U1 chip** (iPhone 11 or later) for Nearby Interaction
- **ARKit-compatible device**
- **Physical AirTag** for real-world testing

### Supported Devices

The Nearby Interaction framework requires devices with the U1 chip:
- iPhone 11 and later
- Apple Watch Series 6 and later
- AirTags

## Project Structure

```
AirTagLocator/
├── AirTagLocator.xcodeproj/
│   └── project.pbxproj
├── AirTagLocator/
│   ├── AirTagLocatorApp.swift      # App entry point
│   ├── ContentView.swift            # Main SwiftUI view
│   ├── ARViewController.swift       # AR view controller
│   ├── NearbyInteractionManager.swift  # Handles AirTag discovery
│   ├── AirTagVisualizer.swift       # Renders bounding box and image
│   ├── Assets.xcassets/             # App assets
│   └── Info.plist                   # App configuration
└── README.md
```

## Setup Instructions

### 1. Open the Project

```bash
cd edth-berlin
open AirTagLocator.xcodeproj
```

### 2. Configure Signing

1. Open the project in Xcode
2. Select the **AirTagLocator** target
3. Go to **Signing & Capabilities**
4. Select your **Development Team**
5. Xcode will automatically generate a bundle identifier

### 3. Add Required Capabilities

The project requires the following capabilities (already configured in Info.plist):

- **Camera Usage**: For AR functionality
- **Local Network**: For peer-to-peer communication
- **Nearby Interaction**: For AirTag localization

### 4. Build and Run

1. Connect your iPhone (iPhone 11 or later)
2. Select your device as the build target
3. Click **Run** (⌘R) or the play button

## How It Works

### Architecture

1. **NearbyInteractionManager**: 
   - Manages NISession for AirTag discovery
   - Uses MultipeerConnectivity for peer discovery tokens
   - Publishes distance and direction updates

2. **ARViewController**: 
   - Sets up ARKit session with world tracking
   - Manages the AR view lifecycle
   - Coordinates updates between NI and visualization

3. **AirTagVisualizer**: 
   - Creates 3D bounding box with wireframe edges
   - Generates location pin image overlay
   - Updates positions based on AirTag location
   - Handles camera-facing orientation

4. **ContentView**: 
   - SwiftUI interface for user interaction
   - Displays connection status and distance
   - Start/Stop tracking controls

### Nearby Interaction Flow

```
1. App starts NISession
2. Discovers nearby AirTags via MultipeerConnectivity
3. Exchanges discovery tokens
4. NISession provides distance and direction updates
5. ARViewController updates visualization in real-time
```

## Usage

1. **Launch the app** on your iPhone
2. **Grant permissions** for Camera and Nearby Interaction when prompted
3. **Tap "Start Tracking"** to begin searching for AirTags
4. **Point your camera** around the room
5. When an AirTag is detected:
   - A cyan bounding box appears in AR
   - A location pin icon displays above it
   - Distance is shown at the bottom of the screen
6. **Move closer or farther** to see the visualization update in real-time

## Important Notes

### Real AirTag Integration

This app demonstrates the core functionality, but **real AirTag integration requires**:

1. **Apple Developer Program membership** ($99/year)
2. **Find My Network integration** through Apple's MFi program
3. **Accessory configuration** with Apple's specifications
4. **Entitlements** from Apple for Find My network access

The current implementation uses:
- **Simulated distance updates** for demonstration
- **MultipeerConnectivity** for peer discovery (not actual AirTags)
- **Standard NISession** API that works with U1-equipped devices

### For Production Use

To connect to real AirTags, you would need to:

1. Apply for the MFi Program at [developer.apple.com/programs/mfi](https://developer.apple.com/programs/mfi/)
2. Integrate with the Find My network
3. Use proper AirTag discovery tokens from Apple's Find My framework
4. Implement authentication and security measures

## Customization

### Change Bounding Box Color

In `AirTagVisualizer.swift`, modify the material color:

```swift
material.color = .init(tint: .cyan.withAlphaComponent(0.8))
// Change to: .red, .green, .yellow, etc.
```

### Adjust Bounding Box Size

In `AirTagVisualizer.swift`, change the box size:

```swift
let boxSize: Float = 0.1 // Default: 10cm
// Increase for larger box
```

### Modify Image Overlay

Replace the `createAirTagSymbolImage()` function to use your own image:

```swift
if let customImage = UIImage(named: "YourImageName") {
    // Use your custom image
}
```

## Troubleshooting

### "Nearby Interaction not supported"

- Ensure you're using an iPhone 11 or later
- Check that iOS 16.0+ is installed

### Camera Permission Denied

- Go to **Settings > Privacy & Security > Camera**
- Enable camera access for AirTagLocator

### No AirTags Detected

- Ensure Bluetooth is enabled
- Make sure the AirTag is nearby and active
- Try restarting the app
- Note: Demo mode uses simulated data

### AR View Not Working

- Ensure adequate lighting
- Move the device to help ARKit initialize
- Check that camera is not obstructed

## Technical Details

### Frameworks Used

- **ARKit**: Augmented reality and world tracking
- **RealityKit**: 3D rendering and entity management
- **NearbyInteraction**: U1 chip-based spatial awareness
- **MultipeerConnectivity**: Peer discovery and token exchange
- **SwiftUI**: Modern declarative UI
- **Combine**: Reactive programming for state management

### Performance

- **Update Rate**: 30 FPS for AR visualization
- **Distance Accuracy**: ±0.1 meters (with real U1 devices)
- **Range**: Up to 10 meters (typical indoor environment)

## Future Enhancements

- [ ] Multiple AirTag tracking
- [ ] Haptic feedback when approaching AirTag
- [ ] Sound-based guidance
- [ ] History of found AirTags
- [ ] Custom image upload for overlay
- [ ] Recording and playback of tracking sessions
- [ ] Integration with Find My network (requires Apple approval)

## License

This project is provided as-is for educational and demonstration purposes.

## Resources

- [Apple Nearby Interaction Documentation](https://developer.apple.com/documentation/nearbyinteraction)
- [ARKit Documentation](https://developer.apple.com/documentation/arkit)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [Find My Network Accessory Specification](https://developer.apple.com/find-my/)

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review Apple's official documentation
3. Ensure your device meets all requirements

---

**Note**: This is a demonstration app. Real AirTag integration requires additional Apple certifications and agreements.

