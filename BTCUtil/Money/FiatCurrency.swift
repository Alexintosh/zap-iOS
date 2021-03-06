//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public struct FiatCurrency: Currency, Equatable, Codable {
    public let currencyCode: String
    public let symbol: String
    public let localized: String
    public let exchangeRate: Decimal
    
    private var currencyFormatter: NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.generatesDecimalNumbers = true
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.autoupdatingCurrent
        currencyFormatter.currencyCode = currencyCode
        return currencyFormatter
    }
    
    public init(currencyCode: String, symbol: String, localized: String, exchangeRate: Decimal) {
        self.currencyCode = currencyCode
        self.symbol = symbol
        self.localized = localized
        self.exchangeRate = exchangeRate
    }
    
    private func format(value: NSDecimalNumber) -> String? {
        if value == NSDecimalNumber.notANumber {
            return currencyFormatter.string(from: 0)
        } else {
            return currencyFormatter.string(from: value)
        }
    }
    
    public func format(satoshis: Satoshi) -> String? {
        if !satoshis.isNormal {
            return format(value: 0)
        } else {
            let fiatValue = satoshis.convert(to: .bitcoin) * exchangeRate
            return format(value: fiatValue as NSDecimalNumber)
        }
    }
    
    public func satoshis(from string: String) -> Satoshi? {
        let numberFormatter = NumberFormatter()
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .decimal
        
        guard let fiatValue = (numberFormatter.number(from: string)) as? NSDecimalNumber else { return nil }
        return Satoshi.from(value: fiatValue.decimalValue / exchangeRate, unit: .bitcoin)
    }
    
    public func value(satoshis: Satoshi) -> Decimal? {
        return satoshis.multiplying(byPowerOf10: -BitcoinUnit.bitcoin.exponent) * exchangeRate
    }
    
    public func stringValue(satoshis: Satoshi) -> String? {
        guard let value = self.value(satoshis: satoshis) else { return nil }
        
        let valueFormatter = NumberFormatter()
        valueFormatter.maximumFractionDigits = 2
        valueFormatter.usesGroupingSeparator = false
        
        return valueFormatter.string(from: value as NSDecimalNumber)
    }
}
