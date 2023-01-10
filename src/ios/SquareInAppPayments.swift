//
//  SquareInAppPayments.swift
//
//  Created by Andre Grillo on 04/01/2023.
//  Copyright © 2023 OutSystems. All rights reserved.
//

import Foundation
import SquareInAppPaymentsSDK

class SquareInAppPayments: CDVPlugin, SQIPCardEntryViewControllerDelegate {

    var command = CDVInvokedUrlCommand()
    var pluginResult = CDVPluginResult()
    
    @objc(payWithCard:)
    func payWithCard(_ command: CDVInvokedUrlCommand){
        self.command = command
        let vc = self.makeCardEntryViewController()
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController.present(nc, animated: true, completion: nil)
        }
    }
    
    func makeCardEntryViewController() -> SQIPCardEntryViewController {
        // Customize the card payment form
        let theme = SQIPTheme()
        theme.errorColor = .red
        theme.tintColor = UIColor.green //Color.primaryAction
        theme.keyboardAppearance = .light
        theme.messageColor = UIColor.black //Color.descriptionFont
        theme.saveButtonTitle = "Pay"

        return SQIPCardEntryViewController(theme: theme)
    }
    
    func sendPluginResult(status: CDVCommandStatus, message: String) {
        self.pluginResult = CDVPluginResult(status: status, messageAs: message)
        self.commandDelegate!.send(self.pluginResult, callbackId: self.command.callbackId)
    }
    
}

//SQIPCardEntryViewControllerDelegate Methods
extension SquareInAppPayments {
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didObtain cardDetails: SQIPCardDetails, completionHandler: @escaping (Error?) -> Void) {
        print("⭐️ didObtain cardDetails ⭐️")
        
        // Send card nonce to your server to store or charge the card.
        // When a response is received, call completionHandler with `nil` for success,
        // or an error to indicate failure.
        
        self.viewController.dismiss(animated: true) {
            
            var returnArray: Array<String> = []
            returnArray.append("Token: \(cardDetails.nonce)")
            returnArray.append("expirationMonth: \(cardDetails.card.expirationMonth)")
            returnArray.append("expirationYear: \(cardDetails.card.expirationYear)")
            returnArray.append("lastFourDigits: \(cardDetails.card.lastFourDigits)")
            returnArray.append("description: \(cardDetails.card.description)")
            
            self.sendPluginResult(status: CDVCommandStatus_OK, message: "\(returnArray)")
        }
        
    }
    
//    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didObtain cardDetails: SQIPCardDetails) async throws {
//
//    }
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
        print("⭐️ didCompleteWith status")
        //  Handle backend results. If your backend processes the card with no error, call the completion handler with a single nil argument. A success animation is shown to the buyer and cardEntryViewController:didCompleteWithStatus: is called. At this point, you should dismiss the card entry view controller.
        
        DispatchQueue.main.async { [weak self] in
            cardEntryViewController.dismiss(animated: true) {
                switch status {
                case .canceled:
                    //Devolver callback
                    print("⭐️ Cancelled")
                    self?.sendPluginResult(status: CDVCommandStatus_ERROR, message: "User Cancelled")
                    break
                case .success:
                    print("⭐️ Success")
                    self?.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Unknown SDK Error")
                }
            }
        }
        
    }
    
    
}