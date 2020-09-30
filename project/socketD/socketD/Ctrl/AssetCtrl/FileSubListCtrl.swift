//
//  FileListController.swift
//  socketD
//
//  Created by Jz D on 2020/5/7.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit

import AVFoundation

class FileSubListCtrl: UITableViewController {
    
    let cellID = "cellID"
    var url: URL?
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
        if let src = url{
            do {
                let properties: [URLResourceKey] = [ URLResourceKey.localizedNameKey, URLResourceKey.creationDateKey, URLResourceKey.localizedTypeDescriptionKey]
                let paths = try FileManager.default.contentsOfDirectory(at: src, includingPropertiesForKeys: properties, options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles])
                for url in paths{
                    let isDirectory = (try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory ?? false
                    let musicExtern = ["mp3", "m4a", "txt"]
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
        
        let light = "\(indexPath.row)  ->"

        let lightAttributes = [
            NSAttributedString.Key.font: UIFont.regular(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let source = "\(light)  \(files[indexPath.row].lastPathComponent)"
        
        let yes = NSMutableAttributedString(string: source)
        let wholeAttributes = [
            NSAttributedString.Key.font: UIFont.medium(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.red
        ]
        
        
        let lightRange = source.range(light)
        yes.setAttributes(wholeAttributes, range: NSRange(location: 0, length: source.count))
        yes.setAttributes(lightAttributes, range: lightRange)
        let suffix = ".m4a"
        if source.contains(suffix){
            let suffixRange = source.range(suffix)
            let notMatter = [NSAttributedString.Key.font: UIFont.regular(ofSize: 8),
                             NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            yes.setAttributes(notMatter, range: suffixRange)
        }
        cell.textLabel?.attributedText = yes.cp
        return cell
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = files[indexPath.row]
        guard url.absoluteString.contains("txt") == false else {
            //reading
            do {
                let text = try String(contentsOfFile: url.path, encoding: String.Encoding.utf8)
                print(text)
            }catch { print(error) }
            return
        }
        navigationController?.pushViewController(PlayerController(music: url), animated: true)
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let url = files[indexPath.row]
        let contextItem = UIContextualAction(style: .destructive, title: "删文件") {  (contextualAction, view, boolValue) in
            do {
                if FileManager.default.fileExists(atPath: url.path){
                    try FileManager.default.removeItem(atPath: url.path)
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
