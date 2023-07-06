//
//  Extensions.swift
//  loop
//
//  Created by Yecol Hsu on 12/10/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import PopupDialog
import pop
import QBImagePickerController
import UserNotifications

public extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
//    static func resizeWithImage(_ sourceImage: UIImage, toWidth: CGFloat) -> UIImage {
//        let rect: CGRect = CGRect(x: 0, y: 0, width: sourceImage.size.width, height: sourceImage.size.height)
//        let cgImage: CGImage = sourceImage.cgImage!.cropping(to: rect)!
//        return UIImage(cgImage: cgImage, scale: sourceImage.size.width / toWidth, orientation: sourceImage.imageOrientation)
//    }
    
//    func scaleImage(toSize newSize: CGSize) -> UIImage? {
//        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
//        if let context = UIGraphicsGetCurrentContext() {
//            context.interpolationQuality = .high
//            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
//            context.concatenate(flipVertical)
//            context.draw(self.cgImage!, in: newRect)
//            let newImage = UIImage(cgImage: context.makeImage()!)
//            UIGraphicsEndImageContext()
//            return newImage
//        }
//        return nil
//    }
//
    static func resizeWithImage(_ sourceImage: UIImage, toWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width;
        let scaleFactor = toWidth / oldWidth;

        let newHeight = sourceImage.size.height * scaleFactor;
        let newWidth = oldWidth * scaleFactor;

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight));
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!;
    }
    
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

public extension UIImageView {
    func asAvatar() {
        self.contentMode = .scaleAspectFill;
        self.layer.borderColor = CL_GREY_BORDER_6C.cgColor;
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true;
    }

    func asAvatar(size: CGFloat) {
        self.contentMode = .scaleAspectFill;
        self.layer.borderColor = CL_GREY_BORDER_6C.cgColor;
        self.layer.cornerRadius = size / 2;
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true;
    }
}

public extension UIButton {
    func asAvatar(size: CGFloat) {
        self.contentMode = .scaleAspectFill;
        self.layer.borderColor = CL_GREY_BORDER_6C.cgColor;
        self.layer.cornerRadius = size / 2;
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true;
    }
}


public extension UIView {
    func addShadow() {
        self.layer.shadowColor = CL_GREY_SHADOW.cgColor
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 4.0;
        self.layer.shadowOffset = CGSize(width: 0, height: 0);
        self.clipsToBounds = false;
    }
}

public extension UINavigationController {
    func setLoopThemeGreenNav() {
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = CL_GREEN_BG;
        self.navigationBar.isTranslucent = false;
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                  NSFontAttributeName: fontMontserrat16];
    }
}

public extension UIButton {

    func setLoopBtnGreenFramed(font: UIFont) {
        self.layer.borderColor = CL_GREEN_DEFAULT.cgColor;
        self.layer.cornerRadius = FL_CONNER_RADIUS;
        self.titleLabel?.font = font;
        self.setTitleColor(CL_GREEN_DEFAULT, for: UIControlState())
        self.layer.borderWidth = 1.0;
    }

    func setLoopBtnGreenBackgrounded(font: UIFont) {
        self.layer.borderColor = CL_GREEN_BG.cgColor;
        self.backgroundColor = CL_GREEN_BG;
        self.layer.cornerRadius = FL_CONNER_RADIUS;
        self.titleLabel?.font = font;
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.layer.borderWidth = 1.0;
    }

    func setLoopBtnWhiteFramed(font: UIFont) {
        self.layer.borderColor = UIColor.white.cgColor;
        self.layer.cornerRadius = FL_CONNER_RADIUS;
        self.titleLabel?.font = font;
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.layer.borderWidth = 1.0;
    }


    func initLoopThemeBtnWith(_ title: String) {
        let width = ceil(title.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: fontMontserrat14], context: nil).size.width) + 12;
        self.setTitle(title, for: UIControlState())

        let newFrame = CGRect(x: 0, y: 0, width: width, height: 25.0)
        self.frame = newFrame;
        self.layer.borderColor = CL_GREEN_DEFAULT.cgColor;
        self.layer.cornerRadius = FL_CONNER_RADIUS;
        self.titleLabel?.font = fontMontserrat14;
        self.setTitleColor(CL_GREEN_DEFAULT, for: UIControlState())
        self.setTitleColor(CL_GREEN_BG, for: .disabled)
        self.layer.borderWidth = 1.0;
    }

    func asImageTextBtn() {
        let imageSize: CGSize = self.imageView!.image!.size
        let labelString = NSString(string: self.titleLabel!.text!)
        let titleSize = labelString.size(attributes: [NSFontAttributeName: self.titleLabel!.font])

        self.imageEdgeInsets = UIEdgeInsetsMake((50 - imageSize.height) / 2, -30, 0, 0.0)
        self.titleEdgeInsets = UIEdgeInsetsMake((50 - titleSize.height) / 2 - 5, 10, 0.0, 0.0)
        self.contentEdgeInsets = UIEdgeInsetsMake(-10, 0.0, 0.0, 0.0)
    }
}

public extension UIViewController {

    func displayAlertView(_ info: String) {
        let alertView = UIAlertController(title: "Information", message: info, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }

    func filterError(_ error: Error?) -> Bool {
        if error != nil {
            displayAlertView(String(format: "filtered error:%@", error!.localizedDescription));
            print("filtered error:%@", error!)
            return false
        } else {
            return true
        }
    }

    func showProgress() {
        DispatchQueue.main.async(execute: {
            MBProgressHUD.showAdded(to: self.view, animated: true);
        })
    }
    
    
    func showLoadingProgress(){
        DispatchQueue.main.async(execute: {
            MBProgressHUD.showAdded(to: self.view, animated: true).label.text = "Loading...".localized;
        })
    }

    func hideProgress() {
        DispatchQueue.main.async(execute: {
            MBProgressHUD.hide(for: self.view, animated: true);
        })
    }


    func showComplete(with info: String) {
        DispatchQueue.main.async(execute: {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true);
            let image = UIImage(named: "checkmark")!.withRenderingMode(.alwaysTemplate);
            let imageView = UIImageView(image: image);
            hud.customView = imageView;
            hud.mode = .customView;
            hud.label.text = info;
            hud.hide(animated: true, afterDelay: 2.0);
        })
    }

    func showToast(with info: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)

        // Set the text mode to show only text.
        hud.mode = .text;
        hud.label.text = info;
        hud.offset = CGPoint(x: 0, y: 200);
        hud.hide(animated: true, afterDelay: 2.0)
    }

    internal func displayDialogBadgeBrief(badge: LPBadge) {

        let overlayAppearance = PopupDialogOverlayView.appearance()

        overlayAppearance.color = UIColor.black
        overlayAppearance.blurRadius = 20
        overlayAppearance.blurEnabled = true
        overlayAppearance.liveBlur = false
        overlayAppearance.opacity = 0.3

        let buttonCancel = CancelButton(title: "DISMISS") {
            print("DISMISS")
        }
        buttonCancel.titleFont = fontMontserrat14;
        buttonCancel.titleColor = CL_GREY_FONT;


        let buttonMore = DefaultButton(title: "DETAILS", dismissOnTap: true, action: {
            print("DETAILS")
            let badgeDetailController = BadgeController(badge: badge);
            self.navigationController?.pushViewController(badgeDetailController, animated: true);
        })

        buttonMore.titleColor = CL_GREEN_DEFAULT;
        buttonMore.titleFont = fontMontserrat14;


        let dialogBriefBadge = DialogBriefBadge();
        dialogBriefBadge.setData(badge: badge);

        let popDialog = PopupDialog(viewController: dialogBriefBadge, buttonAlignment: .horizontal, transitionStyle: .bounceUp, gestureDismissal: true);

        popDialog.addButtons([buttonCancel, buttonMore])
        popDialog.transitionStyle = .fadeIn

        // Present dialog
        self.present(popDialog, animated: true, completion: nil)
    }


    internal func displayBadgeCongrats(badgeId: String, grant type:BadgeGrantType) {

        DataModelManager.sharedInstance.cloudGetBadgeDetail(badgeId, block: { (object, error) in
            if (self.filterError(error)) {

                DispatchQueue.main.async(execute: {

                    let badge = object as! LPBadge;
                    let congratsVC = CongratsViewController()

                    congratsVC.bindData(badge, grantType: type);
                    let popDialog = PopupDialog(viewController: congratsVC, buttonAlignment: .horizontal, transitionStyle: .bounceUp, gestureDismissal: true);

                    let buttonCancel = CancelButton(title: "DISMISS") {
                        print("DISMISS")
                    }
                    buttonCancel.titleFont = fontMontserrat14;
                    buttonCancel.titleColor = CL_GREY_FONT;

                    let buttonMore = DefaultButton(title: "DETAILS", dismissOnTap: true, action: {
                        print("DETAILS")
                        let badgeDetailController = BadgeController(badge: badge);

                        if let navigationController = self as? UINavigationController {
                            navigationController.pushViewController(badgeDetailController, animated: true);
                        } else if let tabBarController = self as? MainTabBarController {
                            (tabBarController.selectedViewController as! UINavigationController).pushViewController(badgeDetailController, animated: true);
                        } else {
                            self.navigationController?.pushViewController(badgeDetailController, animated: true);
                        }
                    })

                    buttonMore.titleColor = CL_GREEN_DEFAULT;
                    buttonMore.titleFont = fontMontserrat14;

                    popDialog.addButtons([buttonCancel, buttonMore])
                    self.present(popDialog, animated: true, completion: nil)

                })
            }
        })
    }

}

extension UIView {

    /**
     Starts rotating the view around Z axis.
     
     @param duration Duration of one full 360 degrees rotation. One second is default.
     @param repeatCount How many times the spin should be done. If not provided, the view will spin forever.
     @param clockwise Direction of the rotation. Default is clockwise (true).
     */
    func startZRotation(duration: CFTimeInterval = 1, repeatCount: Float = Float.infinity, clockwise: Bool = true) {
        if self.layer.animation(forKey: "transform.rotation.z") != nil {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let direction = clockwise ? 1.0 : -1.0
        animation.toValue = NSNumber(value: Double.pi * 2 * direction)
        animation.duration = duration
        animation.isCumulative = true
        animation.repeatCount = repeatCount
        self.layer.add(animation, forKey: "transform.rotation.z")
    }


    /// Stop rotating the view around Z axis.
    func stopZRotation() {
        self.layer.removeAnimation(forKey: "transform.rotation.z")
    }

    func installShadowForFeaturedBadgeCell() {
        layer.borderColor = UIColor.darkGray.cgColor;
        layer.borderWidth = 0.5;
        layer.cornerRadius = 10
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 10)
        layer.shadowOpacity = 0.8
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowRadius = 5.0
    }

}

extension UIView {

    var screenShot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0);
        if let _ = UIGraphicsGetCurrentContext() {
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
}

extension QBImagePickerController {
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        UIApplication.shared.statusBarStyle = .default
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIApplication.shared.statusBarStyle = .lightContent
    }
}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "");
    }
}
