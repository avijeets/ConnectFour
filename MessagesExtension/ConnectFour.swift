//
//  ConnectFour.swift
//  ConnectFour
//
//  Created by Amar Ramachandran on 6/23/16.
//  Copyright © 2016 amarjayr. All rights reserved.
//

import Foundation
import Messages

enum CFCellState: CustomStringConvertible {
    case empty
    case occupied(CFPlayer)
    
    var description: String {
        switch self {
        case empty:
            return "empty"
        case occupied(let player):
            return player.description
        }
    }
}

struct CFPlayer: CustomStringConvertible {
    var uuid: String!
    var color: UIColor!
    
    var description: String {
        return uuid! + ":/:" + color.hexString(includeAlpha: false)
    }
}

extension CFPlayer: Hashable {
    var hashValue: Int {
        return self.uuid.hashValue
    }
}

extension CFPlayer: Equatable {}

func == (lhs: CFPlayer, rhs: CFPlayer) -> Bool {
    return lhs.uuid == rhs.uuid
}

enum CFError: ErrorProtocol, CustomStringConvertible {
    case rowFull
    case notPlayerTurn
    case gameDone
    
    var description: String {
        switch self {
        case .rowFull:
            return "The current row is full."
        case .notPlayerTurn:
            return "Not current player's turn."
        case .gameDone:
            return "The game is over."
        }
    }
}

class ConnectFour {
    private var grid: [[CFCellState]]!
    
    let player: CFPlayer!
    let opponent: CFPlayer!
    var players: [CFPlayer] {
        return [player, opponent]
    }
    
    var size: (columns: Int, rows: Int) {
        return (grid.count, grid[0].count)
    }
    
    var winner: CFPlayer? {
        return checkWinner() ?? nil
    }
    
    subscript(column: Int, row: Int) -> CFCellState {
        get {
            return grid[column][row]
        }
    }
    
    var requiredInRow: Int = 4
    
    // MARK: Initializers
    
    init(player: CFPlayer, opponent: CFPlayer, columns: Int = 7, rows: Int = 6) {
        self.player = player
        self.opponent = opponent
        
        grid = Array(repeatElement(Array(repeatElement(CFCellState.empty, count: rows)), count: columns))
    }
    
    private init(player: CFPlayer, opponent: CFPlayer, board: [[CFCellState]]) {
        self.player = player
        self.opponent = opponent
        
        grid = board
    }
    
    // MARK: Board manipulation
    
    func drop(in column: Int) throws -> (column: Int, row: Int) {
        guard column < size.columns && column >= 0 else {
            fatalError("Coordinates not on grid")
        }
        
        guard winner == nil else {
            throw CFError.gameDone
        }
        
        guard moveCount(for: player) <= moveCount(for: opponent) else {
            throw CFError.notPlayerTurn
        }
        
        do {
            let coordinates = try firstAvailableSpot(in: column)
            
            grid[coordinates.column][coordinates.row] = CFCellState.occupied(player)
            
            print(grid.description);
            
            return coordinates
        } catch CFError.rowFull {
            throw CFError.rowFull
        }
    }
    
    private func firstAvailableSpot(in column: Int) throws -> (column: Int, row: Int) {
        for i in 0..<size.rows {
            if case .empty = self[column, (size.rows-1)-i] {
                return (column, (size.rows-1)-i)
            }
        }
        
        throw CFError.rowFull
    }
    
    // MARK: Winning/Gameover handling
    
    func checkWinner() -> CFPlayer? {
        return checkDiagonals() ?? checkAntidiagonals() ?? checkRows(for: grid) ?? checkColumns()
    }
    
    private func checkDiagonals() -> CFPlayer? {
        var newGrid: [[CFCellState]] = grid
        for i in 0..<grid.count {
            newGrid[i].insert(contentsOf: Array(repeatElement(CFCellState.empty, count: ((size.columns-1)-i))), at: 0)
            let length = newGrid[i].count
            newGrid[i] += Array(repeatElement(CFCellState.empty, count: ((2*size.columns - 1) - length)))
        }
        
        return checkRows(for: newGrid)
    }
    
    private func checkAntidiagonals() -> CFPlayer? {
        var newGrid: [[CFCellState]] = grid
        for i in 0..<grid.count {
            newGrid[i].insert(contentsOf: Array(repeatElement(CFCellState.empty, count: i)), at: 0)
            let length = newGrid[i].count
            newGrid[i] += Array(repeatElement(CFCellState.empty, count: ((2*size.columns - 1) - length)))
        }
        
        return checkRows(for: newGrid)
    }
    
    private func checkColumns() -> CFPlayer? {
        var owned = [CFPlayer: [Int]]()
        
        for player in players {
            owned[player] =  Array(repeating: 0, count: size.columns)
        }
        
        for i in 0..<grid.count {
            for j in 0..<grid[0].count {
                var occupiedBy: CFPlayer?
                if case .occupied(let user) = grid[i][j] {
                    owned[user]![i] += 1
                    occupiedBy = user
                }
                
                for (player, array) in owned {
                    for numberOwned in array {
                        if numberOwned == requiredInRow {
                            return player
                        }
                    }
                    
                    if occupiedBy == nil {
                        owned[player]![i] = 0
                    } else if player != occupiedBy {
                        owned[player]![i] = 0
                    }
                }
                
            }
        }
        
        return nil
    }
    
    private func checkRows(for grid: [[CFCellState]]) -> CFPlayer? {
        var owned = [CFPlayer: [Int]]()
        
        for player in players {
            owned[player] =  Array(repeating: 0, count: size.columns)
        }
        
        for i in 0..<size.columns {
            for j in 0..<size.rows {
                var occupiedBy: CFPlayer?
                if case .occupied(let user) = grid[i][j] {
                    owned[user]![j] += 1
                    occupiedBy = user
                }
                
                for (player, array) in owned {
                    for numberOwned in array {
                        if numberOwned == requiredInRow {
                            return player
                        }
                    }
                    
                    if occupiedBy == nil {
                        owned[player]![j] = 0
                    } else if player != occupiedBy {
                        owned[player]![j] = 0
                    }
                }
                
            }
        }
        
        return nil
    }
    
    // MARK: Utility
    
    func moveCount(for player: CFPlayer?) -> Int {
        guard player == self.player || player == opponent else {
            fatalError("Player not part of game.")
        }
        
        return grid.flatMap { $0 }.filter { (element) -> Bool in
            if case .occupied(let user) = element {
                return user == player
            }
            return false
            }.count
    }
    
    func containsUserWith(uuid user: String) -> Bool {
        return player.uuid == user || opponent.uuid == user
    }
}

extension ConnectFour {
    func boardToJSON() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: grid.map({ (value: [CFCellState]) -> [String] in
                var array = [String]()
                for i in 0..<value.count {
                    array.append(String(value[i]))
                }
                
                return array
            }), options: .prettyPrinted)
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            return nil
        }
    }
    
    static func boardFrom(json string: String) -> [[CFCellState]]? {
        print(string)
        if let data = string.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String]]
                let grid = json!
                
                var returnGrid = Array(repeatElement(Array(repeatElement(CFCellState.empty, count: grid[0].count)), count: grid.count))
                
                for i in 0..<grid.count {
                    for j in 0..<grid[0].count {
                        if grid[i][j] != "empty" {
                            var elComponents = grid[i][j].components(separatedBy: ":/:")
                            
                            returnGrid[i][j] = CFCellState.occupied( CFPlayer(uuid: elComponents[0], color: UIColor(hex: elComponents[1])))
                        } else {
                            returnGrid[i][j] = CFCellState.empty
                        }
                    }
                }
                
                print(returnGrid.description)
                
                return returnGrid
            } catch let error as NSError {
                fatalError("JSON PARSING ERROR: " + error.description)
            }
        } else {
            fatalError("boardFrom, unkown error")
        }
    }
    
    static func userFrom(string: String) -> CFPlayer {
        return CFPlayer(uuid: string.components(separatedBy: ":/:")[0], color: UIColor(hex: string.components(separatedBy: ":/:")[1]))
    }
}

extension ConnectFour {
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: "Player", value: player.description))
        items.append(URLQueryItem(name: "Opponent", value: opponent.description))
        items.append(URLQueryItem(name: "Board", value: boardToJSON()))
        
        return items
    }
    
    convenience init?(queryItems: [URLQueryItem]) {
        self.init(player: ConnectFour.userFrom(string: queryItems[1].value!), opponent: ConnectFour.userFrom(string: queryItems[0].value!), board: ConnectFour.boardFrom(json: queryItems[2].value!)!)
    }
}

extension ConnectFour {
    convenience init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else { return nil }
        
        self.init(queryItems: queryItems)
    }
}


extension ConnectFour: Equatable {}

func == (lhs: ConnectFour, rhs: ConnectFour) -> Bool {
    return lhs.player == rhs.player && lhs.opponent == rhs.opponent && lhs.boardToJSON() == rhs.boardToJSON()
}
