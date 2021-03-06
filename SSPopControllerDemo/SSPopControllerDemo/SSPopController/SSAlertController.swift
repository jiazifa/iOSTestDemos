//
//  SSAlertController.swift
//  SSPopControllerDemo
//
//  Created by Mac on 17/3/10.
//  Copyright © 2017年 treee. All rights reserved.
//

import Foundation
import UIKit

struct ScreenSize {
    private static let screenBounds = UIScreen.main.bounds
    static let width = ScreenSize.screenBounds.width
    static let height = ScreenSize.screenBounds.height
}

enum SSAlertControllerStyle {
    case action
    case systemAlert
    case custom
}

class SSAlertController: UIViewController {
    //MARK:-
    //MARK:properties
    var style:SSAlertControllerStyle!
    var dismissStyle:SSAlertDismissAnimatorType = .slideDown
    var presentStyle:SSAlertPresentAnimatorType = .bounce
    
    public var contentView:SSAlertBaseView = {
        return SSAlertBaseView()
    }()
    
    public var canTapToDismiss:Bool {
        set {
            //UNDO:set can tap back
            print("\(newValue)")
            if newValue == false {
                backgroundView.removeGestureRecognizer(gesture)
            }else {
                backgroundView.addGestureRecognizer(gesture)
            }
        }
        get {
            if let gestures:[UIGestureRecognizer] = backgroundView.gestureRecognizers {
                for ges in gestures {
                    if ges.isEqual(gesture) {
                        return true
                    }
                }
                return false
            }
            return false
        }
    }
    
    private lazy var gesture:UITapGestureRecognizer = {
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapToDismiss(_:)))
        return gesture
    }()
    public lazy var backgroundView:UIView = {
        let view:UIView = UIView.init(frame: self.view.bounds)
        view.backgroundColor = UIColor.black
        view.addGestureRecognizer(self.gesture)
        return view
    }()
    
    //MARK:-
    //MARK:lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        contentView.setupSuperViewContranints()
    }
    convenience init(_ title:String, message:String, alertStyle:SSAlertControllerStyle) {
        self.init()
        self.style = alertStyle
        
        //如果不添加这个视图，跳转完成之后会变成黑色
        switch alertStyle {
        case .action:
            contentView = SSActionView.init(title: title, message: message)
            self.presentStyle = .slideUp
            self.dismissStyle = .slideDown
            self.canTapToDismiss = true
            break
        case .systemAlert:
            contentView = SSAlertSystemView.init(title: title, message: message)
            self.presentStyle = .bounce
            self.dismissStyle = .fadeOut
            self.canTapToDismiss = false
            break
        default:
            contentView = SSAlertBaseView.init(title: title, message: message)
            break
        }
        
        contentView.alertController = self
        /**
         要在初始化的时候就添加视图才行。否则就迟了！
         */
        setupViews()
    }
    //MARK:-
    //MARK:public
    
    
    //MARK:-
    //MARK:private
    private func initialize() {
        transitioningDelegate = self
        modalPresentationStyle = .custom
        view.backgroundColor = UIColor.clear
    }
    
    func setupViews() {
        view.addSubview(backgroundView)
        view.sendSubview(toBack: backgroundView)
        setupBackgroundViewContraints()
        view.addSubview(contentView)
        view.bringSubview(toFront: contentView)
        setupContentViewContranints()
    }
    
    func setupBackgroundViewContraints() -> Void {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: backgroundView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint.init(item: backgroundView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint.init(item: backgroundView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint.init(item: backgroundView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    func setupContentViewContranints() -> Void {
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension SSAlertController {
    func tapToDismiss(_ tap:UITapGestureRecognizer) -> Void {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SSAlertController:UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SSAlertDismissAnimator.init(self.dismissStyle)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SSAlertPresentAnimator.init(self.presentStyle)
    }
}
