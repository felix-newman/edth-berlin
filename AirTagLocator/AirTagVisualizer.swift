import ARKit
import RealityKit
import UIKit

class AirTagVisualizer {
    private let arView: ARView
    private var boundingBoxEntity: ModelEntity?
    private var imageEntity: ModelEntity?
    private var anchorEntity: AnchorEntity?
    
    init(arView: ARView) {
        self.arView = arView
        setupAnchor()
    }
    
    private func setupAnchor() {
        // Create anchor at origin
        anchorEntity = AnchorEntity(world: .zero)
        arView.scene.addAnchor(anchorEntity!)
    }
    
    func updateAirTagPosition(distance: Float, direction: simd_float3) {
        // Calculate position based on distance and direction
        let position = direction * distance
        
        // Update or create bounding box
        if boundingBoxEntity == nil {
            createBoundingBox()
        }
        
        // Update or create image overlay
        if imageEntity == nil {
            createImageOverlay()
        }
        
        // Update positions
        boundingBoxEntity?.position = position
        
        // Position image above the bounding box
        let imageOffset = simd_float3(0, 0.15, 0) // 15cm above
        imageEntity?.position = position + imageOffset
        
        // Make entities face the camera
        if let cameraTransform = arView.session.currentFrame?.camera.transform {
            let cameraPosition = simd_float3(cameraTransform.columns.3.x,
                                            cameraTransform.columns.3.y,
                                            cameraTransform.columns.3.z)
            
            // Calculate look-at rotation for the image
            let lookDirection = normalize(cameraPosition - (position + imageOffset))
            let rotation = simd_quatf(from: simd_float3(0, 0, 1), to: lookDirection)
            imageEntity?.orientation = rotation
        }
    }
    
    private func createBoundingBox() {
        // Create a wireframe bounding box
        let boxSize: Float = 0.1 // 10cm box
        
        // Create box mesh
        let mesh = MeshResource.generateBox(size: boxSize, cornerRadius: 0.005)
        
        // Create material with wireframe appearance
        var material = UnlitMaterial()
        material.color = .init(tint: .cyan.withAlphaComponent(0.8))
        
        // Create entity
        boundingBoxEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Add wireframe edges
        addWireframeEdges(to: boundingBoxEntity!, boxSize: boxSize)
        
        anchorEntity?.addChild(boundingBoxEntity!)
    }
    
    private func addWireframeEdges(to entity: ModelEntity, boxSize: Float) {
        let halfSize = boxSize / 2
        let edgeThickness: Float = 0.003
        
        // Define the 12 edges of a cube
        let edges: [(start: simd_float3, end: simd_float3)] = [
            // Bottom face
            (simd_float3(-halfSize, -halfSize, -halfSize), simd_float3(halfSize, -halfSize, -halfSize)),
            (simd_float3(halfSize, -halfSize, -halfSize), simd_float3(halfSize, -halfSize, halfSize)),
            (simd_float3(halfSize, -halfSize, halfSize), simd_float3(-halfSize, -halfSize, halfSize)),
            (simd_float3(-halfSize, -halfSize, halfSize), simd_float3(-halfSize, -halfSize, -halfSize)),
            
            // Top face
            (simd_float3(-halfSize, halfSize, -halfSize), simd_float3(halfSize, halfSize, -halfSize)),
            (simd_float3(halfSize, halfSize, -halfSize), simd_float3(halfSize, halfSize, halfSize)),
            (simd_float3(halfSize, halfSize, halfSize), simd_float3(-halfSize, halfSize, halfSize)),
            (simd_float3(-halfSize, halfSize, halfSize), simd_float3(-halfSize, halfSize, -halfSize)),
            
            // Vertical edges
            (simd_float3(-halfSize, -halfSize, -halfSize), simd_float3(-halfSize, halfSize, -halfSize)),
            (simd_float3(halfSize, -halfSize, -halfSize), simd_float3(halfSize, halfSize, -halfSize)),
            (simd_float3(halfSize, -halfSize, halfSize), simd_float3(halfSize, halfSize, halfSize)),
            (simd_float3(-halfSize, -halfSize, halfSize), simd_float3(-halfSize, halfSize, halfSize)),
        ]
        
        // Create edge material
        var edgeMaterial = UnlitMaterial()
        edgeMaterial.color = .init(tint: .cyan)
        
        // Create cylinder for each edge
        for edge in edges {
            let direction = edge.end - edge.start
            let length = simd_length(direction)
            let midpoint = (edge.start + edge.end) / 2
            
            let cylinder = MeshResource.generateCylinder(height: length, radius: edgeThickness)
            let edgeEntity = ModelEntity(mesh: cylinder, materials: [edgeMaterial])
            
            // Position at midpoint
            edgeEntity.position = midpoint
            
            // Rotate to align with edge direction
            let up = simd_float3(0, 1, 0)
            let normalizedDirection = normalize(direction)
            let rotation = simd_quatf(from: up, to: normalizedDirection)
            edgeEntity.orientation = rotation
            
            entity.addChild(edgeEntity)
        }
    }
    
    private func createImageOverlay() {
        // Create a plane to display the image
        let planeSize: Float = 0.08 // 8cm
        let mesh = MeshResource.generatePlane(width: planeSize, height: planeSize, cornerRadius: 0.01)
        
        // Create material with an image
        var material = UnlitMaterial()
        
        // Create a simple colored texture as placeholder
        // In production, you'd load an actual image
        let image = createAirTagSymbolImage()
        if let cgImage = image.cgImage {
            let texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
            material.color = .init(texture: .init(texture!))
        } else {
            material.color = .init(tint: .white)
        }
        
        imageEntity = ModelEntity(mesh: mesh, materials: [material])
        
        // Add a subtle glow effect
        addGlowEffect(to: imageEntity!)
        
        anchorEntity?.addChild(imageEntity!)
    }
    
    private func createAirTagSymbolImage() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw background circle
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: rect)
            
            // Draw AirTag symbol (simplified Apple logo style)
            let symbolRect = rect.insetBy(dx: 40, dy: 40)
            context.cgContext.setFillColor(UIColor.systemBlue.cgColor)
            
            // Draw a location pin icon
            let pinPath = UIBezierPath()
            let centerX = symbolRect.midX
            let topY = symbolRect.minY
            let bottomY = symbolRect.maxY
            let width = symbolRect.width * 0.6
            
            // Pin head (circle)
            let headRadius = width / 2
            let headCenter = CGPoint(x: centerX, y: topY + headRadius)
            pinPath.addArc(withCenter: headCenter, radius: headRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            
            // Pin point (triangle)
            pinPath.move(to: CGPoint(x: centerX - headRadius * 0.7, y: headCenter.y + headRadius * 0.5))
            pinPath.addLine(to: CGPoint(x: centerX, y: bottomY))
            pinPath.addLine(to: CGPoint(x: centerX + headRadius * 0.7, y: headCenter.y + headRadius * 0.5))
            
            pinPath.close()
            pinPath.fill()
            
            // Draw inner circle (hole in pin head)
            let innerRadius = headRadius * 0.4
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fillEllipse(in: CGRect(x: centerX - innerRadius,
                                                     y: headCenter.y - innerRadius,
                                                     width: innerRadius * 2,
                                                     height: innerRadius * 2))
        }
    }
    
    private func addGlowEffect(to entity: ModelEntity) {
        // Add a larger, semi-transparent plane behind for glow effect
        let glowSize: Float = 0.12
        let glowMesh = MeshResource.generatePlane(width: glowSize, height: glowSize, cornerRadius: glowSize / 2)
        
        var glowMaterial = UnlitMaterial()
        glowMaterial.color = .init(tint: .cyan.withAlphaComponent(0.3))
        
        let glowEntity = ModelEntity(mesh: glowMesh, materials: [glowMaterial])
        glowEntity.position = simd_float3(0, 0, 0.001) // Slightly behind
        
        entity.addChild(glowEntity)
    }
    
    func removeVisualization() {
        boundingBoxEntity?.removeFromParent()
        imageEntity?.removeFromParent()
        boundingBoxEntity = nil
        imageEntity = nil
    }
}

