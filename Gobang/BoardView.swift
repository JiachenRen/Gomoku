//
//  BoardView.swift
//  Gobang
//
//  Created by Jiachen Ren on 8/7/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

public typealias Coordinate = (col: Int, row: Int)

@IBDesignable class BoardView: UIView {
    
    @IBInspectable var boardColor: UIColor = UIColor.orange
    @IBInspectable var cornerOffset: CGFloat = 10
    @IBInspectable var gridLineWidth: CGFloat = 1
    @IBInspectable var gridColor: UIColor = UIColor.black
    @IBInspectable var vertexRadius: CGFloat = 3
    @IBInspectable var vertexColor: UIColor = UIColor.black
    @IBInspectable var verticesVisible: Bool = true
    @IBInspectable var blackPieceColor: UIColor = UIColor.black
    @IBInspectable var whitePieceColor: UIColor = UIColor.white
    @IBInspectable var pieceScale: CGFloat = 0.9
    
    //this should only apply when using standard board
    static var vertices: [Coordinate] = {
       return [(3, 3), (15, 3), (3, 15), (15, 15), (9, 9), (9, 15), (15, 9), (9, 3), (3, 9)]
    }()
    
    var dummyPiece: (Piece, CGPoint)? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var pieces: [[Piece?]]? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var board: Board {
        return Board.sharedInstance
    }
    
    var pieceRadius: CGFloat {
        return gap / 2 * pieceScale
    }
    
    var dimension: Int = 19 { //since the rows and cols of the board are always going to be the same.
        didSet {
            //do stuff to update dimension of the view.
            self.setNeedsDisplay()
        }
    }
    
    var boardWidth: CGFloat {
        return self.bounds.width - cornerOffset * 2
    }
    
    var gap: CGFloat {
        return boardWidth / CGFloat(dimension - 1)
    }
    
    var context: CGContext {
        return UIGraphicsGetCurrentContext()!
    }
    
    var highlightedCoordinates: [Coordinate]?
    
    func reloadBoardSettings() {
        if retrieveFromUserDefualt(key: "boardAttrsInitialized") == nil {
            saveToUserDefault(obj: board.dimension, key: "dimension")
            saveToUserDefault(obj: Float(pieceScale), key: "radius")
            saveToUserDefault(obj: Float(cornerOffset), key: "margin")
            saveToUserDefault(obj: true, key: "boardAttrsInitialized")
        }
        cornerOffset = CGFloat(retrieveFromUserDefualt(key: "margin") as! Float)
        pieceScale = CGFloat(retrieveFromUserDefualt(key: "radius") as! Float)
        let updatedDim = retrieveFromUserDefualt(key: "dimension") as! Int
        if board.dimension != updatedDim { //took me a while to find this bug
            board.dimension = updatedDim
            self.dimension = board.dimension
        }
        self.setNeedsDisplay()
    }
    
    func highlightMostRecentPiece() {
        if board.lastMoves.count == 0 {return}
        let move = board.lastMoves[board.lastMoves.count - 1]
        let pos = self.onScreen(move)
        
        //get the path for drawing a triangle and configers its graphics settings
        let path = pathForPolygon(radius: pieceRadius / 1.5, sides: 3)
        path.lineWidth = pieceRadius / 8
        path.lineJoinStyle = .round
        
        //determine the highlight color according to the color of the piece
        let color = board.pieces[move.row][move.col] == .black ? UIColor.green : UIColor.red
        color.setStroke()
        
        //draw the triangle
        context.saveGState()
        context.translateBy(x: pos.x, y: pos.y)
        context.rotate(by: -CGFloat.pi / 6)
        path.stroke()
        context.restoreGState()
        
    }
    
    private func pathForPolygon(radius: CGFloat, sides: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let step = CGFloat.pi * 2 / CGFloat(sides)
        path.move(to: Vec2D(x: cos(step), y: sin(step)).setMag(radius).cgPoint)
        for i in 1...(sides-1) {
            let angle = step * CGFloat(i + 1)
            let pointer = Vec2D(x: cos(angle), y: sin(angle))
                .setMag(radius).cgPoint
            path.addLine(to: pointer)
        }
        path.close()
        return path
    }
    
    override func draw(_ rect: CGRect) {
        //draws the background for the board
        boardColor.setFill()
        UIBezierPath(rect: bounds).fill()
        
        //draw the grid
        gridColor.setStroke()
        pathForGrid().stroke()
//        let w = bounds.width - cornerOffset * 2
//        context.stroke(CGRect(origin: CGPoint(x: cornerOffset, y: cornerOffset), size: CGSize(width: w, height: w)), width: 3)
        
        //draw the vertices, 19 for standard board
        if verticesVisible && dimension == 19 {
            self.drawVertices()
        }
        
        //draw pieces
        drawPieces()
        
        //highlight selected pieces
        highlightPieces()
        
        //display the digits overlay over the pieces according to the order in which they were placed onto the board
        displayOverlayDigits()
        
        //draw dummy piece to help place the piece
        drawDummyPiece()
        
        //highlight the piece that AI/Player just put down
        if !board.displayDigits {
            highlightMostRecentPiece()
        }
    }
    
    private func highlightPieces() {
        if let coordinates = self.highlightedCoordinates, coordinates.count > 0 {
            let co = coordinates[0]
            let color = board.pieces[co.row][co.col] == .black ? UIColor.green : UIColor.red
            color.withAlphaComponent(1).setStroke()
            coordinates.forEach { co in
                context.setLineWidth(pieceRadius / 8)
                context.strokeEllipse(in: CGRect(center: onScreen(co), size: CGSize(width: pieceRadius * 2, height: pieceRadius * 2)))
            }
        }
    }
    
    private func drawDummyPiece() {
        guard let (piece, pos) = self.dummyPiece else {
            return
        }
        let coordinate = onBoard(pos)
        if pieces?[coordinate.row][coordinate.col] != nil {
            return
        }
        let corrected = onScreen(coordinate)
        (piece == .black ? blackPieceColor : whitePieceColor).withAlphaComponent(0.5).setFill()
        CGContext.fillCircle(center: corrected, radius: pieceRadius)
    }
    
    private func pathForGrid() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: cornerOffset, y: cornerOffset))
        (0..<dimension).map{CGFloat($0)}.forEach{
            //draw the vertical lines
            path.move(to: CGPoint(x: cornerOffset + $0 * gap, y: cornerOffset))
            path.addLine(to: CGPoint(x: cornerOffset + $0 * gap, y: bounds.height - cornerOffset))
            
            //draw the horizontal lines
            path.move(to: CGPoint(x: cornerOffset, y: cornerOffset + $0 * gap))
            path.addLine(to: CGPoint(x: bounds.width - cornerOffset, y: cornerOffset + $0 * gap))
        }
        path.lineWidth = self.gridLineWidth
        path.lineCapStyle = .round
        return path
    }
    
    private func drawVertices() {
        self.vertexColor.setFill()
        BoardView.vertices.map{onScreen($0)}.forEach {
            CGContext.fillCircle(center: $0, radius: vertexRadius)
        }
    }
    
    private func drawPieces() {
        guard let pieces = self.pieces else {
            return
        }
        for row in 0..<pieces.count {
            for col in 0..<pieces[row].count {
                if let piece = pieces[row][col] {
                    switch piece {
                    case .black:
                        self.blackPieceColor.setFill()
//                        self.whitePieceColor.setStroke()
                    case .white:
                        self.whitePieceColor.setFill()
//                        self.blackPieceColor.setStroke()
                    }
                    let point = onScreen(Coordinate(col: col, row: row))
                    CGContext.fillCircle(center: point, radius: pieceRadius)
                    
//                    context.setLineWidth(1)
//                    let size = pieceRadius * 2
//                    context.strokeEllipse(in: CGRect(center: point, size: CGSize(width: size, height: size)))
                }
            }
        }
    }
    
    private func displayOverlayDigits() {
        if !board.displayDigits {return}
        for (num, piece) in board.lastMoves.enumerated() {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let isMostRecent = num == board.lastMoves.count - 1
            let attributes = [
                NSAttributedStringKey.paragraphStyle  : paragraphStyle,
                NSAttributedStringKey.font            : UIFont.systemFont(ofSize: pieceRadius),
                NSAttributedStringKey.foregroundColor : board.pieces[piece.row][piece.col] == .black ? isMostRecent ? UIColor.green : UIColor.white : isMostRecent ? UIColor.red : UIColor.black,
            ]
            
            let textRect = CGRect(center: onScreen(piece).translate(0, 0), size: CGSize(width: 50, height: pieceRadius))
            let attrString = NSAttributedString(string: "\(num + 1)", attributes: attributes)
            attrString.draw(in: textRect)
        }
    }
    
    
    private func onScreen(_ coordinate: Coordinate) -> CGPoint {
        return CGPoint(
            x: cornerOffset + CGFloat(coordinate.col) * gap,
            y: cornerOffset + CGFloat(coordinate.row) * gap
        )
    }
    
    public func onBoard(_ onScreen: CGPoint) -> Coordinate {
        func convert(_ n: CGFloat) -> Int {
            return Int((n - cornerOffset) / gap + 0.5)
        }
        return (convert(onScreen.x), convert(onScreen.y))
    }

}


