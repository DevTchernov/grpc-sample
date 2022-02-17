/*
 * Copyright 2019 IceRock MAG Inc. Use of this source code is governed by the Apache 2.0 license.
 */

import Foundation
import UIKit
import MultiPlatformLibrary
import MultiPlatformLibraryMvvm
import SkyFloatingLabelTextField

class ConfigViewController: UIViewController {
    @IBOutlet private var tokenField: SkyFloatingLabelTextField!
    @IBOutlet private var languageField: SkyFloatingLabelTextField!
    
    private var viewModel: ConfigViewModel!
    private var grpcTestViewModel: GrpcTestViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AppComponent.factory.configFactory.createConfigViewModel(eventsDispatcher: EventsDispatcher(listener: self))

        grpcTestViewModel = AppComponent.factory.grpcTestFactory.createViewModel(eventsDispatcher: EventsDispatcher(listener: self))
        
        // binding methods from https://github.com/icerockdev/moko-mvvm
        tokenField.bindTextTwoWay(liveData: viewModel.apiTokenField.data)
        tokenField.bindError(liveData: viewModel.apiTokenField.error)
        
        languageField.bindTextTwoWay(liveData: viewModel.languageField.data)
        languageField.bindError(liveData: viewModel.languageField.error)
    }
    
    @IBAction func onSubmitPressed() {
        viewModel.onSubmitPressed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        grpcTestViewModel.onMainButtonTap()
    }
    
    deinit {
        // clean viewmodel to stop all coroutines immediately
        viewModel.onCleared()
        grpcTestViewModel.onCleared()
    }
}

extension ConfigViewController: ConfigViewModelEventsListener {
    // callsed from ViewModel by EventsDispatcher - see https://github.com/icerockdev/moko-mvvm
    func routeToNews() {
        performSegue(withIdentifier: "routeToNews", sender: nil)
    }
}

extension ConfigViewController: GrpcTestViewModelEventsListener {
    func showMessage(message: String) {
        let alert = UIAlertController(title: "gRPC test", message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}
