//
//  AdjustFontSize.swift
//  iykyk
//
//  Created by Patrick McKowen on 8/25/24.
//

import UIKit

func adjustFontSize(for text: String, in size: CGSize, startingFontSize: CGFloat = 17) -> CGFloat {
    let maxWidth = size.width - 14
    let maxHeight = size.height - 14
    let testFont = UIFont.systemFont(ofSize: startingFontSize, weight: .bold)
    let words = text.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)

    if words.count == 2 {
        // Two words: split them and calculate size
        let size1 = (words[0] as NSString).size(withAttributes: [.font: testFont])
        let size2 = (words[1] as NSString).size(withAttributes: [.font: testFont])
        let totalHeight = size1.height + size2.height
        let maxWordWidth = max(size1.width, size2.width)

        if maxWordWidth > maxWidth || totalHeight > maxHeight {
            return startingFontSize * min(maxWidth / maxWordWidth, maxHeight / totalHeight) * 0.95
        }
    } else {
        // Single word
        let size = (text as NSString).size(withAttributes: [.font: testFont])
        if size.width > maxWidth || size.height > maxHeight {
            return startingFontSize * min(maxWidth / size.width, maxHeight / size.height) * 0.95
        }
    }

    return startingFontSize
}
