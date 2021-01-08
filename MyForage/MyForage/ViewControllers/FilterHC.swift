//
//  FilterHC.swift
//  MyForage
//
//  Created by Cora Jacobson on 1/7/21.
//

import SwiftUI

class FilterHC<SwiftView: View>: UIHostingController<SwiftView> {

    weak var coordinator: MainCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(coordinator: MainCoordinator, contentView: SwiftView) {
        self.coordinator = coordinator
        super.init(rootView: contentView)
        view.backgroundColor = .clear
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
