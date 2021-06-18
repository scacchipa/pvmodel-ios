import Foundation
import UIKit

class TabSelectorViewController: UIViewController {
    @IBOutlet weak var pvButton: UIButton!
    @IBOutlet weak var vtButton: UIButton!
    @IBOutlet weak var ptButton: UIButton!
    @IBOutlet weak var contrButton: UIButton!
    
    var buttonArray: [UIButton] = []
    
    override func viewDidLoad() {
        buttonArray = [pvButton, vtButton, ptButton, contrButton]
        
        forAllButtons(
            selectedButton: pvButton,
            trueScript: { button in button.isSelected = true },
            falseScript: { button in button.isSelected = false })
        
        pvButton.addTarget(self, action: #selector(buttonWasPushed), for: UIControl.Event.touchUpInside)
        vtButton.addTarget(self, action: #selector(buttonWasPushed), for: UIControl.Event.touchUpInside)
        ptButton.addTarget(self, action: #selector(buttonWasPushed), for: UIControl.Event.touchUpInside)
        contrButton.addTarget(self, action: #selector(buttonWasPushed), for: UIControl.Event.touchUpInside)
    }
    private func forAllButtons(selectedButton: UIButton, trueScript: (UIButton)->(), falseScript: (UIButton)->()) {
        for idx in 0..<buttonArray.count {
            let button = buttonArray[idx]
            if (button == selectedButton) {
                trueScript(button)
            } else {
                falseScript(button)
            }
        }
    }
    private func toSelectOnlyAButton(_ selButton: UIButton) {
        if !selButton.isSelected {
            forAllButtons(
                selectedButton: selButton,
                trueScript: { button in button.isSelected = true },
                falseScript: { button in button.isSelected = false})
        }
    }
    @objc func buttonWasPushed(control: UIButton, withEvent event: UIEvent) {
        toSelectOnlyAButton(control)
    }
}
