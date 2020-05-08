

import UIKit
import AVFoundation

import MediaPlayer



struct SongInfo {
    let music: Data?
    let songName: String?
    
    init(song data: Data? = nil, name title: String? = nil){
        music = data
        songName = title
    }
}



class PlayerController: UIViewController{
    
    //Choose background here. Between 1 - 7
    let selectedBackground = 1
    
    
    var audioPlayer:AVAudioPlayer! = nil
    
    var audioList:NSArray!
    var currentAudioIndex = 0
    var timer:Timer!
    
    
    var audioLength = 0.0
    
    var totalLengthOfAudio = ""
    var finalImage:UIImage!
    var isTableViewOnscreen = false
    
    
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
    
    override var prefersStatusBarHidden : Bool {
        isTableViewOnscreen
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //assing background

        
        //this sets last listened trach number as current
        retrieveSavedTrackNumber()
        prepareAudio()
      
        assingSliderUI()
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
    
        guard let data = music.music else {
            alertSongExsit()
            return
        }

        
        UIApplication.shared.beginReceivingRemoteControlEvents()
     
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = self
        
            audioLength = audioPlayer.duration
            playerProgressSlider.maximumValue = CFloat(audioPlayer.duration)
            playerProgressSlider.minimumValue = 0.0
            playerProgressSlider.value = 0.0
        
        
            audioPlayer.prepareToPlay()
            showTotalSongLength()
        
            progressTimerLabel.text = "00:00"
        } catch{
            print(error)
        }
        
        
        
        
    }
    
    
    
    
    
    //MARK:- Player Controls Methods
    func  playAudio(){
        guard audioPlayer != nil else {
            return
        }
        audioPlayer.play()
        startTimer()
     
        saveCurrentTrackNumber()
        showMediaInfo()
    }
    
    
    
    
    func playNextAudio(){
        guard audioPlayer != nil else{
            alertSongExsit()
            return
        }
        currentAudioIndex += 1
        if currentAudioIndex>audioList.count-1{
            currentAudioIndex -= 1
            
            return
        }
        
     
        
        if audioPlayer.isPlaying{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    
    
    
    func playPreviousAudio(){
        guard audioPlayer != nil else{
            alertSongExsit()
            return
        }
        currentAudioIndex -= 1
        if currentAudioIndex<0{
            currentAudioIndex += 1
            return
        }
        
        
        if audioPlayer.isPlaying{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func stopAudiplayer(){
        audioPlayer.stop();
        
    }
    
    func pauseAudioPlayer(){
        audioPlayer.pause()
        
    }
    
    
    //MARK:- Timer
    
    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerController.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    func stopTimer(){
        timer.invalidate()
        
    }
    
    
    @objc func update(_ timer: Timer){
        if !audioPlayer.isPlaying{
            return
        }
        let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
        progressTimerLabel.text  = "\(time.minute):\(time.second)"
        playerProgressSlider.value = CFloat(audioPlayer.currentTime)
        UserDefaults.standard.set(playerProgressSlider.value , forKey: AudioTags.playerProgress.rawValue)

        
    }
    
    
    
    
    
    func retrievePlayerProgressSliderValue(){
        guard audioPlayer != nil else {
            return
        }
        let playerProgressSliderValue =  UserDefaults.standard.float(forKey: AudioTags.playerProgress.rawValue)
        if playerProgressSliderValue == 0 {
            playerProgressSlider.value = 0.0
            audioPlayer.currentTime = 0.0
            progressTimerLabel.text = "00:00:00"
            
            
        }else{
            guard audioPlayer != nil else{
                alertSongExsit()
                return
            }
            playerProgressSlider.value  = playerProgressSliderValue
            
            audioPlayer.currentTime = TimeInterval(playerProgressSliderValue)
            
            let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
            progressTimerLabel.text  = "\(time.minute):\(time.second)"
            playerProgressSlider.value = CFloat(audioPlayer.currentTime)
        }
    }

    
    
    //This returns song length
    func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
       // let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
       // var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    

    
    func showTotalSongLength(){
        calculateSongLength()
        totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }
    
    


 
  
    
    
 
   
    func assingSliderUI () {
        let minImage = UIImage(named: "slider-track-fill")
        let maxImage = UIImage(named: "slider-track")
        let thumb = UIImage(named: "thumb")

        playerProgressSlider.setMinimumTrackImage(minImage, for: UIControl.State())
        playerProgressSlider.setMaximumTrackImage(maxImage, for: UIControl.State())
        playerProgressSlider.setThumbImage(thumb, for: UIControl.State())

    
    }
    
    //MARK:- Target Action
    
    @IBAction func play(_ sender : AnyObject) {
        guard audioPlayer != nil else{
            alertSongExsit()
            return
        }
        if shuffleState == true {
            shuffleArray.removeAll()
        }
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        if audioPlayer.isPlaying{
            pauseAudioPlayer()
            if audioPlayer.isPlaying {
                playButton.setImage( pause, for: UIControl.State())
            }
            else{
                playButton.setImage(play , for: UIControl.State())
            }
            
        }else{
            playAudio()
            if audioPlayer.isPlaying {
                playButton.setImage( pause, for: UIControl.State())
            }
            else{
                playButton.setImage(play , for: UIControl.State())
            }
            
        }
    }
    
    
    
    @IBAction func next(_ sender : AnyObject) {
        playNextAudio()
    }
    
    
    @IBAction func previous(_ sender : AnyObject) {
        playPreviousAudio()
    }
    
    
    
    
    @IBAction func changeAudioLocationSlider(_ sender : UISlider) {
        guard audioPlayer != nil else{
            alertSongExsit()
            return
        }
        audioPlayer.pause()
        audioPlayer.currentTime = TimeInterval(sender.value)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.audioPlayer.play()
        }
       
        
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






extension PlayerController: UITableViewDelegate{
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
      
        currentAudioIndex = (indexPath as NSIndexPath).row
        prepareAudio()
        playAudio()

        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        
        
        if audioPlayer.isPlaying{
            playButton.setImage( pause, for: UIControl.State())
        }
        else{
            playButton.setImage(play , for: UIControl.State())
        }
        
        
    }
    
    
    
    
}







extension PlayerController: UITableViewDataSource{
    


    //MARK-


    // Table View Part of the code. Displays Song name and Artist Name
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        var songNameDict = NSDictionary();
        songNameDict = audioList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        let songName = songNameDict.value(forKey: "songName") as! String
        
        var albumNameDict = NSDictionary();
        albumNameDict = audioList.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        let albumName = albumNameDict.value(forKey: "albumName") as! String
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont(name: "BodoniSvtyTwoITCTT-BookIta", size: 25.0)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = songName
        
        cell.detailTextLabel?.font = UIFont(name: "BodoniSvtyTwoITCTT-Book", size: 16.0)
        cell.detailTextLabel?.textColor = UIColor.white
        cell.detailTextLabel?.text = albumName
        return cell
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }



    func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath){
        tableView.backgroundColor = UIColor.clear
        
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = UIColor.clear
        cell.backgroundView = backgroundView
        cell.backgroundColor = UIColor.clear
    }




}







extension PlayerController: AVAudioPlayerDelegate{


    // MARK:- AVAudioPlayer Delegate's Callback method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            
            if shuffleState == false && repeatState == false {
                // do nothing
                playButton.setImage( UIImage(named: "play"), for: UIControl.State())
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
                    playButton.setImage( UIImage(named: "play"), for: UIControl.State())
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

