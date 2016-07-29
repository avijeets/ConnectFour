//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Amar Ramachandran on 6/23/16.
//  Copyright © 2016 amarjayr. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        
        // Present the view controller appropriate for the conversation and presentation style.
        presentViewController(for: conversation, with: presentationStyle)
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        
        // Present the view controller appropriate for the conversation and presentation style.
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }
        
        presentViewController(for: conversation, with: presentationStyle)
    }

    
    private func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        let game = ConnectFour(message: conversation.selectedMessage, current: conversation.localParticipantIdentifier.uuidString) ?? ConnectFour(player: CFPlayer(uuid: conversation.localParticipantIdentifier.uuidString, color: UIColor.random()), opponent: CFPlayer(uuid: conversation.remoteParticipantIdentifiers[0].uuidString, color: UIColor.random()), columns: 4, rows: 3);
    
        controller = instantiateGameViewController(with: game);
        
        // Remove any existing child controllers.
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Embed the new controller.
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)

    }

    private func instantiateGameViewController(with game: ConnectFour) -> UIViewController {
        // Instantiate a `BuildIceCreamViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: GameViewController.storyboardIdentifier) as? GameViewController else { fatalError("Unable to instantiate a GameViewController from the storyboard") }
        
        controller.game = game;
        controller.delegate = self
        
        return controller
    }
    
    // MARK: Convenience
    
    private func composeMessage(with game: ConnectFour, caption: String, image: UIImage, session: MSSession? = nil) -> MSMessage {
        var components = URLComponents()
        components.queryItems = game.queryItems
        
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = caption
        
        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
        message.layout = layout
        
        return message
    }
}

extension UIColor {
    static func random() -> UIColor {
        let randomRed: CGFloat = CGFloat(drand48())
        let randomGreen: CGFloat = CGFloat(drand48())
        let randomBlue: CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

extension MessagesViewController: GameViewControllerDelegate {
    func gameViewController(_ controller: GameViewController, renderedImage: UIImage) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        guard let game = controller.game else { fatalError("Expected the controller to be displaying a game") }
        
        let message = composeMessage(with: game, caption: NSLocalizedString("", comment: ""), image: renderedImage, session: conversation.selectedMessage?.session)
        
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }

        dismiss()
    }
}
