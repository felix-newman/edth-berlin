# Quick Start Guide

## Get Started in 3 Steps

### 1. Open in Xcode
```bash
open AirTagLocator.xcodeproj
```

### 2. Configure Your Team
- Select **AirTagLocator** target
- Go to **Signing & Capabilities**
- Choose your **Development Team**

### 3. Run on Device
- Connect iPhone 11 or later
- Press **⌘R** to build and run

## What You'll See

1. **Main Screen**: Shows connection status and distance
2. **AR View**: Camera view with AR overlays
3. **Start Tracking Button**: Begins AirTag search

## Controls

- **Start Tracking**: Begin searching for AirTags
- **Stop Tracking**: End the session
- **Status Indicator**: Green = connected, Red = disconnected

## Key Features Demonstrated

✅ **3D Bounding Box**: Cyan wireframe around detected object  
✅ **Image Overlay**: Location pin icon above the box  
✅ **Real-time Distance**: Updates as you move  
✅ **Camera-Facing UI**: Image always faces you  

## Demo Mode

The app includes **simulated distance updates** for testing without a real AirTag. This lets you:
- Test the UI and AR visualization
- See how the bounding box moves
- Verify the image overlay works
- Check distance calculations

## Requirements Checklist

- [ ] iPhone 11 or later (U1 chip required)
- [ ] iOS 16.0+
- [ ] Xcode 15.0+
- [ ] Camera permission granted
- [ ] Good lighting for AR tracking

## Troubleshooting

**App won't build?**
- Check your Development Team is selected
- Ensure bundle identifier is unique

**AR not working?**
- Grant camera permission in Settings
- Ensure good lighting
- Move device to initialize ARKit

**No AirTags found?**
- App uses demo mode by default
- Real AirTag integration requires Apple MFi program

## Next Steps

Read the full [README.md](README.md) for:
- Detailed architecture explanation
- Customization options
- Production deployment requirements
- API documentation

---

**Ready to customize?** Check out `AirTagVisualizer.swift` to modify colors, sizes, and images!

