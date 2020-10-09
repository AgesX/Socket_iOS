

import UIKit
import AVFoundation

import MediaPlayer



struct SongInfo {
    let songName: String?
    let src: URL?
    
    init(song url: URL? = nil){
        songName = url?.lastPathComponent
        src = url
    }
}



class PlayerController: UIViewController{

    var audioPlayer: AVAudioPlayer?
    
    var currentAudioIndex = 0
    var timer: Timer?

    
    var timerBack: Timer?

    var repeatState = false
   

    @IBOutlet var songNameLabel : UILabel!
    
    @IBOutlet var progressTimerLabel : UILabel!
    

    @IBOutlet var playerProgressSlider : UISlider!
    @IBOutlet var totalLengthOfAudioLabel : UILabel!
    @IBOutlet var previousButton : UIButton!
    
    
    @IBOutlet var playButton : UIButton!
    @IBOutlet var nextButton : UIButton!

    
    @IBOutlet weak var repeatButton: UIButton!

    
    let source: [URL]
    let initial: Int
    
    var music: SongInfo{
        SongInfo(song: source[currentAudioIndex])
    }
    
    var lasting: TimeInterval?
    
    
    var backLearn: MusicItem?
    
    init(music src: [URL], item row: Int) {
        source = src
        initial = row
        super.init(nibName: "PlayerController", bundle: nil)
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
        
        
        currentAudioIndex = initial
        //this sets last listened trach number as current
        prepareAudio()
      
        setRepeat()
        retrievePlayerProgressSliderValue()
        //LockScreen Media control registry
        if UIApplication.shared.responds(to: #selector(UIApplication.beginReceivingRemoteControlEvents)){
            UIApplication.shared.beginReceivingRemoteControlEvents()
            UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
            })
        }
        
        configName()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(self.toStudy))
        
        
        play(self)
        
        

    }
    
    
    
    func configName(){
        songNameLabel.text = music.songName?.fileName
        title = music.songName?.fileName
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backLearn = nil
        stopTimer()
        stopTimerBack()
        audioPlayer?.stop()
        playButton(isPlay: false)
    }
    
    
    
    
    
    @objc func toStudy(){
        if let t = lasting{
            let learn = StudyC(delegate: self, duration: t)
            navigationController?.pushViewController(learn, animated: true)
        }
        
    }
    
    
    //MARK:- Lockscreen Media Control
      
      // This shows media info on lock screen - used currently and perform controls
    func showMediaInfo(duration total: TimeInterval, current time: TimeInterval){
          
          if let songName = music.songName{
                let info: [String : Any]? = [MPMediaItemPropertyTitle : songName.fileName,
                                             MPMediaItemPropertyArtist: "邓",
                                             MPMediaItemPropertyPlaybackDuration: total,
                                             MPNowPlayingInfoPropertyElapsedPlaybackTime: time]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = info
          }
          
      }
      
      override func remoteControlReceived(with event: UIEvent?) {
          if let e = event, e.type == UIEvent.EventType.remoteControl{
              switch e.subtype{
              case UIEventSubtype.remoteControlPlay:
                  play(self)
              case UIEventSubtype.remoteControlPause:
                  play(self)
              case UIEventSubtype.remoteControlNextTrack:
                  next(self)
              case UIEventSubtype.remoteControlPreviousTrack:
                  previous(self)
              default:
                  print("There is an issue with the control")
              }
          }
      }
      
      
      
      override var preferredStatusBarStyle : UIStatusBarStyle {
          return UIStatusBarStyle.default
      }
      


    
    func setRepeat(){
        
        repeatState = UserDefaults.standard.bool(forKey: "repeatState")
        
        repeatButton.isSelected = repeatState
        
    
    }
    

    

    func alertSongExsit(){
        let alert = UIAlertController(title: "Music Error", message: "No songs Exsit", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Cancel it", style: UIAlertAction.Style.cancel) { (action) in            }
        alert.addAction(action)
        present(alert, animated: true, completion: {})
    }
    

    
    // Prepare audio for playing
    func prepareAudio(){
    
        guard let src = music.src else{
            alertSongExsit()
            return
        }

        configName()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
     
        do {
            let data = try Data(contentsOf: src)
            audioPlayer = try AVAudioPlayer(data: data)
           
            audioPlayer?.volume = 1
            audioPlayer?.prepareToPlay()
           // audioPlayer?.enableRate = true
           // audioPlayer?.rate = 2
            
        } catch{
            print(error)
        }
        
        if src.lastPathComponent.contains("mp3"){
            let audioAsset = AVURLAsset(url: src, options: nil)
            let d_k = "duration"
            audioAsset.loadValuesAsynchronously(forKeys: [d_k]) {
                var error: NSError? = nil
                let status = audioAsset.statusOfValue(forKey: d_k, error: &error)
                switch status {
                case .loaded: // Sucessfully loaded. Continue processing.
                    let duration = audioAsset.duration
                    let durationInSec = CMTimeGetSeconds(duration)
                    DispatchQueue.main.async {
                        self.lasting = durationInSec
                        self.playerProgressSlider.maximumValue = Float(durationInSec)
                        self.totalLengthOfAudioLabel.text = Double(durationInSec).formatted
                    }
                    break
                case .failed: break // Handle error
                case .cancelled: break // Terminate processing
                default: break // Handle all other cases
                }
            }
        }
        else{
            let t = audioPlayer?.duration ?? 0
            lasting = t
            playerProgressSlider.maximumValue = Float(t)
            totalLengthOfAudioLabel.text = t.formatted
        }
        
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        progressTimerLabel.text = "00: 00: 00"
    }
    
    
    
    
    
    //MARK:- Player Controls Methods
    func playAudio(){
        guard audioPlayer != nil else {
            return
        }
        audioPlayer?.numberOfLoops = 5
        audioPlayer?.play()
        startTimer()
        guard let duration = audioPlayer?.duration, let current = audioPlayer?.currentTime else {
            return
        }
        showMediaInfo(duration: duration, current: current)
    }
    
    
    
    
    func playNextAudio(){
        guard let p = audioPlayer else{
            alertSongExsit()
            return
        }
        currentAudioIndex += 1
        if currentAudioIndex >= source.count{
            currentAudioIndex -= 1
            return
        }
        prepareAudio()
        if p.isPlaying{
            playAudio()
        }
        
    }
    
    
    
    
    
    func playPreviousAudio(){
        guard let p = audioPlayer else{
            alertSongExsit()
            return
        }
        currentAudioIndex -= 1
        if currentAudioIndex<0{
            currentAudioIndex += 1
            return
        }
        
        prepareAudio()
        if p.isPlaying{
            playAudio()
        }
        
    }
    
    
    func stopAudiplayer(){
        audioPlayer?.stop()
        
    }
    
    func pauseAudioPlayer(){
        audioPlayer?.pause()
        
    }
    
    
    //MARK:- Timer
    
    func startTimer(){
        stopTimerBack()
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerController.update(_:)), userInfo: nil,repeats: true)
            timer?.fire()
        }
    }
    
    func stopTimer(){
        
        timer?.invalidate()
        timer = nil
    
    }
    
    
    @objc func update(_ timer: Timer){
        guard let p = audioPlayer, p.isPlaying else {
            return
        }
        progressTimerLabel.text = p.currentTime.formatted
        playerProgressSlider.value = Float(p.currentTime)
        if var song = music.songName{
            song.progress = playerProgressSlider.value
        }
        let curve = Float(p.currentTime)
        if curve + 10 >= playerProgressSlider.maximumValue{
            
            if var song = music.songName{
                playerProgressSlider.value = 0
                song.progress = playerProgressSlider.value
            }
            
            if repeatState{
                //repeat same song
                prepareAudio()
                playAudio()
                

            }
            else {
                playNextAudio()
                    
            }
            
            
        }
        
    }
    
    
    
    
    
    func retrievePlayerProgressSliderValue(){
        guard audioPlayer != nil else {
            return
        }
        var playerProgressSliderValue: Float = 0
        if let song = music.songName{
            playerProgressSliderValue = song.progress
        }
        if playerProgressSliderValue == 0 {
            playerProgressSlider.value = 0.0
            audioPlayer?.currentTime = 0.0
            progressTimerLabel.text = "00:00:00"
            
            
        }
        else{
            guard let p = audioPlayer else{
                alertSongExsit()
                return
            }
            playerProgressSlider.value  = playerProgressSliderValue
            
            audioPlayer?.currentTime = TimeInterval(playerProgressSliderValue)
            
            progressTimerLabel.text = p.currentTime.formatted
            playerProgressSlider.value = Float(p.currentTime)
        }
    }

    
    //MARK:- Target Action
    
    @IBAction func play(_ sender : AnyObject) {
        guard let p = audioPlayer else{
            alertSongExsit()
            return
        }
        
        if p.isPlaying{
            pauseAudioPlayer()
            playButton(isPlay: false)
        }else{
            playAudio()
            playButton(isPlay: true)
        }
    }
    
    
    
    @IBAction func next(_ sender : AnyObject) {
        
        playNextAudio()
    }
    
    
    @IBAction func previous(_ sender : AnyObject) {
        playPreviousAudio()
    }
    
    
    
    
    
    @IBAction func progressSliderTouchedDown(_ sender: UISlider) {
        guard let p = audioPlayer else{
            alertSongExsit()
            return
        }
        if p.isPlaying{
            pauseAudioPlayer()
        }
        stopTimer()
    }
    
    
    
    
    
    @IBAction func progressSliderValueChanged(_ sender: UISlider) {
        guard audioPlayer != nil else{
            alertSongExsit()
            return
        }
        
        progressTimerLabel.text = TimeInterval(sender.value).formatted
    }
    
    
    
    
    // 这个控制，非常的流畅，漂亮
    @IBAction func progressSliderTouchedUp(_ sender: UISlider) {

        audioPlayer?.currentTime = TimeInterval(sender.value)
       
        if audioPlayer?.isPlaying == false{
            audioPlayer?.play()
            playButton(isPlay: true)
        }
        startTimer()
    }
    
    
    
  
 
    
    @IBAction func repeatButtonTapped(_ sender: UIButton) {
        if sender.isSelected{
            repeatState = false
            
        } else {
            repeatState = true
        }
        sender.isSelected = repeatState
        UserDefaults.standard.set(repeatState, forKey: "repeatState")
        
    }
    
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
}

extension PlayerController: AVAudioPlayerDelegate{


    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
       
        
        var conditionOne = true
        if let segment = backLearn{
            audioPlayer?.currentTime = segment.start
            audioPlayer?.play()
            conditionOne = false
        }
        guard conditionOne, flag else {
            return
        }
        
        
            
        
  

            
        
    }




}






extension PlayerController: BackPlayDelegate{
    func learn(byRepeat material: MusicItem?) {
        guard let music = material else {
            audioPlayer?.pause()
            playButton(isPlay: false)
            return
        }
        playButton(isPlay: true)
        backLearn = music
        playAudioTwo(begin: music.start)
        
    }
    
    
    func playAudioTwo(begin start: TimeInterval){
        guard audioPlayer != nil else {
            return
        }
        audioPlayer?.currentTime = start
        audioPlayer?.numberOfLoops = 0
        audioPlayer?.play()
        startTimerTwo()
        guard let duration = audioPlayer?.duration, let current = audioPlayer?.currentTime else {
            return
        }
        showMediaInfo(duration: duration, current: current)
    }
    
    
    func startTimerTwo(){
        if timerBack == nil {
            timerBack = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerController.record), userInfo: nil,repeats: true)
            timerBack?.fire()
        }
    }
    
    
    @objc func record(){
        guard let p = audioPlayer, p.isPlaying else {
            return
        }
        if let segment = backLearn, segment.end <= p.currentTime{
            audioPlayer?.currentTime = segment.start
            audioPlayer?.play()
        }
    }
    
    
    
    func stopTimerBack(){
        
        timerBack?.invalidate()
        timerBack = nil
    
    }
    
    func playButton(isPlay toPlay: Bool){
        if toPlay{
            playButton.setImage(UIImage(named: "pause") , for: UIControl.State.normal)
        }
        else{
            playButton.setImage(UIImage(named: "play") , for: UIControl.State.normal)
        }
    }
}
