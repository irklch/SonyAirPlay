//
//  MainScreenVC.swift
//  SonyAirPlay
//
//  Created by Ирина Кольчугина on 03.12.2023.
//

import UIKit
import SnapKit
import m

final class MainScreenVC: UIViewController {
    private lazy var airplayButton: AVRoutePickerView = {
let airplayButton = AVRoutePickerView()
        airplayButton.delegate = self
        return airplayButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal.withAlphaComponent(0.1)
        view.addSubview(airplayButton)
        airplayButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
        let avAsset = AVAsset(url: URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")!)
            let avPlayerItem = AVPlayerItem(asset: avAsset)
            let avPlayer = AVPlayer(playerItem: avPlayerItem)
            let avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer.frame = CGRect(x: 0.0, y: 40.0, width: self.view.frame.size.width, height: self.view.frame.size.height - 40.0)
            self.view.layer.addSublayer(avPlayerLayer)
            avPlayer.seek(to: CMTime.zero)
            avPlayer.play()
        avPlayer.mirr
    }
}
extension MainScreenVC: AVRoutePickerViewDelegate {

}
