//
//  SquareInAppPayments.swift
//
//  Created by Andre Grillo on 04/01/2023.
//  Copyright © 2023 OutSystems. All rights reserved.
//

import Foundation
import SquareInAppPaymentsSDK

@objc(SquareInAppPayments)
class SquareInAppPayments: CDVPlugin, SQIPCardEntryViewControllerDelegate {

    var command = CDVInvokedUrlCommand()
    var pluginResult = CDVPluginResult()
    
    @objc(payWithCard:)
    func payWithCard(_ command: CDVInvokedUrlCommand){
        self.command = command
        if let vc = self.makeCardEntryViewController(arguments: command.arguments) {
            vc.delegate = self
            let nc = UINavigationController(rootViewController: vc)
            nc.modalPresentationStyle = .fullScreen
            
            DispatchQueue.main.async { [weak self] in
                self?.viewController.present(nc, animated: true, completion: nil)
            }
        } else {
            self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Invalid Parameters")
        }
    }
    
    func makeCardEntryViewController(arguments: Array<Any>) -> SQIPCardEntryViewController? {
        if arguments.count == 4 {
            if let buttonCaption = command.arguments[0] as? String, let tintHexColor = command.arguments[1] as? String, let messageHexColor = command.arguments[2] as? String, let errorHexColor = command.arguments[3] as? String  {
                if messageHexColor.isValidHexColor() && tintHexColor.isValidHexColor() && errorHexColor.isValidHexColor() {
                    if buttonCaption != "" {
                        // Customize the card payment form
                        let theme = SQIPTheme()
                        theme.errorColor = UIColor(hexaString: errorHexColor)
                        theme.tintColor = UIColor(hexaString: tintHexColor)
                        theme.keyboardAppearance = .light
                        theme.messageColor = UIColor(hexaString: messageHexColor)
                        theme.saveButtonTitle = buttonCaption

                        return SQIPCardEntryViewController(theme: theme)
                    } else {
                        self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Invalid Button string")
                    }
                    
                } else {
                    self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Invalid Hexcolor")
                }
            } else {
                self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Invalid Input Parameters")
            }

        } else {
            self.sendPluginResult(status: CDVCommandStatus_ERROR, message: "Error: Incorrect number of input parameters")
        }
        return nil
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
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
        print("⭐️ didCompleteWith status")
        
        DispatchQueue.main.async { [weak self] in
            cardEntryViewController.dismiss(animated: true) {
                switch status {
                case .canceled:
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


extension UIColor {
    convenience init(hexaString: String, alpha: CGFloat = 1) {
        let chars = Array(hexaString.dropFirst())
        self.init(red:   .init(strtoul(String(chars[0...1]),nil,16))/255,
                  green: .init(strtoul(String(chars[2...3]),nil,16))/255,
                  blue:  .init(strtoul(String(chars[4...5]),nil,16))/255,
                  alpha: alpha)}
}

extension String {
    func isValidHexColor() -> Bool {
        guard let regex = try? NSRegularExpression(pattern: "^#(?:[0-9a-fA-F]{3}){1,2}$") else {
            return false
        }
        let range = NSRange(location: 0, length: self.utf16.count)
        if regex.firstMatch(in: self, options: [], range: range) != nil {
            return true
        }
        return false
    }
}
