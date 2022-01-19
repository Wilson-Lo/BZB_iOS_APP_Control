//
//  OpeningViewController.swift
//  BZB_Project
//
//  Created by GoMax on 2021/12/13.
//

import Foundation
import UIKit
import Lottie

class OpeningViewController: UIViewController{
    
    @IBOutlet var mainView: UIView!
    var animationView: AnimationView!
    
    override func viewDidLoad() {
        print("OpeningViewController-viewDidLoad")
        super.viewDidLoad()
      
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        print("OpeningViewController-width = ",screenWidth)
        animationView = AnimationView(name: "pad")
        animationView.frame = CGRect(x: 50, y: 0, width: screenWidth * 1 , height: screenHeight * 0.4)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        mainView.addSubview(animationView)
        animationView.play( fromProgress: animationView.currentProgress,
                            toProgress: 1,
                            loopMode: .playOnce,
                            completion: { [weak self] completed in
                                print("Animation Finish !")
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: UINavigationController.typeName) as! UINavigationController
                                vc.modalPresentationStyle = .custom
                                self!.present(vc, animated: true, completion: nil)
                            })
    }
    

}
