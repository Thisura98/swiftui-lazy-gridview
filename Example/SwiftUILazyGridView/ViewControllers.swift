//
//  ViewController.swift
//  SwiftUILazyGridView
//
//  Created by thisura1998@gmail.com on 10/24/2020.
//  Copyright (c) 2020 thisura1998@gmail.com. All rights reserved.
//

import UIKit
import SwiftUI
import SwiftUILazyGridView

class NavController: UINavigationController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSwiftUIView()
    }
    
    private func showSwiftUIView(){
        let appView = AppView()
        let instance = ViewController(rootView: appView)
        
        setViewControllers([instance], animated: true)
    }
    
}

class ViewController: UIHostingController<AppView> {

}

struct AppView: View{
    
    var body: some View{
        LazyGridView()
    }
    
}
