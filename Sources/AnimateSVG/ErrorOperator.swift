import Foundation

// Define a custom precedence group
precedencegroup CustomPrecedence {
	// So both operators can be in single group
	associativity: left
	// Make sure can set variables to returned value
	higherThan: DefaultPrecedence
}

infix operator ?!: CustomPrecedence
public func ?!<T>(lhs: T?, rhs: T) -> (T, Bool) {
	(lhs ?? rhs, lhs == nil)
}

infix operator ~>: CustomPrecedence
public func ~><T>(lhs: (T, Bool), rhs: String) -> T {
	let (value, condition) = lhs
	if condition {
		print(rhs)
	}
	return value
}
