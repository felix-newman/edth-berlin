# AirTag Locator - iOS AR App

An iOS application that uses ARKit and the Nearby Interaction framework to localize AirTags in 3D space, displaying a bounding box around them with an image overlay.

## Features

- 🎯 **Real-time U1 Chip Localization**: Uses Apple's Nearby Interaction framework with real U1 chip data
- 📦 **3D Bounding Box**: Draws a cyan wireframe box around the detected device in AR space
- 🖼️ **Image Overlay**: Displays a location pin icon above the bounding box
- 📏 **Distance Display**: Shows real-time distance in meters with centimeter accuracy
- 🎨 **Modern UI**: Clean, intuitive interface with status indicators
- 📡 **Peer-to-Peer**: Works between two iPhones (iPhone 11+) using real U1 chip distance data

## Requirements

- **iOS 16.0+**
- **Xcode 15.0+**
- **Two iPhones with U1 chip** (iPhone 11 or later) for real distance tracking
- **ARKit-compatible device**

**Note**: This app uses **real Nearby Interaction data** between two U1-equipped iPhones. It does NOT work with AirTags directly (see explanation below).

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

### Setup (Requires TWO iPhones with U1 chip)

1. **Install the app on BOTH iPhones** (iPhone 11 or later)
2. **Launch the app on BOTH devices**
3. **Grant permissions** for Camera and Nearby Interaction when prompted
4. **Tap "Start Tracking" on BOTH devices**

### Tracking

5. The devices will **automatically discover each other** via MultipeerConnectivity
6. Once connected, you'll see:
   - Status: "Connected to [Device Name]"
   - Real-time distance updates using U1 chip
   - A cyan bounding box in AR showing the other iPhone's position
   - A location pin icon above the box
7. **Move the devices closer or farther** apart to see **real distance data** update
8. The bounding box position updates based on actual U1 chip measurements

### What You're Seeing

- **Distance accuracy**: ±10cm (real U1 chip precision)
- **Direction**: 3D vector pointing to the other device
- **Update rate**: ~10Hz from Nearby Interaction framework
- **This is the SAME technology AirTags use** for precise location

## Important Notes

### Why This Doesn't Work with AirTags Directly

**AirTags are NOT accessible via standard Nearby Interaction APIs.** Here's why:

1. **Find My Network is Private**: AirTags only communicate through Apple's encrypted Find My network
2. **Requires MFi Certification**: You need to join Apple's MFi (Made for iPhone) program
3. **NDA Required**: Apple requires legal agreements and hardware certification
4. **No Public API**: There is no public API to access AirTag location data

### What This App Actually Does

This app uses **real U1 chip technology** between two iPhones:

✅ **Real distance measurements** (±10cm accuracy)  
✅ **Real direction vectors** in 3D space  
✅ **Same U1 chip** that AirTags use  
✅ **Same NISession API** that would be used with certified accessories  
✅ **No simulation** - all data comes from actual ultra-wideband radio

**This is the exact same technology AirTags use**, just between iPhones instead of with an AirTag.

### To Use With Real AirTags

You would need to:

1. **Join Apple's MFi Program** (requires business, NDA, fees)
2. **Get Find My Network certification** from Apple
3. **Obtain special entitlements** for your app
4. **Hardware certification** if building accessories
5. **Legal agreements** with Apple

This is not available to individual developers without going through Apple's formal program.

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

### No Devices Detected

- Ensure **both iPhones** have the app running
- Both devices must tap "Start Tracking"
- Ensure Bluetooth and WiFi are enabled on both
- Make sure devices are within ~10 meters
- Check that both devices are iPhone 11 or later
- Try restarting the app on both devices

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
