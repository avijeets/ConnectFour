//
//  GameViewController.swift
//  ConnectFour
//
//  Created by Amar Ramachandran on 7/28/16.
//  Copyright © 2016 amarjayr. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    static let storyboardIdentifier = "GameViewController"

    @IBOutlet weak var gameView: UICollectionView!
    var game: ConnectFour! = nil
    
    weak var delegate: GameViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        gameView!.backgroundColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        gameView!.delegate = self
        gameView!.dataSource = self
        
        let layout = gameView!.collectionViewLayout as? UICollectionViewFlowLayout
        layout!.minimumInteritemSpacing = 10.0
        layout!.minimumLineSpacing = 17.0
        
        self.view.backgroundColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game.size.rows * game.size.columns;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameViewCell", for: indexPath);
        
        if case .occupied(let user) = game![Int(indexPath.row%(game?.size.columns)!), Int(floor(Double(indexPath.row/((game?.size.rows)!+1))))] {
            cell.contentView.backgroundColor = user.color
        } else {
            cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
            
            cell.layer.borderColor = #colorLiteral(red: 0.9607843137, green: 0.6980392157, blue: 0.3607843137, alpha: 1).cgColor
            cell.layer.borderWidth = 3
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        
        return CGSize(width: floor(collectionView.bounds.size.width / CGFloat(game!.size.columns))-layout!.minimumLineSpacing,
                      height: floor(collectionView.bounds.size.width / CGFloat(game!.size.rows))-layout!.minimumLineSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let column = Int(indexPath.row%(game?.size.columns)!)
        
        do {
            let location = try game.drop(in: column)
            let index = (game?.size.columns)! * location.row + location.column
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            
            delegate!.gameViewController(self, renderedImage: self.gameView!.createImage())
        } catch CFError.rowFull {
            print("Row Full")
        } catch CFError.notPlayerTurn {
            print("NOT PLAYER TURN")
        } catch CFError.gameDone {
            print("GAME IS DONE")
        } catch {
            print("unkown error")
        }

    }
}

protocol GameViewControllerDelegate: class {
    func gameViewController(_ controller: GameViewController, renderedImage: UIImage)
}

extension UIView {
    func createImage() -> UIImage {
        let rect: CGRect = self.frame
        
        UIGraphicsBeginImageContextWithOptions(rect.size, self.isOpaque, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
}
