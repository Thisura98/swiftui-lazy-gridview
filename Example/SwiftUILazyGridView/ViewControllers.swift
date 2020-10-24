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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "LazyGridView Example"
    }
    
}

struct CustomObject{
    var id: Int
    var lateInitialized: Bool
    var text: String
}

struct AppView: View{
    
    private var viewModel = LazyGridViewModel<CustomObject, CustomObject>(UIScreen.main.bounds.width - 10.0, spacing: 0.0)
    
    init(){
        startLongRunningTask()
    }
    
    var body: some View{
        LazyGridView<CustomObject, CustomObject>(viewModel) { (input, callback) in
            // Do some fake processing on a background thread
            DispatchQueue.global().async {
                let randomDelay = arc4random_uniform(10000000)
                usleep(randomDelay)
                
                // Passthrough
                callback(input)
            }
            
        } _: { (post: CustomObject) -> AnyView in
            // View Builder
            return AnyView(ZStack(content: {
                Image("Example Image").resizable()
                Text(post.text)
                    .padding(EdgeInsets(top: 2.0, leading: 6.0, bottom: 2.0, trailing: 6.0))
                    .foregroundColor( post.lateInitialized ? Color.red : Color.yellow )
                    .background(Color.white)
                    .cornerRadius(8.0)
            }))
        } _: { (clickedItem) in
            guard let index = viewModel.getAllItems().firstIndex (where: { $0?.id == clickedItem?.id }) else { return }
            print("You clicked the item at index, \(index)")
            self.addRandomItem()
        }

    }
    
    /**
     Setup some items
     */
    private mutating func startLongRunningTask(){
        for i in 0..<30{
            viewModel.addItem(CustomObject(id: i, lateInitialized: false, text: "Initial"))
        }
    }
    
    /**
     Action when a Grid Item is clicked
     */
    private func addRandomItem(){
        let randomPos = Int(arc4random_uniform(UInt32(viewModel.getNumberOfItems())))
        viewModel.addItem(CustomObject(id: viewModel.getNumberOfItems(), lateInitialized: true, text: "On Click"), at: randomPos)
    }
    
    /*
     
     // Append items at fixed intervals
     
    class AppLogic{
        var structRef: AppView!
        var timer: Timer!
        
        init(_ structRef: AppView){
            self.structRef = structRef
            timer = Timer.scheduledTimer(
                timeInterval: 2.0,
                target: self,
                selector: #selector(timerTicked),
                userInfo: nil,
                repeats: true)
        }
        
        @objc private func timerTicked(){
            self.structRef.appendItemAtInterval()
        }
    }
    
    private mutating func startLongRunningTask(){
        self.appLogic = AppLogic(self)
    }
    
    private mutating func appendItemAtInterval(){
        viewModel.addItem("Some Item", at: 0)
    }*/
    
}
