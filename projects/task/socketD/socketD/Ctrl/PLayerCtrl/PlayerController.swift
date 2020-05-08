

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
    
    var audioList:NSArray!
    var currentAudioIndex = 0
    var timer: Timer?


    var shuffleState = false
    var repeatState = false
    var shuffleArray = [Int]()

    @IBOutlet var songNameLabel : UILabel!
    
    @IBOutlet var progressTimerLabel : UILabel!
    

    @IBOutlet var playerProgressSlider : UISlider!
    @IBOutlet var totalLengthOfAudioLabel : UILabel!
    @IBOutlet var previousButton : UIButton!
    
    
    @IBOutlet var playButton : UIButton!
    @IBOutlet var nextButton : UIButton!

    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!

    
    var music = SongInfo()
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previousButton.isHidden = true
        nextButton.isHidden = true
        
        //this sets last listened trach number as current
        retrieveSavedTrackNumber()
        prepareAudio()
      
        setRepeatAndShuffle()
        retrievePlayerProgressSliderValue()
        //LockScreen Media control registry
        if UIApplication.shared.responds(to: #selector(UIApplication.beginReceivingRemoteControlEvents)){
            UIApplication.shared.beginReceivingRemoteControlEvents()
            UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
            })
        }
        
        songNameLabel.text = music.songName


    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        audioPlayer?.stop()
        
    }
    
    
    
    //MARK:- Lockscreen Media Control
      
      // This shows media info on lock screen - used currently and perform controls
      func showMediaInfo(){
          
          if let songName = music.songName{
              MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : songName]
          }
          
      }
      
      override func remoteControlReceived(with event: UIEvent?) {
          if event!.type == UIEvent.EventType.remoteControl{
              switch event!.subtype{
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
      


    
    func setRepeatAndShuffle(){
        shuffleState = UserDefaults.standard.bool(forKey: "shuffleState")
        repeatState = UserDefaults.standard.bool(forKey: "repeatState")
        
        shuffleButton.isSelected = shuffleState
     
        repeatButton.isSelected = repeatState
        
    
    }
    

    


    
    func saveCurrentTrackNumber(){
        UserDefaults.standard.set(currentAudioIndex, forKey: AudioTags.currentIndex.rawValue)
   
        
    }
    
    

    func alertSongExsit(){
        let alert = UIAlertController(title: "Music Error", message: "No songs Exsit", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Cancel it", style: UIAlertAction.Style.cancel) { (action) in            }
        alert.addAction(action)
        present(alert, animated: true, completion: {})
    }
    
    
    
    func retrieveSavedTrackNumber(){
        
        currentAudioIndex = UserDefaults.standard.intVal(forKey: AudioTags.currentIndex.rawValue)
    }


    
    // Prepare audio for playing
    func prepareAudio(){
    
        guard let src = music.src else{
            alertSongExsit()
            return
        }

        
        UIApplication.shared.beginReceivingRemoteControlEvents()
     
        do {
            let data = try Data(contentsOf: src)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1
            audioPlayer?.prepareToPlay()
            
        } catch{
            print(error)
        }
        
        
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
                    self.playerProgressSlider.maximumValue = Float(durationInSec)
                    self.totalLengthOfAudioLabel.text = Double(durationInSec).formattedTime
                }
                break
            case .failed: break // Handle error
            case .cancelled: break // Terminate processing
            default: break // Handle all other cases
            }
        }
        
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        progressTimerLabel.text = "00:00"
    }
    
    
    
    
    
    //MARK:- Player Controls Methods
    func playAudio(){
        guard audioPlayer != nil else {
            return
        }
        audioPlayer?.play()
        startTimer()
     
        saveCurrentTrackNumber()
        showMediaInfo()
    }
    
    
    
    
    func playNextAudio(){
        guard let p = audioPlayer else{
            alertSongExsit()
            return
        }
        currentAudioIndex += 1
        if currentAudioIndex>audioList.count-1{
            currentAudioIndex -= 1
            
            return
        }
        
        if p.isPlaying{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
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
        
        
        if p.isPlaying{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
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
        progressTimerLabel.text = p.currentTime.formattedTime
        playerProgressSlider.value = Float(p.currentTime)
        UserDefaults.standard.set(playerProgressSlider.value , forKey: AudioTags.playerProgress.rawValue)

        
    }
    
    
    
    
    
    func retrievePlayerProgressSliderValue(){
        guard audioPlayer != nil else {
            return
        }
        let playerProgressSliderValue =  UserDefaults.standard.float(forKey: AudioTags.playerProgress.rawValue)
        if playerProgressSliderValue == 0 {
            playerProgressSlider.value = 0.0
            audioPlayer?.currentTime = 0.0
            progressTimerLabel.text = "00:00:00"
            
            
        }else{
            guard let p = audioPlayer else{
                alertSongExsit()
                return
            }
            playerProgressSlider.value  = playerProgressSliderValue
            
            audioPlayer?.currentTime = TimeInterval(playerProgressSliderValue)
            
            progressTimerLabel.text = p.currentTime.formattedTime
            playerProgressSlider.value = Float(p.currentTime)
        }
    }

    
    //MARK:- Target Action
    
    @IBAction func play(_ sender : AnyObject) {
        guard let p = audioPlayer else{
            alertSongExsit()
            return
        }
        if shuffleState == true {
            shuffleArray.removeAll()
        }
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        if p.isPlaying{
            pauseAudioPlayer()
            playButton.setImage(play , for: UIControl.State.normal)
        }else{
            playAudio()
            playButton.setImage( pause, for: UIControl.State.normal)
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
        
        progressTimerLabel.text = TimeInterval(sender.value).formattedTime
    }
    
    
    
    
    // 这个控制，非常的流畅，漂亮
    @IBAction func progressSliderTouchedUp(_ sender: UISlider) {

        audioPlayer?.currentTime = TimeInterval(sender.value)
       
        if audioPlayer?.isPlaying == false{
            audioPlayer?.play()
        }
        startTimer()
    }
    
    
    
  
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        shuffleArray.removeAll()
        if sender.isSelected{
            sender.isSelected = false
            shuffleState = false
            UserDefaults.standard.set(false, forKey: "shuffleState")
        } else {
            sender.isSelected = true
            shuffleState = true
            UserDefaults.standard.set(true, forKey: "shuffleState")
        }
        
        
        
    }
    
    
    @IBAction func repeatButtonTapped(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            repeatState = false
            UserDefaults.standard.set(false, forKey: "repeatState")
        } else {
            sender.isSelected = true
            repeatState = true
            UserDefaults.standard.set(true, forKey: "repeatState")
        }

        
    }
    
    
}

extension PlayerController: AVAudioPlayerDelegate{


    // MARK:- AVAudioPlayer Delegate's Callback method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            
            if shuffleState == false && repeatState == false {
                // do nothing
                playButton.setImage( UIImage(named: "play"), for: UIControl.State.normal)
                return
                
            } else if shuffleState == false && repeatState == true {
                //repeat same song
                prepareAudio()
                playAudio()
                
            } else if shuffleState == true && repeatState == false {
                //shuffle songs but do not repeat at the end
                //Shuffle Logic : Create an array and put current song into the array then when next song come randomly choose song from available song and check against the array it is in the array try until you find one if the array and number of songs are same then stop playing as all songs are already played.
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= audioList.count {
                    playButton.setImage( UIImage(named: "play"), for: UIControl.State.normal)
                    return
                    
                }
                
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    }else{
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
                
            } else if shuffleState == true && repeatState == true {
                //shuffle song endlessly
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= audioList.count {
                    shuffleArray.removeAll()
                }
                
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    }else{
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
                
                
            }
            
        }
    }




}

