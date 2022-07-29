//
//  TableViewCell.swift
//  KimChristianFinalProject
//
//  Created by Christian Kim on 2022/05/01.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var videoImg: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    
    let sharedData = SharedData.sharedData
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // configures each cell to have the title and thumbnail of each video
    func setVideo(title: String, thumbnail: String) {
        
        self.videoTitle.text = title
        
        // grabs the image from the shared data or as a request if the video hasn't been loaded in yet
        if let imageData = sharedData.getImage(url: thumbnail) {
            self.videoImg.image = UIImage(data: imageData)
        }
        
        else {
            let url = URL(string: thumbnail)
            URLSession.shared.dataTask(with: url!) { data, response, error in
                if let error = error {
                    print("Error IMAGE: \(error)")
                }
                if data != nil {
                    self.sharedData.addImage(url: thumbnail, data: data)
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async {
                        self.videoImg.image = image
                    }
                }
            }.resume()
        }
    }

}
