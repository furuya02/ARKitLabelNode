//
//  ViewController.swift
//  ARKitLabelNode
//
//  Created by . SIN on 2017/10/24.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var recordingButton: RecordingButton!
    var labelNodes: [LabelNode] = []
    
    enum Mode {
        case none // 厚みなし
        case thickCharacters // 文字の厚みがある
        case thickPanel // 文字とパネルに厚みがある
    }
    var mode = Mode.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        
        // 録画ボタン
        self.recordingButton = RecordingButton(self)
        
        DispatchQueue.main.async {
            self.setMode()
        }
        
    }
    
    @IBAction func tapCleanButton(_ sender: Any) {
        
        for labelNode in labelNodes {
            labelNode.runAction(SCNAction.sequence([SCNAction.fadeOut(duration: 0.5), SCNAction.removeFromParentNode()]))
        }
        labelNodes = []
        
        DispatchQueue.main.async {
            self.setMode()
        }
    }

    func setMode()  {
        let actionSheet = UIAlertController(title: "mode", message: "select the mode to string panel.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "thickCharacters", style: .default) { _ in self.mode = .thickCharacters })
        actionSheet.addAction(UIAlertAction(title: "thickPanel", style: .default) { _ in self.mode = .thickPanel })
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel) {_ in })
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("tauch")
        guard let camera = sceneView.pointOfView else { return }
        
        // ラベルノードの生成
        let textThickness: CGFloat = (mode == .none) ? 0 : 0.1
        let panelThickness: CGFloat = (mode == .thickPanel) ? 0.1 : 0
        print("\(textThickness) \(panelThickness)")
        let textColor = UIColor.blue
        let panelColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.4)
        let width: CGFloat = 1
        let labelNode = LabelNode(text: "本日は晴天なり", width: width, textColor: textColor, panelColor: panelColor, textThickness: textThickness, panelThickness: panelThickness)
        
        let position = SCNVector3(x: 0, y: 0, z: -0.5) // ラベルノードの位置は、左右：0m 上下：0m　奥に50cm
        labelNode.position = camera.convertPosition(position, to: nil) // カメラ位置からの偏差に変換する
        labelNode.eulerAngles = camera.eulerAngles  // カメラのオイラー角と同じにする
        sceneView.scene.rootNode.addChildNode(labelNode) // 生成したラベルノードをシーンに追加する
        
        labelNodes.append(labelNode)
    }
    
}

