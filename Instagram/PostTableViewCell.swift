//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by WEBSYSTEM-MAC29 on 2023/10/11.
//

import UIKit
import FirebaseStorageUI

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)
        
        
        
        // 日時の表示
        self.dateLabel.text = postData.date
        
        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // コメントの表示
        let comments = postData.comments
        
        var sumString = "\(postData.name) : \(postData.caption)"
        
        if  comments.isEmpty == false {
            for comment in 0...comments.count - 1 {
                if comment == 0 {
                    sumString += "\n\n" + "コメント一覧"
                }
                sumString += "\n" + comments[comment]
            }
        }

        
        // キャプションの表示
        self.captionLabel.text = sumString
    }
}
