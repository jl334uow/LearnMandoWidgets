//
//  MandarinWords.swift
//  MandoWidget
//
//  Created by Justin  on 27/7/2026.
//

import Foundation

struct MandarinWord: Identifiable, Codable {
    let id = UUID()
    
    let character: String
    let pinyin: String
    let english: String
    
    static let sampleWords: [MandarinWord] = [
        MandarinWord(character: "你好", pinyin: "nǐ hǎo", english: "Hello"),
        MandarinWord(character: "谢谢", pinyin: "xiè xiè", english: "Thank you"),
        MandarinWord(character: "再见", pinyin: "zài jiàn", english: "Goodbye"),
        MandarinWord(character: "是", pinyin: "shì", english: "Yes"),
        MandarinWord(character: "不是", pinyin: "bù shì", english: "No"),
        MandarinWord(character: "好", pinyin: "hǎo", english: "Good"),
        MandarinWord(character: "不好", pinyin: "bù hǎo", english: "Not good"),
        MandarinWord(character: "对不起", pinyin: "duìbù qǐ", english: "Sorry"),
        MandarinWord(character: "没关系", pinyin: "méi guānxi", english: "It doesn't matter"),
        MandarinWord(character: "请", pinyin: "qǐng", english: "Please"),
        MandarinWord(character: "谢谢你", pinyin: "xiè xiè nǐ", english: "Thank you (you)"),
        MandarinWord(character: "水", pinyin: "shuǐ", english: "Water"),
        MandarinWord(character: "茶", pinyin: "chá", english: "Tea"),
        MandarinWord(character: "米饭", pinyin: "mǐfàn", english: "Rice"),
        MandarinWord(character: "面条", pinyin: "miàntiáo", english: "Noodles"),
        MandarinWord(character: "学生", pinyin: "xuésheng", english: "Student"),
        MandarinWord(character: "朋友", pinyin: "péngyou", english: "Friend"),
        MandarinWord(character: "家", pinyin: "jiā", english: "Home/Family"),
        MandarinWord(character: "名字", pinyin: "míngzi", english: "Name"),
        MandarinWord(character: "怎样", pinyin: "zěnyàng", english: "How"),
        MandarinWord(character: "多少", pinyin: "duōshao", english: "How much"),
        MandarinWord(character: "钱", pinyin: "qián", english: "Money"),
        MandarinWord(character: "天气", pinyin: "tiānqì", english: "Weather"),
        MandarinWord(character: "今天", pinyin: "jīntiān", english: "Today")
    ]
}
    

