//
//  ModelActivity.swift
//  PVModel
//
//  Created by Pablo Antonio Scacchi Bernasconi on 23/03/2019.
//  Copyright © 2019 Pablo Antonio Scacchi Bernasconi. All rights reserved.
//

import Foundation

import UIKit

class ModelViewController : UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    public var clock:Clock = Clock()
    override func viewDidLoad() {
        let render = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let img = render.image { ctx in
            let rectangle = CGRect(x: 100, y: 100, width: 200, height: 200)
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        self.imageView!.image = img
    }
}
