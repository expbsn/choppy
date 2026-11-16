import Foundation

/// Guesses the kana reading of Japanese text on the device, for words that do not come from the
/// bundled content (translator results, words typed by hand). The guess can be wrong for names
/// and rare readings, so it is always shown in an editable field.
enum ReadingGenerator {
    /// Hiragana reading of `text`. Kana stay as they are; kanji are transcribed word by word.
    static func hiragana(for text: String) -> String {
        let string = text as NSString
        let tokenizer = CFStringTokenizerCreate(nil, string, CFRange(location: 0, length: string.length),
                                                kCFStringTokenizerUnitWord, Locale(identifier: "ja") as CFLocale)
        var result = ""
        while !CFStringTokenizerAdvanceToNextToken(tokenizer).isEmpty {
            let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let token = string.substring(with: NSRange(location: range.location, length: range.length))
            if let latin = CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? String {
                let kana = NSMutableString(string: latin)
                CFStringTransform(kana, nil, kCFStringTransformLatinHiragana, false)
                result += kana as String
            } else {
                result += token
            }
        }
        return result.isEmpty ? text : result
    }
}
