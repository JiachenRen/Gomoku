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
       return [(4, 4), (14, 4), (4, 14), (14, 14), (9, 9), (9, 14), (14, 9), (9, 4), (4, 9)]
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
    
    override func draw(_ rect: CGRect) {
        //draws the background for the board
        boardColor.setFill()
        UIBezierPath(rect: bounds).fill()
        
        //draw the grid
        gridColor.setStroke()
        pathForGrid().stroke()
        
        //draw the vertices, 19 for standard board
        if verticesVisible && dimension == 19 {
            self.drawVertices()
        }
        
        //draw pieces
        drawPieces()
        
        //draw dummy piece to help place the piece
        drawDummyPiece()
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
                    case .black: self.blackPieceColor.setFill()
                    case .white: self.whitePieceColor.setFill()
                    }
                    CGContext.fillCircle(center: onScreen((col, row)), radius: pieceRadius)
                }
            }
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
