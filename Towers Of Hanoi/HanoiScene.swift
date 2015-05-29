//
//  HanoiScene.swift
//  Towers Of Hanoi
//
//  Created by Silviu Pop on 10/23/14.
//  Copyright (c) 2014 We Heart Swift. All rights reserved.
//

import SceneKit

class HanoiScene: SCNScene {
    
    var numberOfDisks = 4
    
    // pegs settings
    var pegHeight: CGFloat = 0.0
    let pegRadius: CGFloat = 0.1
    var pegs: [SCNNode] = []
    
    // disks settings
    let diskHeight: CGFloat = 0.2
    let diskRadius: CGFloat = 1.0
    var disks: [SCNNode] = []
    
    // board settings
    var boardWidth: CGFloat = 0.0
    var boardLength: CGFloat = 0.0
    var boardPadding: CGFloat = 0.8
    var boardHeight: CGFloat = 0.2
    
    // Hanoi algorithm implementations
    var hanoiSolver: HanoiSolver
    
    override init() {
        
        self.hanoiSolver = HanoiSolver(numberOfDisks: numberOfDisks) as HanoiSolver
        
        super.init()
        
        // initialize
        createBoard()
        createPegs()
        createDisks()
        
        // play Hanoi and animations
        playAnimation()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createBoard() {
        boardWidth = diskRadius * 6.0 + boardPadding
        boardLength = diskRadius * 2.0 + boardPadding
        
        // create SCNBox
        let boardGeometry = SCNBox(width: boardWidth, height: boardHeight, length: boardLength, chamferRadius: 0.1)
        boardGeometry.firstMaterial?.diffuse.contents = UIColor.brownColor()

        // create SCNNode
        let boardNode = SCNNode(geometry: boardGeometry)
        
        rootNode.addChildNode(boardNode)
    }
    
    func createPegs() {
        pegHeight = CGFloat(numberOfDisks + 3) * diskHeight
        
        var x:Float = Float(-boardWidth/2 + boardPadding/2 + diskRadius)
        
        for i in 0..<3 {
            let cylinder = SCNCylinder(radius: pegRadius, height: pegHeight)
            cylinder.firstMaterial?.diffuse.contents = UIColor.brownColor()
            
            let cylinderNode = SCNNode(geometry: cylinder)
            cylinderNode.position.x = x
            cylinderNode.position.y = Float(pegHeight/2.0 + boardHeight/2.0)
         
            rootNode.addChildNode(cylinderNode)
            pegs.append(cylinderNode)
            
            x += Float(diskRadius * 2)
        }
    }
    
    func createDisks() {
        var firstPeg = pegs[0]
        
        var y:Float = Float(boardHeight/2 + diskHeight/2)
        
        var radius:CGFloat = diskRadius
        
        for i in 0..<numberOfDisks {
            
            let hue = CGFloat(i) / CGFloat(numberOfDisks+1)
            let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            
            let tube = SCNTube(innerRadius: pegRadius, outerRadius: radius, height: diskHeight)
            tube.firstMaterial?.diffuse.contents = color
            
            let tubeNode = SCNNode(geometry: tube)
            tubeNode.position.x = firstPeg.position.x
            tubeNode.position.y = y
            
            rootNode.addChildNode(tubeNode)
            disks.append(tubeNode)
            
            y += Float(diskHeight)
            radius -= 0.1
        }
    }
    
    // animations
    func animationFromMove(move: HanoiMove) -> SCNAction {
        
        var duration = 0.0
        
        let node = disks[move.diskIndex]
        let destination = pegs[move.destinationPegIndex]
        
        // Move to top
        var topPosition = node.position
        topPosition.y = Float(pegHeight + diskHeight * CGFloat(numberOfDisks))
        duration = normalizeDuration(node.position, endPosition: topPosition)
        let moveUp = SCNAction.moveTo(topPosition, duration: duration)
        
        // Move sideways
        var sidePosition = destination.position
        sidePosition.y = topPosition.y
        duration = normalizeDuration(topPosition, endPosition: sidePosition)
        let moveSide = SCNAction.moveTo(sidePosition, duration: duration)
        
        // Move to bottom
        var bottomPosition = sidePosition
        bottomPosition.y = Float(boardHeight/2.0 + diskHeight/2.0) + Float(move.destinationDiskCount)*Float(diskHeight)
        duration = normalizeDuration(sidePosition, endPosition: bottomPosition)
        let moveDown = SCNAction.moveTo(bottomPosition, duration: duration)
        
        // create sequence
        let sequence = SCNAction.sequence([moveUp, moveSide, moveDown])
        return sequence
        
    }
    
    func recursiveAnimation(index: Int) {
        
        let move = hanoiSolver.moves[index]
        let animation = animationFromMove(move)
        
        // get node and apply animation
        let node = disks[move.diskIndex]
        node.runAction(animation, completionHandler: {
            if (index + 1) < self.hanoiSolver.moves.count {
                self.recursiveAnimation(index + 1)
            }
        })
    }
    
    func playAnimation() {
        
        // construct moves (Hanoi algorithm within)
        hanoiSolver.computeMove()
        
        // animate moves
        recursiveAnimation(0)
        
    }
    
    // normalize moving speed
    func lengthOfVector(v: SCNVector3) -> Float {
        return sqrtf(pow(v.x, 2.0) + pow(v.y, 2.0) + pow(v.z, 2.0))
    }
    
    func distanceBetweenVectors(v1: SCNVector3, v2: SCNVector3) -> Float {
        return lengthOfVector(SCNVector3(x: v2.x-v1.x, y: v2.y-v1.y, z: v2.z-v1.z))
    }
    
    func normalizeDuration(startPosition: SCNVector3, endPosition: SCNVector3) -> Double {
        let length = distanceBetweenVectors(startPosition, v2: endPosition)
        let referenceLength = distanceBetweenVectors(pegs[0].position, v2: pegs[2].position)
        return 0.5 * Double(length/referenceLength)
    }
}
