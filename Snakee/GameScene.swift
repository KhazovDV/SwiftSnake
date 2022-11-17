//
//  GameScene.swift
//  Snakee
//
//  Created by Caleb Cheng on 28/07/2016.
//  Copyright (c) 2016 Caleb Cheng. All rights reserved.
//

//make

import SpriteKit

class Body: SKSpriteNode {
    var row:Int = 0
    var col:Int = 0
    var nextMove: String = ""
    var curMove: String = ""
    var nextPos: CGPoint = CGPoint(x: 0, y: 0)
    var jumped: Bool = false
    
    func getRow() -> Int { // idek why these are functions
        return row
    }
    
    func getCol() -> Int {
        return col
    }
    
    convenience init(imageNamed: String)
    {
        let color = UIColor()
        let texture = SKTexture(imageNamed: imageNamed)
        let size = CGSizeMake(24.0, 24.0)
        self.init(texture: texture, color: color, size: size)
    }
}


class Fruit: SKSpriteNode {
    
    var row: Int = 0
    var col: Int = 0
    
    convenience init(imageNamed: String){
        let color = UIColor()
        let texture = SKTexture(imageNamed: imageNamed)
        let size = CGSizeMake(16, 16)
        self.init(texture: texture, color: color, size: size)
    }
}


class GameScene: SKScene {
    let viewWidth:CGFloat = UIScreen.main.bounds.width
    let viewHeight:CGFloat = UIScreen.main.bounds.height
    let gridCols = 16
    let gridRows = 10
    
    var gameOver = UILabel()
    var snakeHead = Body(imageNamed:"snakehead") // our snake head
    var grid:Grid = Grid(blockSize:0, rows:1, cols:1, renderGrid: shouldRenderGrid) // empty init of grid
    var apple: Fruit = Fruit(imageNamed: "apple")
    var mySnake: [Body] = [] // our snake is defined as an array of bodies
    
    var pauseButton: SKSpriteNode = SKSpriteNode(imageNamed: "pause")
    
    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        view.backgroundColor = UIColor.black
        
        let blockSize = viewWidth / 28
        grid = Grid(blockSize:blockSize, rows:gridRows, cols:gridCols, renderGrid: shouldRenderGrid)
        grid.addChild(apple)
        grid.position = CGPointMake (CGRectGetMidX(view.frame),CGRectGetMidY(view.frame))
        addChild(grid)
        
        gameOver.text = "GAME OVER"
        gameOver.textColor = UIColor.white
        gameOver.frame = CGRect(x: viewWidth / 2 - 50, y: 20, width: 100, height: 30)
        gameOver.textAlignment = NSTextAlignment.center
        gameOver.alpha = 0
        self.view!.addSubview(gameOver)
        

        // initis for snakehead
        snakeHead.position = grid.gridPosition(row: 3, col: 5)
        snakeHead.row = 3
        snakeHead.col = 5
        grid.addChild(snakeHead)
        
        // set the first move for snakeHead
        snakeHead.nextMove = "right"
        mySnake.append(snakeHead)
        
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: Selector("respondToSwipeGesture:"))
            gesture.direction = direction
            view.addGestureRecognizer(gesture)
        }
        
        let snakeBody = Body(imageNamed: "snakebody")
        snakeBody.row = snakeHead.row - 1
        snakeBody.col = snakeHead.col
        snakeBody.position = grid.gridPosition(row: snakeBody.row, col: snakeBody.col)
        snakeBody.nextPos = grid.gridPosition(row: snakeBody.row + 1, col: snakeBody.col)
        grid.addChild(snakeBody)
        
        mySnake.append(snakeBody)
        generateFruit()
        // our "tick"
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        }
   
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                if snakeHead.curMove != "left"{
                    snakeHead.nextMove = "right"
                }
            case UISwipeGestureRecognizer.Direction.down:
                if snakeHead.curMove != "up" {
                    snakeHead.nextMove = "down"
                }
            case UISwipeGestureRecognizer.Direction.left:
                if snakeHead.curMove != "right" {
                    snakeHead.nextMove = "left"
                }
            case UISwipeGestureRecognizer.Direction.up:
                if snakeHead.curMove != "down" {
                    snakeHead.nextMove = "up"
                }
            default:
                break // should never get here.
            }
        }
    }
    
    func generateFruit(){
        let row = Int(arc4random_uniform(UInt32(gridRows-1)) + 1)
        let col = Int(arc4random_uniform(UInt32(gridCols-1)) + 1)
        apple.position = grid.gridPosition(row: row, col: col)
        apple.row = row
        apple.col = col
    }
    
    func appendBody(){
        let lastBody = mySnake.last
        let newBody = Body(imageNamed: "snakebody")
        newBody.position = lastBody!.position
        newBody.row = lastBody!.row
        newBody.col = lastBody!.col
        newBody.nextPos = grid.gridPosition(row: newBody.row, col: newBody.col)
        mySnake.append(newBody)
        grid.addChild(newBody)
        
    }
    
    func ripSnake() {
        self.view?.isPaused = true
        UIView.animate(withDuration: 2) { () -> Void in
            self.gameOver.alpha = 1
        }

    }
    
    
    func tick() {
        
        switch(snakeHead.nextMove){
        case "right":
            snakeHead.col += 1
            snakeHead.curMove = "right"
            snakeHead.run(SKAction.rotate(toAngle: CGFloat(M_PI * 1.5), duration: 0.1, shortestUnitArc: true))
            break
        case "down":
            snakeHead.row += 1
            snakeHead.curMove = "down"
            snakeHead.run(SKAction.rotate(toAngle: CGFloat(M_PI), duration: 0.1, shortestUnitArc: true))
            break
        case "left":
            snakeHead.col -= 1
            snakeHead.curMove = "left"
            snakeHead.run(SKAction.rotate(toAngle: CGFloat(M_PI/2.0), duration: 0.1, shortestUnitArc: true))
            break
        case "up":
            snakeHead.row -= 1
            snakeHead.curMove = "up"
            snakeHead.run(SKAction.rotate(toAngle: CGFloat(0), duration: 0.1, shortestUnitArc: true))
            break
        default:
            break
        }
        
        
        snakeHead.jumped = false
        
        if snakeHead.col == gridCols{
            snakeHead.col = 0
            snakeHead.jumped = true
            
        } else if snakeHead.col < 0{
            snakeHead.col = gridCols - 1
            snakeHead.jumped = true
        }
        if snakeHead.row == gridRows{
            snakeHead.row = 0
            snakeHead.jumped = true
            
        } else if snakeHead.row < 0{
            snakeHead.row = gridRows - 1
            snakeHead.jumped = true
        }
        
        if snakeHead.row == apple.row && snakeHead.col == apple.col{
            generateFruit()
            appendBody()
        }
        
        let moveDuration: Double = snakeHead.jumped ? 0 : 0.1
        
        snakeHead.nextPos = grid.gridPosition(row: snakeHead.getRow(), col: snakeHead.getCol()) // update the pos
        snakeHead.run(SKAction.move(to: snakeHead.nextPos, duration: moveDuration))
        
        for i in (1...mySnake.count-1).reversed() { // start from the tail

            let snakeToFollow = mySnake[i-1]
            let snakeToMove = mySnake[i]
            let moveDuration: Double = snakeToMove.jumped ? 0 : 0.1
            
            snakeToMove.run(SKAction.move(to: snakeToMove.nextPos, duration: moveDuration))
            if snakeHead.row == snakeToMove.row && snakeHead.col == snakeToMove.col{
                ripSnake()
            }
            snakeToMove.nextPos = grid.gridPosition(row: snakeToFollow.row, col: snakeToFollow.col)
            snakeToMove.row = snakeToFollow.row
            snakeToMove.col = snakeToFollow.col
            snakeToMove.jumped = snakeToFollow.jumped
        }
        
    
        
    }

}

