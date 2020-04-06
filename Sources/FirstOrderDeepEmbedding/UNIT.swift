import Foundation

public final class UNIT : ASort {
    
    private class H : SortMakingHelper {
        
        var C_unit : ConstName!
        var T_unit : Term!
        
        init() {
            super.init("UNIT")
            (C_unit, T_unit) = add(name: "unit", result: sortname)
        }
        
    }
    
    private static let h = H()
            
    public struct Native : Hashable {}
        
    public required init() {
        super.init()
    }
    
    public override func setDefaultInhabitant() {
        set(inhabitant: UNIT.h.T_unit)
    }
        
    public override func isValid(nativeValue : Any) -> Bool {
        return nativeValue is Native
    }

    override public var sortname : SortName {
        return UNIT.h.sortname
    }
        
    override public var constants : [ConstName : Signature] {
        return UNIT.h.constants
    }
    
    override public func eval(name : ConstName, count : Int, nativeArgs : (Int) -> AnyHashable) -> AnyHashable {
        return Native()
    }
    
    public static let unit = UNIT(inhabitant: UNIT.h.T_unit)
    
    public static let singleton = Native()
    
}
