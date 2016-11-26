//
//  ViewController.swift
//  ZZPlayer
//
//  Created by duzhe on 16/8/19.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit
import AVFoundation

//AVPlayerItem：一个媒体资源管理对象，管理者视频的一些基本信息和状态，一个AVPlayerItem对应着一个视频资源。
class ViewController: UIViewController {

    @IBOutlet weak var playerView:ZZPlayerView!
    
    var playerItem:AVPlayerItem!
    var avplayer:AVPlayer!
    var playerLayer:AVPlayerLayer!
    
    var link:CADisplayLink!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 检测连接是否存在 不存在报错
        guard let url = URL(string: "http://192.168.31.188/XXHHD.mp4") else { fatalError("连接错误") }
        
        playerItem = AVPlayerItem(url: url) // 创建视频资源
        // 监听缓冲进度改变
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        // 监听状态改变
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        
        self.avplayer = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: avplayer)
        
        //设置模式
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        self.playerView.playerLayer = self.playerLayer
        self.playerView.layer.insertSublayer(playerLayer, at: 0)
        self.playerView.delegate = self
        
        self.link = CADisplayLink(target: self, selector: #selector(update))
        self.link.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit{
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "status")
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges"{
//            通过监听AVPlayerItem的"loadedTimeRanges"，可以实时知道当前视频的进度缓冲
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            let percent = loadedTime/totalTime
            
            self.playerView.progressView.progress = Float(percent)
        }else if keyPath == "status"{
//            AVPlayerItemStatusUnknown,AVPlayerItemStatusReadyToPlay, AVPlayerItemStatusFailed。只有当status为AVPlayerItemStatusReadyToPlay是调用 AVPlayer的play方法视频才能播放。
            print(playerItem.status.rawValue)
            if playerItem.status == AVPlayerItemStatus.readyToPlay{
                // 只有在这个状态下才能播放
                self.avplayer.play()
            }else{
                print("加载异常")
            }
        }
    }
    
    func avalableDurationWithplayerItem()->TimeInterval{
        guard let loadedTimeRanges = avplayer?.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecound = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSecound
        return result
    }
    
    func update(){
        //暂停的时候
        if !self.playerView.playing{
            return
        }
        
        let currentTime = CMTimeGetSeconds(self.avplayer.currentTime())
        let totalTime   = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
        
        
        let timeStr = "\(formatPlayTime(currentTime))/\(formatPlayTime(totalTime))"
        playerView.timeLabel.text = timeStr
        // 滑动不在滑动的时候
        if !self.playerView.sliding{
            // 播放进度
            self.playerView.slider.value = Float(currentTime/totalTime)
        }
        
    }
    
    func formatPlayTime(_ secounds:TimeInterval)->String{
        if secounds.isNaN{
            return "00:00"
        }
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController:ZZPlayerViewDelegate{
    // 滑动滑块 指定播放位置
    func zzplayer(_ playerView: ZZPlayerView, sliderTouchUpOut slider: UISlider) {
        
        //当视频状态为AVPlayerStatusReadyToPlay时才处理
        if self.avplayer.status == AVPlayerStatus.readyToPlay{
            let duration = slider.value * Float(CMTimeGetSeconds(self.avplayer.currentItem!.duration))
            let seekTime = CMTimeMake(Int64(duration), 1)
            self.avplayer.seek(to: seekTime, completionHandler: { (b) in
                playerView.sliding = false
            })
        }
    }
    
    
    func zzplayer(_ playerView: ZZPlayerView, playAndPause playBtn: UIButton) {
        if !playerView.playing{
            self.avplayer.pause()
        }else{
            if self.avplayer.status == AVPlayerStatus.readyToPlay{
                self.avplayer.play()
            }
        }
    }
    
}

