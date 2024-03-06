extends Object
class_name FTimer

var tick: float
var timer: float = 0
var _done := false

func _init(_tick: float, a_done := false) -> void:
    tick = _tick
    _done = a_done

func progress() -> float:
    return timer/tick

func finish():
    _done = true
    timer = tick
    
func start(a_done := false) -> void:
    timer = 0
    _done = a_done
func step(delta: float) -> bool:
    if _done: return false
    _done = false
    timer += delta
    if timer >= tick:
        _done = true
        return true
    return false
    
func done() -> bool:
    return _done