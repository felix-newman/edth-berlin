# Features & Visual Guide

## App Interface

### Main Screen Layout

```
┌─────────────────────────────────────┐
│  📱 AirTag Locator                  │
├─────────────────────────────────────┤
│                                     │
│         🎥 AR Camera View           │
│                                     │
│     ┌─────────────┐                │
│     │             │                │
│     │   📍 Icon   │  ← Image Overlay
│     │             │                │
│     └─────────────┘                │
│           │                         │
│     ┌─────┴─────┐                  │
│     │           │                  │
│     │  ┌─────┐  │  ← Bounding Box │
│     │  │     │  │     (Cyan)       │
│     │  └─────┘  │                  │
│     │           │                  │
│     └───────────┘                  │
│                                     │
│                                     │
├─────────────────────────────────────┤
│                                     │
│   ┌─────────────────────────────┐  │
│   │ 🟢 AirTag detected          │  │
│   └─────────────────────────────┘  │
│                                     │
│   ┌─────────────────────────────┐  │
│   │   Distance: 2.34 m          │  │
│   └─────────────────────────────┘  │
│                                     │
│   ┌─────────────────────────────┐  │
│   │    🛑 Stop Tracking         │  │
│   └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

## Feature Breakdown

### 1. 3D Bounding Box 📦

**Visual Appearance**:

- Cyan wireframe cube
- 10cm × 10cm × 10cm default size
- 12 edges rendered as thin cylinders
- Semi-transparent faces
- Glows slightly for visibility

**Behavior**:

- Follows AirTag position in 3D space
- Updates 30 times per second
- Maintains size regardless of distance
- Visible through AR camera

**Technical Details**:

```
Material: Unlit (always visible)
Color: Cyan (RGB: 0, 255, 255, 80% opacity)
Edge Thickness: 3mm
Rendering: RealityKit ModelEntity
```

---

### 2. Image Overlay 🖼️

**Visual Appearance**:

- Location pin icon
- 8cm × 8cm plane
- White background with blue pin
- Positioned 15cm above bounding box
- Always faces the camera

**Icon Design**:

```
┌─────────┐
│    ●    │  ← Circle head
│   ╱ ╲   │
│  ╱   ╲  │  ← Pin body
│ ╱     ╲ │
│    ▼    │  ← Point
└─────────┘
```

**Behavior**:

- Billboard effect (always faces user)
- Smooth rotation following camera
- Maintains fixed offset from box
- High contrast for visibility

---

### 3. Distance Display 📏

**Format**: `Distance: X.XX m`

**Examples**:

- `Distance: 0.52 m` - Very close
- `Distance: 2.34 m` - Medium range
- `Distance: 8.91 m` - Far away

**Accuracy**:

- Real U1 devices: ±10cm
- Demo mode: Simulated values
- Updates in real-time

**Color Coding** (potential enhancement):

- 🟢 Green: < 1m (close)
- 🟡 Yellow: 1-5m (medium)
- 🔴 Red: > 5m (far)

---

### 4. Status Indicator 🚦

**States**:

#### Not Connected 🔴

```
┌─────────────────────────┐
│ 🔴 Not connected        │
└─────────────────────────┘
```

#### Searching 🟡

```
┌─────────────────────────┐
│ 🟡 Searching for AirTags│
└─────────────────────────┘
```

#### Connected 🟢

```
┌─────────────────────────┐
│ 🟢 AirTag detected      │
└─────────────────────────┘
```

#### Error ⚠️

```
┌─────────────────────────┐
│ ⚠️ Session error        │
└─────────────────────────┘
```

---

### 5. Control Buttons 🎮

#### Start Tracking (Green)

```
┌─────────────────────────┐
│   ▶️ Start Tracking     │
└─────────────────────────┘
```

- Begins AirTag search
- Initializes NISession
- Starts AR tracking

#### Stop Tracking (Red)

```
┌─────────────────────────┐
│   🛑 Stop Tracking      │
└─────────────────────────┘
```

- Ends tracking session
- Pauses AR
- Clears visualization

---

## AR Visualization Details

### Bounding Box Wireframe

```
     Top Face
    ┌─────────┐
   ╱│        ╱│
  ╱ │       ╱ │
 ┌─────────┐  │  ← Edges are 3D cylinders
 │  │      │  │
 │  └──────│──┘
 │ ╱       │ ╱
 │╱        │╱
 └─────────┘
   Bottom Face
```

**12 Edges**:

- 4 bottom edges
- 4 top edges
- 4 vertical edges

**Rendering**:

- Each edge is a thin cylinder
- Cylinders rotated to align with cube edges
- Uniform cyan color
- No face filling (wireframe only)

---

### Image Billboard Effect

```
Camera Position: 👁️

        📍
       ╱│╲
      ╱ │ ╲
     ╱  │  ╲
    ╱   │   ╲
   ╱    │    ╲
        ▼
    Bounding Box
```

The image always rotates to face the camera:

- Calculates camera position each frame
- Computes look-at vector
- Applies rotation quaternion
- Smooth interpolation

---

## User Experience Flow

### Initial State

```
1. App launches
2. Shows camera view
3. Status: "Not connected" 🔴
4. Button: "Start Tracking" (green)
```

### Starting Tracking

```
1. User taps "Start Tracking"
2. Status changes to "Searching..." 🟡
3. Permissions requested (if needed)
4. NISession initializes
```

### AirTag Detected

```
1. Status: "AirTag detected" 🟢
2. Bounding box appears in AR
3. Image overlay appears above
4. Distance updates in real-time
5. Button changes to "Stop Tracking" (red)
```

### Moving Around

```
1. User moves closer → distance decreases
2. User moves farther → distance increases
3. Box position updates smoothly
4. Image always faces user
```

### Stopping

```
1. User taps "Stop Tracking"
2. Visualization disappears
3. Status: "Not connected" 🔴
4. Button: "Start Tracking" (green)
```

---

## Visual Effects

### Glow Effect

The image has a subtle glow:

```
┌─────────────┐
│ ╭─────────╮ │  ← Outer glow (cyan, 30% opacity)
│ │ ┌─────┐ │ │
│ │ │ 📍  │ │ │  ← Main image
│ │ └─────┘ │ │
│ ╰─────────╯ │
└─────────────┘
```

### Transparency

- Bounding box: 80% opaque
- Image background: 100% opaque
- Glow effect: 30% opaque

### Anti-aliasing

- Smooth edges on all geometry
- Corner radius on image plane
- High-quality rendering

---

## Responsive Design

### Portrait Mode

```
┌─────────┐
│         │
│   AR    │
│  View   │
│         │
│         │
├─────────┤
│ Status  │
│Distance │
│ Button  │
└─────────┘
```

### Landscape Mode (iPad)

```
┌─────────────────────────┐
│           AR            │
│          View           │
│                         │
├─────────┬───────────────┤
│ Status  │   Distance    │
│ Button  │   Controls    │
└─────────┴───────────────┘
```

---

## Accessibility Features

### VoiceOver Support

- Status announcements
- Distance readouts
- Button labels
- Error messages

### Dynamic Type

- Text scales with system settings
- Minimum readable size maintained
- Layout adjusts automatically

### High Contrast

- Clear visual indicators
- Strong color differentiation
- Readable in bright sunlight

---

## Color Palette

| Element          | Color  | Hex       | Usage            |
| ---------------- | ------ | --------- | ---------------- |
| Bounding Box     | Cyan   | `#00FFFF` | Wireframe edges  |
| Image Background | White  | `#FFFFFF` | Icon background  |
| Pin Icon         | Blue   | `#007AFF` | Location marker  |
| Glow Effect      | Cyan   | `#00FFFF` | Subtle highlight |
| Success          | Green  | `#34C759` | Connected state  |
| Error            | Red    | `#FF3B30` | Error state      |
| Warning          | Yellow | `#FFCC00` | Searching state  |

---

## Animation & Motion

### Smooth Transitions

- Position updates: Linear interpolation
- Rotation: Spherical interpolation (slerp)
- Appearance: Fade in over 0.3s
- Disappearance: Fade out over 0.2s

### Frame Rates

- AR rendering: 60 FPS
- Visualization updates: 30 FPS
- UI updates: As needed
- NISession: ~10 Hz

---

## Real-World Examples

### Close Range (< 1m)

```
Distance: 0.67 m
Box appears large in view
Very precise positioning
Easy to locate
```

### Medium Range (1-5m)

```
Distance: 2.84 m
Box clearly visible
Good tracking accuracy
Comfortable viewing
```

### Far Range (5-10m)

```
Distance: 7.23 m
Box appears smaller
Still trackable
May need to move closer
```

---

## Tips for Best Experience

1. **Lighting**: Use in well-lit environments
2. **Movement**: Move slowly for best tracking
3. **Distance**: Optimal range is 1-5 meters
4. **Obstacles**: Clear line of sight helps
5. **Calibration**: Let ARKit initialize (move device around)

---

## Future Visual Enhancements

- [ ] Animated pulse effect on detection
- [ ] Trail showing AirTag movement history
- [ ] Directional arrow when out of view
- [ ] Heat map of search area
- [ ] Multiple AirTag colors
- [ ] Custom image upload
- [ ] AR measurement tools
- [ ] Screenshot/recording capability
