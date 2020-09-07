//
//  XibExtension.swift
//  XibFrame
//
//  Created by 施峰磊 on 2020/1/11.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

//MARK: - 基础视图
extension UIView {
    //TODO: 圆角
    @IBInspectable open var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue;
        }
        get {
            return self.layer.cornerRadius;
        }
    }
    
    //TODO: 框线宽度
    @IBInspectable open var borderWidth: CGFloat {
        set {
            self.layer.borderWidth = newValue;
        }
        get {
            return self.layer.borderWidth;
        }
    }
    
    //TODO: 框线颜色
    @IBInspectable open var borderColor: UIColor {
        set {
            self.layer.borderColor = newValue.cgColor;
        }
        get {
            return UIColor.init(cgColor: self.layer.borderColor ?? UIColor.black.cgColor);
        }
    }
    
    //TODO: 阴影颜色
    @IBInspectable open var shadowColor: UIColor {
        set {
            self.layer.shadowColor = newValue.cgColor;
        }
        get {
            return UIColor.init(cgColor: self.layer.shadowColor ?? UIColor.black.cgColor);
        }
    }
    
    
    //TODO: 阴影不透明度
    @IBInspectable open var shadowOpacity: Float {
        set {
            self.layer.shadowOpacity = newValue;
        }
        get {
            return self.layer.shadowOpacity;
        }
    }
    
    //TODO: 阴影半径
    @IBInspectable open var shadowRadius: CGFloat {
        set {
            self.layer.shadowRadius = newValue;
        }
        get {
            return self.layer.shadowRadius;
        }
    }
    
    //TODO: 阴影偏移
    @IBInspectable open var shadowOffset: CGSize {
        set {
            self.layer.shadowOffset = newValue;
        }
        get {
            return self.layer.shadowOffset;
        }
    }
    
}

//MARK: - 按钮

private var buttonUnEnabledColorKey :Void?
private var buttonEnabledColorKey :Void?

extension UIButton {
    //TODO: 按钮不可以颜色
    @IBInspectable open var unEnabledColor: UIColor? {
        set {
            objc_setAssociatedObject(self, &buttonUnEnabledColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &buttonUnEnabledColorKey) as? UIColor;
        }
    }
    
    
    private var enabledColor: UIColor? {
        set {
            if objc_getAssociatedObject(self, &buttonEnabledColorKey) == nil {
                objc_setAssociatedObject(self, &buttonEnabledColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            return objc_getAssociatedObject(self, &buttonEnabledColorKey) as? UIColor;
        }
    }
    
    open override var backgroundColor: UIColor?{
        didSet{
            if !(self.backgroundColor?.compare(tagerColor: oldValue) ?? false) {
                self.enabledColor = backgroundColor;
            }
        }
    }
    
    open override var isEnabled: Bool{
        didSet{
            self.backgroundColor = self.isEnabled ? (self.enabledColor ?? self.backgroundColor) : (self.unEnabledColor ?? self.backgroundColor) ;
        }
    }
}

extension UIColor{
    func compare(tagerColor:UIColor?) -> Bool {
        if tagerColor == nil {
            return false;
        }else{
            var red1:CGFloat = 0.0
            var red2:CGFloat = 0.0
            var green1:CGFloat = 0.0
            var green2:CGFloat = 0.0
            var blue1:CGFloat = 0.0
            var blue2:CGFloat = 0.0
            var alpha1:CGFloat = 0.0
            var alpha2:CGFloat = 0.0
            self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
            tagerColor!.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
            if ((red1 == red2)&&(green1 == green2)&&(blue1 == blue2)&&(alpha1 == alpha2)) {
                return true;
            } else {
                return false;
            }
        }
        
    }
}


//MARK: - UILabel显示
private var labelIsCheckZeroKey: Void?
private var labelDecimalPointLengthKey: Void?
private var labelOriginalStringKey: Void?

extension UILabel{
    //TODO: 原来的字符串
    private var originalString : String?{
        set {
            objc_setAssociatedObject(self, &labelOriginalStringKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &labelOriginalStringKey) as? String;
        }
    };
    
    //TODO: 是否检查小数位
    @IBInspectable open var isCheckZero: Bool {
        set {
            objc_setAssociatedObject(self, &labelIsCheckZeroKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            if self.text != nil {
                self.cText = self.originalString;
            }
        }
        get {
            return (objc_getAssociatedObject(self, &labelIsCheckZeroKey) as? Bool) ?? false;
        }
    }
    
    //TODO: 限制小数位长度，默认2位
    @IBInspectable open var decimalPointLength: Int16 {
        set {
            objc_setAssociatedObject(self, &labelDecimalPointLengthKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            if self.text != nil {
                self.cText = self.originalString;
            }
        }
        get {
            return (objc_getAssociatedObject(self, &labelDecimalPointLengthKey) as? Int16) ?? 2;
        }
    }
    
    //TODO: 字符串入口
    @IBInspectable open var cText: String? {
        set {
            self.originalString = newValue;
            if self.isCheckZero {
                self.text = newValue?.checkZero(scale: self.decimalPointLength);
            }else{
                self.text = newValue
            }
        }
        get{
            return self.text;
        }
    }
}

public enum StringType :Int {
    case None ,Number,Chinese,Other
}

class TypeString: NSObject {
    var type:StringType = .None
    var string:String = "";
}

//MARK: - String
extension String{
    /// TODO: 裁剪字符串
    /// - Parameter rang: 范围
    public func subString(rang:NSRange) -> String {
        let rang = self.rangToIndex(rang: rang) ;
        return String(self[rang]);
    }
    
    /// TODO: rang转为String.Index
    /// - Parameter rang: 范围
    public func rangToIndex(rang:NSRange) -> Range<String.Index> {
        let start = self.index(self.startIndex, offsetBy: rang.lowerBound)
        let end = self.index(self.startIndex, offsetBy: rang.upperBound)
        return start..<end
    }
    
    /// TODO: 保留小数点位数
    /// - Parameter scale: 位数
    public func checkZero(scale:Int16) -> String{
        let stringArray = numberTypeSplit(text: self);
        var stringList:Array<String> = Array.init();
        for typeString in stringArray {
            if typeString.type == .Number {
                stringList.append(priceTreatment(string: typeString.string, scale: scale))
            }else{
                stringList.append(typeString.string)
            }
        }
        return stringList.joined();
    }
    
    
    private func priceTreatment(string: String, scale:Int16) -> String{
        let roundingBehavior = NSDecimalNumberHandler.init(roundingMode: .bankers, scale: scale, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true);
        let number:NSDecimalNumber = NSDecimalNumber.init(string: string)
        return "\(number.rounding(accordingToBehavior: roundingBehavior))"
    }
        
    private func numberTypeSplit(text:String?) -> Array<TypeString> {
        if text != nil {
            let regular = try! NSRegularExpression.init(pattern: "([0-9]\\d*\\.?\\d*)", options: []);
            var results = regular.matches(in: text!, options: [], range: NSRange.init(location: 0, length: text!.count));
            var stringArray:Array<TypeString> = Array.init();
            var count:Int = 0
            if results.count > 0 {
                count = (results.count * 2)-1;
                let firstResult:NSTextCheckingResult! = results.first;
                let endResult:NSTextCheckingResult! = results.last;
                if (firstResult.range.location != 0){
                    count += 1;
                }
                if (firstResult != endResult) {//不是只有一个结果
                    if (endResult.range.location+endResult.range.length < text!.count){
                        count += 1;
                    }
                }else{
                    if (firstResult.range.location+firstResult.range.length < text!.count){
                        count += 1;
                    }
                }
            }
            if (count==0) {
                let typeString = TypeString();
                typeString.string = text!;
                typeString.type = .Other;
                stringArray.append(typeString);
            }else{
                var lastLocation = 0;
                for _ in 0...(count-1) {
                    let firstResult:NSTextCheckingResult? = results.first;
                    let typeString = TypeString();
                    var content = "";
                    if firstResult?.range.location == lastLocation {
                        let subString = text![text!.rangToIndex(rang: firstResult!.range)];
                        content = String(subString);
                        lastLocation = firstResult!.range.location+firstResult!.range.length;
                        results.remove(at: 0);
                        typeString.type = .Number;
                    }else{
                        let rang:NSRange = NSRange.init(location: lastLocation, length: (firstResult != nil ? (firstResult!.range.location-lastLocation):(text!.count - lastLocation)));
                        let subString =  text![text!.rangToIndex(rang: rang)]
                        content = String(subString);
                        lastLocation = firstResult?.range.location ?? text!.count;
                        typeString.type = .Other;
                    }
                    typeString.string = content;
                    
                    stringArray.append(typeString);
                }
            }
            return stringArray;
        }else{
            return [];
        }
    }
}

//MARK: - UITextField输入
private var textFieldIsCheckPriceKey: Void?
private var textFieldIsCheckPhone: Void?
private var textFieldNoPastingKey: Void?
private var textFieldDecimalPointLengthKey: Void?
private var textFieldOriginalStringKey: Void?
 
extension UITextField{
    //TODO: 原来的字符串
    private var originalString : String?{
        set {
            objc_setAssociatedObject(self, &textFieldOriginalStringKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &textFieldOriginalStringKey) as? String;
        }
    };
    
    //TODO: 是否检查价格
    @IBInspectable open var isCheckPrice: Bool{
        set {
            self.keyboardType = newValue ? .decimalPad : .default;
            if newValue {
                self.addTarget(self, action: #selector(textDidChanged(textField:)), for: .editingChanged)
            }
            objc_setAssociatedObject(self, &textFieldIsCheckPriceKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            if self.text != nil {
                self.cText = self.originalString;
            }
        }
        get {
            return (objc_getAssociatedObject(self, &textFieldIsCheckPriceKey) as? Bool) ?? false;
        }
    }
    //TODO: 是否检查手机号码
    @IBInspectable open var isCheckPhone: Bool{
        set {
            self.keyboardType = newValue ? .numberPad : .default;
            if newValue {
                self.addTarget(self, action: #selector(textDidChanged(textField:)), for: .editingChanged)
            }
            objc_setAssociatedObject(self, &textFieldIsCheckPhone, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &textFieldIsCheckPhone) as? Bool) ?? false;
        }
    }
    
    //TODO: 限制小数位长度，默认2位
    @IBInspectable open var decimalPointLength: Int16 {
        set {
            objc_setAssociatedObject(self, &textFieldDecimalPointLengthKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            if self.isCheckPrice && self.text != nil {
                self.cText = self.originalString;
            }
        }
        get {
            return (objc_getAssociatedObject(self, &textFieldDecimalPointLengthKey) as? Int16) ?? 2;
        }
    }
    
    //TODO: 字符串入口
    @IBInspectable open var cText: String? {
        set {
            self.originalString = newValue;
            if self.isCheckPrice {
                self.text = newValue?.checkZero(scale: self.decimalPointLength);
            }else{
                self.text = newValue
            }
        }
        get{
            return self.text;
        }
    }
   
    //TODO: 是否禁止粘贴，默认否
    @IBInspectable open var noPasting: Bool{
        set {
            objc_setAssociatedObject(self, &textFieldNoPastingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &textFieldNoPastingKey) as? Bool) ?? false;
        }
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return !self.noPasting;
        }else{
            return true;
        }
    }
    
    @objc private func textDidChanged(textField:UITextField){
        if self.isCheckPhone {
            if (textField.text?.count ?? 0 > 11) {
                let rang = textField.text!.rangToIndex(rang: NSRange.init(location: 0, length: 11))
                let subString = textField.text![rang];
                textField.text = String(subString);
            }
        }else if self.isCheckPrice {
            if let pointIndex = textField.text?.firstIndex(of: ".") {
                let pointStartIndex = textField.text!.index(pointIndex, offsetBy: 1);
                let subString:String! = String(textField.text![pointStartIndex ..< textField.text!.endIndex]);
                if subString.firstIndex(of: ".") != nil || subString.count > self.decimalPointLength{
                    let rang = textField.text!.rangToIndex(rang: NSRange.init(location: 0, length: textField.text!.count-1)) ;
                    textField.text = String(textField.text![rang]);
                }
            }
        }
    }
}

extension UIColor{
    
    /// 十六进制颜色
    /// - Parameters:
    ///   - value: 十六进制数字
    ///   - a: 透明度
    public static func hexa(value:Int32,a:CGFloat) ->UIColor {
        return UIColor.init(red: CGFloat((value & 0xFF0000) >> 16)/255.0, green: CGFloat((value & 0xFF00) >> 8)/255.0, blue: CGFloat(value & 0xFF)/255.0, alpha: a)
    }
    
    
    /// 颜色设置，兼容暗黑模式
    /// - Parameters:
    ///   - lightColor: 普通模式颜色
    ///   - darkColor: 暗黑模式颜色
    public static func color(lightColor:UIColor, darkColor:UIColor?) -> UIColor {
        if #available(iOS 13, *) {
            if darkColor != nil {
                let color = UIColor.init { (trainCollection) -> UIColor in
                    switch trainCollection.userInterfaceStyle{
                    case .light:
                        return lightColor;
                    case .dark:
                        return darkColor ?? lightColor;
                    default:
                        return lightColor;
                    }
                }
                return color
            }else{
                return lightColor;
            }
        }else{
            return lightColor;
        }
    }
}
