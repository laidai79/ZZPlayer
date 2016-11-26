//
//  ZZPlayerView.swift
//  ZZPlayer
//
//  Created by duzhe on 16/8/19.
//  Copyright © 2016年 dz. All rights reserved.

import UIKit
import AVFoundation

protocol ZZPlayerViewDelegate:NSObjectProtocol {
    
    func zzplayer(_ playerView:ZZPlayerView,sliderTouchUpOut slider:UISlider)
    func zzplayer(_ playerView:ZZPlayerView,playAndPause playBtn:UIButton)
}

class ZZPlayerView: UIView {
    var playerLayer:AVPlayerLayer?
    var slider:UISlider!
    var progressView:UIProgressView!
    var playBtn:UIButton!
    
    var timeLabel:UILabel!
    var sliding = false
    var playing = true
    weak var delegate:ZZPlayerViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        slider = UISlider()
        self.addSubview(slider)
        slider.snp_makeConstraints { (make) in
            make.bottom.equalTo(self).inset(5)
            make.left.equalTo(self).offset(50)
            make.right.equalTo(self).inset(100)
            make.height.equalTo(15)
        }
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        // 从最大值滑向最小值时杆的颜色
        slider.maximumTrackTintColor = UIColor.clear
        // 从最小值滑向最大值时杆的颜色
        slider.minimumTrackTintColor = UIColor.white
        // 在滑块圆按钮添加图片
        slider.setThumbImage(UIImage(named:"slider_thumb"), for: UIControlState())
        
        progressView = UIProgressView()
        progressView.backgroundColor = UIColor.lightGray
        self.insertSubview(progressView, belowSubview: slider)
        progressView.snp_makeConstraints { (make) in
            make.left.right.equalTo(slider)
            make.centerY.equalTo(slider)
            make.height.equalTo(2)
        }
        
        progressView.tintColor = UIColor.red
        progressView.progress = 0
        
        timeLabel = UILabel()
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(timeLabel)
        timeLabel.snp_makeConstraints { (make) in
            make.right.equalTo(self)
            make.left.equalTo(slider.snp_right).offset(10)
            make.bottom.equalTo(self).inset(5)
        }
        playBtn = UIButton()
        self.addSubview(playBtn)
        playBtn.snp_makeConstraints { (make) in
            make.centerY.equalTo(slider)
            make.left.equalTo(self).offset(10)
            make.width.height.equalTo(30)
        }
        playBtn.setImage(UIImage(named: "player_pause"), for: UIControlState())
        playBtn.addTarget(self, action: #selector(playAndPause( _:)) , for: UIControlEvents.touchUpInside)
        
        // 按下的时候
        slider.addTarget(self, action: #selector(sliderTouchDown( _:)), for: UIControlEvents.touchDown)
        // 弹起的时候
        slider.addTarget(self, action: #selector(sliderTouchUpOut( _:)), for: UIControlEvents.touchUpOutside)
        slider.addTarget(self, action: #selector(sliderTouchUpOut( _:)), for: UIControlEvents.touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUpOut( _:)), for: UIControlEvents.touchCancel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
    
    
    func sliderTouchDown(_ slider:UISlider){
        self.sliding = true
    }
    func sliderTouchUpOut(_ slider:UISlider){
        delegate?.zzplayer(self, sliderTouchUpOut: slider)
    }
    
    func playAndPause(_ btn:UIButton){
        let tmp = !playing
        playing = tmp
        if playing {
            playBtn.setImage(UIImage(named: "player_pause"), for: UIControlState())
        }else{
            playBtn.setImage(UIImage(named: "player_play"), for: UIControlState())
        }
        delegate?.zzplayer(self, playAndPause: btn)
    }
    
    
}

//MARK: - 延时执行
func delay(_ seconds: Double, completion:@escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }
}

