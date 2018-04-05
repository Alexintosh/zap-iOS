//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, ContainerViewController {
    // swiftlint:disable:next private_outlet
    @IBOutlet weak var container: UIView?
    
    let viewModel = ViewModel()
    
    weak var currentViewController: UIViewController?
    
    private var mainViewController: MainViewController {
        let mainViewController = Storyboard.main.instantiate(viewController: MainViewController.self)
        mainViewController.viewModel = viewModel
        return mainViewController
    }
    
    private var pinViewController: PinViewController {
        return Storyboard.numericKeyPad.initial(viewController: PinViewController.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialViewController(mainViewController)
    }
}