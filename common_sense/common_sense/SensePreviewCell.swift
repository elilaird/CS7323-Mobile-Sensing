//
//  SensePreviewCell.swift
//  common_sense
//
//  Created by Matthew Lee on 12/8/20.
//
import FoldingCell
import UIKit

class SensePreviewCell: FoldingCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        AlertIcon.image!.withRenderingMode(.alwaysTemplate)
        AlertIcon.tintColor = .red
        // Initialization code
    }

    @IBOutlet weak var AlertIcon: UIImageView!
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
