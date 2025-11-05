//
//  GameScene.swift
//  WelldevTraining Project14
//
//  Created by Md. Kamrul Hasan on 5/8/25.
//

import SpriteKit

class GameScene: SKScene {
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var popupTime = 0.85
    var numRounds = 0
    var highScore = 0
    var isGamePaused = false
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        let pauseButton = SKSpriteNode(imageNamed: "pauseIcon")
        pauseButton.name = "pauseButton"
        pauseButton.position = CGPoint(x: self.size.width - 50, y: self.size.height - 50)
        pauseButton.zPosition = 2
        pauseButton.setScale(0.5)
        addChild(pauseButton)
        
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 10, y: 10)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if node.name == "restartButton" {
                if let newScene = GameScene(fileNamed: "GameScene") {
                    newScene.scaleMode = .aspectFill
                    view?.presentScene(newScene, transition: SKTransition.flipHorizontal(withDuration: 0.5))
                }
            }
            
            if node.name == "pauseButton" {
                togglePause()
                return
            }
            if isGamePaused { return }
  
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion:false))
            } else if node.name == "charEnemy" {
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion:false))
            }
            
        }
    }
    
    func togglePause() {
        if self.isPaused {
            self.isPaused = false
            childNode(withName: "pauseOverlay")?.removeFromParent()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.createEnemy()
            }
        } else {
            self.isPaused = true
            
            let pauseOverlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.4), size: self.size)
            pauseOverlay.name = "pauseOverlay"
            pauseOverlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            pauseOverlay.zPosition = 3
            addChild(pauseOverlay)

            let pauseLabel = SKLabelNode(text: "Game Paused")
            pauseLabel.fontName = "Chalkduster"
            pauseLabel.fontSize = 48
            pauseLabel.fontColor = .white
            pauseLabel.position = .zero
            pauseLabel.zPosition = 4
            pauseOverlay.addChild(pauseLabel)
        }
    }

    
    func pauseGame() {
        self.isPaused = true
        
        let pauseOverlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.4), size: self.size)
        pauseOverlay.name = "pauseOverlay"
        pauseOverlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        pauseOverlay.zPosition = 3
        addChild(pauseOverlay)
        
        let pauseLabel = SKLabelNode(text: "Game Paused")
        pauseLabel.fontName = "Chalkduster"
        pauseLabel.fontSize = 48
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint(x: 0, y: 0)
        pauseLabel.zPosition = 4
        pauseLabel.name = "pauseLabel"
        pauseOverlay.addChild(pauseLabel)
    }
    
    func resumeGame() {
        self.isPaused = false
        childNode(withName: "pauseOverlay")?.removeFromParent()
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "HighScore")
            }
            
            let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.6), size: self.size)
            overlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            overlay.zPosition = 0.5
            overlay.name = "blurOverlay"
            addChild(overlay)
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            let restartLabel = SKLabelNode(text: "Tap to Restart")
            restartLabel.fontName = "Chalkduster"
            restartLabel.fontSize = 36
            restartLabel.fontColor = .cyan
            restartLabel.position = CGPoint(x: 512, y: 160)
            restartLabel.zPosition = 1
            restartLabel.name = "restartButton"
            addChild(restartLabel)
            
            let finalScore = SKLabelNode(fontNamed: "Chalkduster")
            finalScore.text = "Final Score: \(score)"
            finalScore.fontSize = 48
            finalScore.position = CGPoint(x: 512, y: 300) // Position below gameOver
            finalScore.zPosition = 1
            finalScore.fontColor = .white
            addChild(finalScore)
            
            let highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
            highScoreLabel.text = "High Score: \(highScore)"
            highScoreLabel.fontSize = 36
            highScoreLabel.position = CGPoint(x: 512, y: 240)
            highScoreLabel.zPosition = 1
            highScoreLabel.fontColor = .yellow
            highScoreLabel.alpha = 0
            addChild(highScoreLabel)
            
            finalScore.run(SKAction.fadeIn(withDuration: 0.5))
            highScoreLabel.run(SKAction.fadeIn(withDuration: 0.5))
            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 {  slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)  }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            if !self.isPaused {
                self.createEnemy()
            }
        }
    }
}
