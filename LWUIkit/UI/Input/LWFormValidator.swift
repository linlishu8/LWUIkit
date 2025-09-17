//
//  LWFormValidator.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：链式表单校验器（必填、长度、正则、邮箱、手机号、自定义）。
//  - 可单独校验字符串，也可绑定到 TextField/TextView 并自动设置校验状态。
//
//  用法：
//  ```swift
//  let v = LWFormValidator()
//      .required("请输入邮箱")
//      .email("邮箱格式不正确")
//  let r = v.validate(tf.text)
//  tf.validationState = r.asValidationState()
//
//  // 多字段
//  let form = LWFormGroup().add(tf, v).add(tv, v2)
//  let ok = form.validateAll()
//  ```
//

import UIKit

public enum LWRule {
    case required(message: String)
    case minLength(Int, message: String)
    case maxLength(Int, message: String)
    case lengthRange(Int, Int, message: String)
    case regex(NSRegularExpression, message: String)
    case email(message: String)
    case phone(message: String)        // 简化的手机校验
    case custom((String) -> Bool, message: String)
}

public enum LWValidateResult: Equatable {
    case valid
    case invalid(message: String)

    public func asValidationState() -> LWValidationState {
        switch self {
        case .valid: return .success(nil)
        case .invalid(let m): return .error(m)
        }
    }
}

public final class LWFormValidator {
    private var rules: [LWRule] = []
    public init() {}

    @discardableResult public func required(_ msg: String = "必填") -> LWFormValidator {
        rules.append(.required(message: msg)); return self
    }
    @discardableResult public func minLength(_ n: Int, _ msg: String = "长度不足") -> LWFormValidator {
        rules.append(.minLength(n, message: msg)); return self
    }
    @discardableResult public func maxLength(_ n: Int, _ msg: String = "长度过长") -> LWFormValidator {
        rules.append(.maxLength(n, message: msg)); return self
    }
    @discardableResult public func lengthRange(_ min: Int, _ max: Int, _ msg: String = "长度不合法") -> LWFormValidator {
        rules.append(.lengthRange(min, max, message: msg)); return self
    }
    @discardableResult public func regex(_ pattern: String, _ msg: String = "格式不匹配") -> LWFormValidator {
        let re = try? NSRegularExpression(pattern: pattern, options: [])
        if let re = re { rules.append(.regex(re, message: msg)) }
        return self
    }
    @discardableResult public func email(_ msg: String = "邮箱格式不正确") -> LWFormValidator {
        // RFC 完整很复杂，这里采用较稳妥的通用匹配
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return regex(pattern, msg)
    }
    @discardableResult public func phone(_ msg: String = "手机号格式不正确") -> LWFormValidator {
        // 简化：以 7~15 位数字（可含空格/横杠）为有效
        rules.append(.custom({ s in
            let digits = s.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            return digits.count >= 7 && digits.count <= 15
        }, message: msg)); return self
    }
    @discardableResult public func custom(_ test: @escaping (String) -> Bool, _ msg: String = "不符合要求") -> LWFormValidator {
        rules.append(.custom(test, message: msg)); return self
    }

    public func validate(_ text: String?) -> LWValidateResult {
        let s = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        for rule in rules {
            switch rule {
            case .required(let m):
                if s.isEmpty { return .invalid(message: m) }
            case .minLength(let n, let m):
                if s.count < n { return .invalid(message: m) }
            case .maxLength(let n, let m):
                if s.count > n { return .invalid(message: m) }
            case .lengthRange(let min, let max, let m):
                if s.count < min || s.count > max { return .invalid(message: m) }
            case .regex(let re, let m):
                let range = NSRange(location: 0, length: (s as NSString).length)
                if re.firstMatch(in: s, options: [], range: range) == nil { return .invalid(message: m) }
            case .email(let m):
                let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
                if s.range(of: pattern, options: .regularExpression) == nil { return .invalid(message: m) }
            case .phone(let m):
                let digits = s.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                if digits.count < 7 || digits.count > 15 { return .invalid(message: m) }
            case .custom(let block, let m):
                if !block(s) { return .invalid(message: m) }
            }
        }
        return .valid
    }
}

/// 简单的多字段管理
public final class LWFormGroup {
    private var entries: [(UIView, () -> LWValidateResult, (LWValidateResult) -> Void)] = []
    public init() {}
    @discardableResult public func add(_ field: LWTextField, _ validator: LWFormValidator) -> LWFormGroup {
        entries.append((field, { validator.validate(field.text) }, { result in field.validationState = result.asValidationState() })); return self
    }
    @discardableResult public func add(_ field: LWTextView, _ validator: LWFormValidator) -> LWFormGroup {
        entries.append((field, { validator.validate(field.text) }, { result in field.validationState = result.asValidationState() })); return self
    }
    public func validateAll() -> Bool {
        var ok = true
        for e in entries {
            let r = e.1()
            e.2(r)
            if case .invalid = r { ok = false }
        }
        return ok
    }
}
