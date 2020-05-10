//
//  FileListController.swift
//  socketD
//
//  Created by Jz D on 2020/5/7.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit

import AVFoundation

class FileListController: UITableViewController {
    
    let cellID = "cellID"
    var files = [URL]()
    

    
    private lazy var refresh: UIRefreshControl = {
        let c = UIRefreshControl()
        c.addTarget(self, action: #selector(self.pullToRefresh), for: UIControl.Event.valueChanged)
        return c
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "媒体库"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        tableView.refreshControl = refresh
    }
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    
    @objc
    func pullToRefresh(){
        refreshData()
        refresh.endRefreshing()
    }
    
    
    
    func refreshData(){
        files.removeAll()
        if let src = URL(string: URL.dir){
            do {
                let properties: [URLResourceKey] = [ URLResourceKey.localizedNameKey, URLResourceKey.creationDateKey, URLResourceKey.localizedTypeDescriptionKey]
                let paths = try FileManager.default.contentsOfDirectory(at: src, includingPropertiesForKeys: properties, options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles])
                for url in paths{
                    let isDirectory = (try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory ?? false
                    let musicExtern = ["mp3", "m4a"]
                    if isDirectory == false, musicExtern.contains(url.pathExtension){
                        files.append(url)
                    }
                }
                tableView.reloadData()
            } catch let error{
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let attribute = [NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
        let attrString = NSAttributedString(string: files[indexPath.row].lastPathComponent, attributes: attribute)
        cell.textLabel?.attributedText = attrString
        return cell
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let url = files[indexPath.row]
        let musicCtrl = PlayerController(nibName: "PlayerController", bundle: nil)
        musicCtrl.music = SongInfo(song: url)
        navigationController?.pushViewController(musicCtrl, animated: true)
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let url = files[indexPath.row]
        let contextItem = UIContextualAction(style: .destructive, title: "删文件") {  (contextualAction, view, boolValue) in
            do {
                if FileManager.default.fileExists(atPath: url.file){
                    try FileManager.default.removeItem(atPath: url.file)
                }
                self.refreshData()
            } catch {
                print(error)
            }
        }

        return UISwipeActionsConfiguration(actions: [contextItem])
    }
    
    /*
     
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    
}
