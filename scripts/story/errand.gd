class_name Errand extends RefCounted

class NoErrand extends Errand:
	func is_done() -> bool:
		assert(false)
		return false
		
var _is_done = false
var playwright: Playwright

func force_complete():
	_is_done = true
	
func is_done() -> bool:
	return _is_done
	
func complete():
	assert(playwright)
	playwright.play()
