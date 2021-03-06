//
//  VideoSource.swift
//  Atem
//
//  Created by Damiaan on 26/05/18.
//

import Foundation

/// A unique identifier for a video source of an ATEM switcher
public enum VideoSource: RawRepresentable {
	public typealias RawValue = UInt16

	case black
	case input(UInt16)
	case colorBars
	case color(UInt16)
	case mediaPlayer(UInt16)
	case mediaPlayerKey(UInt16)
	case keyMask(UInt16)
	case downStreamKeyMask(UInt16)
	case superSource
	case cleanFeed(UInt16)
	case auxiliary(UInt16)
	case program(me: UInt16)
	case preview(me: UInt16)

	public init?(rawValue: UInt16) {
		switch rawValue {
		case Base.black.rawValue:
			self = .black
		case .input ..< .colorBars:
			self = .input(rawValue - .input)
		case Base.colorBars.rawValue:
			self = .colorBars
		case .color ..< .mediaPlayer:
			self = .color(rawValue - .color)
		case .mediaPlayer ..< .keyMask:
			let division = div(Int32(rawValue - .mediaPlayer), 10)
			switch division.rem {
			case 0: self = .mediaPlayer(UInt16(division.quot))
			case 1: self = .mediaPlayerKey(UInt16(division.quot))
			default: return nil
			}
		case .keyMask ..< .downStreamKeyMask:
			guard rawValue % 10 == 0 else { return nil }
			self = .keyMask((rawValue - .keyMask) / 10)
		case .downStreamKeyMask ..< .superSource:
			guard rawValue % 10 == 0 else { return nil }
			self = .downStreamKeyMask( (rawValue - .downStreamKeyMask) / 10 )
		case Base.superSource.rawValue:
			self = .superSource
		case .cleanFeed ..< .auxiliary:
			self = .cleanFeed(rawValue - .cleanFeed)
		case .auxiliary ..< .program:
			self = .auxiliary(rawValue - .auxiliary)
		case Base.program.rawValue...:
			let division = div(Int32(rawValue - .program), 10)
			switch division.rem {
			case 0: self = .program(me: UInt16(division.quot))
			case 1: self = .preview(me: UInt16(division.quot))
			default: return nil
			}
		default: return nil
		}
	}
	
	public var rawValue: UInt16 {
		switch self {
		case .black:                         return .black + 0
		case .input(let number):             return .input + number
		case .colorBars:                     return .colorBars + 0
		case .color(let number):             return .color + number
		case .mediaPlayer(let number):       return .mediaPlayer + number*10
		case .mediaPlayerKey(let number):    return .mediaPlayerKey + number*10
		case .keyMask(let number):           return .keyMask + number*10
		case .downStreamKeyMask(let number): return .downStreamKeyMask + number*10
		case .superSource:                   return .superSource + 0
		case .cleanFeed(let number):         return .cleanFeed + number
		case .auxiliary(let number):         return .auxiliary + number
		case .program(let me):               return .program + me*10
		case .preview(let me):               return .preview + me*10
		}
	}
	
	enum Base: UInt16 {
		case black = 0
		case input = 1
		case colorBars = 1000
		case color = 2001
		case mediaPlayer = 3010
		case mediaPlayerKey = 3011
		case keyMask = 4010
		case downStreamKeyMask = 5010
		case superSource = 6000
		case cleanFeed = 7001
		case auxiliary = 8001
		case program = 10_010
		case preview = 10_011

		static func + (left: Base, right: RawValue) -> RawValue {
			return left.rawValue + right
		}
		
		static func - (left: RawValue, right: Base) -> RawValue {
			return left - right.rawValue
		}
		
		static func ..< (lower: Base, upper: Base) -> CountableRange<RawValue> {
			return lower.rawValue ..< upper.rawValue
		}
	}
}

extension VideoSource: Hashable {
	public var hashValue: Int {
		return Int(rawValue)
	}
}
