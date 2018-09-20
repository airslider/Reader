import Foundation
import UIKit

internal func attributeAxis(_ attr: NSLayoutAttribute) -> UILayoutConstraintAxis {
    var ret: UILayoutConstraintAxis? = nil
    switch attr {
    case .left, .right, .width, .centerX, .leftMargin, .rightMargin, .centerXWithinMargins:
        ret = .horizontal
        
    case .top, .bottom, .height, .centerY, .lastBaseline, .firstBaseline, .topMargin, .bottomMargin, .centerYWithinMargins:
        ret = .vertical;
        
    default:
        assert(false, "Axis can not be determined for attribute: '\(attr)'")
    }
    return ret!
}

public struct LayoutPriority {
    public static let Required = UILayoutPriority(1000)
    public static let DefaultHigh = UILayoutPriority(750)
    public static let DefaultLow = UILayoutPriority(250)
    public static let FittingSizeLevel = UILayoutPriority(50)
    
    fileprivate init() {
        
    }
}

extension NSLayoutConstraint {
    
    @discardableResult
    public class func create(
        item view1: AnyObject,
             attribute attr1: NSLayoutAttribute,
                       relatedBy relation: NSLayoutRelation = NSLayoutRelation.equal,
                                 toItem view2: AnyObject? = nil,
                                        attribute attr2: NSLayoutAttribute = NSLayoutAttribute.notAnAttribute,
                                                  multiplier: CGFloat = 1.0,
                                                  constant c: CGFloat = 0) -> NSLayoutConstraint {
        
        return NSLayoutConstraint(
            item: view1,
            attribute: attr1,
            relatedBy: relation,
            toItem: view2,
            attribute: attr2,
            multiplier: multiplier,
            constant: c
        )
    }
    
}

extension UIView {
    
    @discardableResult
    public func addMargin(
        _ value: CGFloat, from: NSLayoutAttribute, to: NSLayoutAttribute, items: [UIView]) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for v in items {
            let constraint = NSLayoutConstraint(
                item: v, attribute: to, relatedBy: .equal,
                toItem: self, attribute: from, multiplier: 1.0,
                constant: value
            )
            ret.append(constraint)
            addConstraint(constraint)
        }
        return ret
    }
    
    @discardableResult
    public func addVerticalSpacing(_ value: CGFloat, items: [UIView]) -> [NSLayoutConstraint] {
        assert(items.count > 1)
        var ret = [NSLayoutConstraint]()
        for i in 1..<items.count {
            let constraint = NSLayoutConstraint(
                item: items[i], attribute: .top, relatedBy: .equal,
                toItem: items[i - 1], attribute: .bottom, multiplier: 1.0, constant: value
            )
            ret.append(constraint)
            addConstraint(constraint)
        }
        return ret
    }
    
    @discardableResult
    public func addMinimumVerticalSpacing(_ value: CGFloat, items: [UIView]) -> [NSLayoutConstraint] {
        assert(items.count > 1)
        var ret = [NSLayoutConstraint]()
        for i in 1..<items.count {
            let constraint = NSLayoutConstraint(
                item: items[i], attribute: .top, relatedBy: .greaterThanOrEqual,
                toItem: items[i - 1], attribute: .bottom, multiplier: 1.0, constant: value
            )
            ret.append(constraint)
            addConstraint(constraint)
        }
        return ret
    }
    
    @discardableResult
    public func addHorizontalSpacing(_ value: CGFloat, items: [UIView]) -> [NSLayoutConstraint] {
        assert(items.count > 1)
        var ret = [NSLayoutConstraint]()
        for i in 1..<items.count {
            let constraint = NSLayoutConstraint(
                item: items[i], attribute: .left, relatedBy: .equal,
                toItem:items[i - 1] , attribute: .right, multiplier: 1.0, constant: value
            )
            ret.append(constraint)
            addConstraint(constraint)
        }
        return ret
    }
    
    @discardableResult
    public func addMargin(_ value: CGFloat, from: NSLayoutAttribute, items: [UIView]) -> [NSLayoutConstraint] {
        return addMargin(value, from: from, to: from, items: items);
    }
    
    @discardableResult
    public func addCenterMargin(_ value: CGFloat, from: NSLayoutAttribute, items: [UIView]) -> [NSLayoutConstraint] {
        switch attributeAxis(from) {
        case .horizontal:
            return addMargin(value, from: from, to: .centerX, items: items)
            
        case .vertical:
            return addMargin(value, from: from, to: .centerY, items: items)
        }
    }
    
    @discardableResult
    public func addEquality(of attr: NSLayoutAttribute, items: [UIView]) -> [NSLayoutConstraint] {
        let first = items.first!
        var ret = [NSLayoutConstraint]()
        
        for i in 1..<items.count {
            let constraint = NSLayoutConstraint(
                item: items[i], attribute: attr, relatedBy: .equal,
                toItem: first, attribute: attr, multiplier: 1.0,
                constant: 0.0
            )
            addConstraint(constraint)
            ret.append(constraint)
        }
        return ret
    }
    
    @discardableResult
    public func addEqualityForItems(_ items: [UIView]) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        ret.append(contentsOf: addEquality(of: .left, items: items))
        ret.append(contentsOf: addEquality(of: .right, items: items))
        ret.append(contentsOf: addEquality(of: .top, items: items))
        ret.append(contentsOf: addEquality(of: .bottom, items: items))
        return ret
    }
    
    @discardableResult
    public func addDimension(_ value: CGFloat, attr: NSLayoutAttribute, items: [UIView]) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        
        for v in items {
            let constraint = NSLayoutConstraint(
                item: v, attribute: attr, relatedBy: .equal, toItem: nil,
                attribute: .notAnAttribute, multiplier: 1.0,
                constant: value
            )
            addConstraint(constraint)
            ret.append(constraint)
        }
        return ret
    }
    
    @discardableResult
    public func addWidth(_ value: CGFloat) -> NSLayoutConstraint {
        return addDimension(value, attr: .width, items: [self]).first!
    }
    
    @discardableResult
    public func addHeight(_ value: CGFloat) -> NSLayoutConstraint {
        return addDimension(value, attr: .height, items: [self]).first!
    }

    @discardableResult
    public func addSize(width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
        var  ret = [NSLayoutConstraint]()
        ret.append(addWidth(width))
        ret.append(addHeight(height))
        return ret
    }
    
    @discardableResult
    public func addSize(_ size: CGSize) -> [NSLayoutConstraint] {
        return addSize(width: size.width, height: size.height)
    }
    
    @discardableResult
    public func addConstraints( _ constraintsFormat: String,
                                  options: NSLayoutFormatOptions = NSLayoutFormatOptions(rawValue: 0),
                                  metrics:[String: CGFloat]? = nil,
                                  views: [String:UIView]) -> [NSLayoutConstraint]
    {
        
        var constraints: [NSLayoutConstraint] = []
        
        constraints = NSLayoutConstraint.constraints( withVisualFormat: constraintsFormat,
                                                                      options: options,
                                                                      metrics: metrics,
                                                                      views: views
        )
        
        self.addConstraints(constraints)
        
        return constraints
    }
    
    @discardableResult
    public func addConstraint(
        item: UIView,
             attribute: NSLayoutAttribute,
             relatedBy: NSLayoutRelation = NSLayoutRelation.equal,
             toItem: UIView? = nil,
             toAttribute: NSLayoutAttribute = NSLayoutAttribute.notAnAttribute,
             multiplier: CGFloat = 1.0,
             constant: CGFloat = 0.0,
             priority: UILayoutPriority = LayoutPriority.Required) -> NSLayoutConstraint
    {
        let ret = NSLayoutConstraint(
            item: item,
            attribute: attribute,
            relatedBy: relatedBy,
            toItem: toItem,
            attribute: toAttribute,
            multiplier: multiplier,
            constant: constant
        )
        ret.priority = priority
        addConstraint(ret)
        return ret
    }
    
    // MARK: layout in container
    
    @discardableResult
    public func fillContainerVertically() -> [NSLayoutConstraint] {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        return self.superview!.addConstraints("V:|[self]|", views: ["self": self])
    }
    
    @discardableResult
    public func fillContainerHorizontally() -> [NSLayoutConstraint] {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        return self.superview!.addConstraints("H:|[self]|", views: ["self": self])
    }
    
    @discardableResult
    public func fillContainer() -> [NSLayoutConstraint] {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        var constraints = [NSLayoutConstraint]()
        constraints = constraints + self.fillContainerVertically()
        constraints = constraints + self.fillContainerHorizontally()
        return constraints
    }
    
    @discardableResult
    public func centerHorizontallyInContainer() -> [NSLayoutConstraint]  {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        return self.superview!.addEquality(of: NSLayoutAttribute.centerX, items: [self, self.superview!])
    }
    
    @discardableResult
    public func centerVerticallyInContainer() -> [NSLayoutConstraint]  {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        return self.superview!.addEquality(of: NSLayoutAttribute.centerY, items: [self, self.superview!])
    }
    
    @discardableResult
    public func centerInContainer() -> [NSLayoutConstraint] {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        var constraints = [NSLayoutConstraint]()
        constraints = constraints + self.centerHorizontallyInContainer()
        constraints = constraints + self.centerVerticallyInContainer()
        return constraints
    }
    
    @discardableResult
    public func attachLeftInContainer(margin: CGFloat = 0) -> [NSLayoutConstraint] {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        return self.superview!.addMargin(margin, from: NSLayoutAttribute.left, items: [self])
    }
    
    @discardableResult
    public func attachRightInContainer(margin: CGFloat = 0) -> [NSLayoutConstraint] {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        return self.superview!.addMargin(-margin, from: NSLayoutAttribute.right, items: [self])
    }
    
    @discardableResult
    public func attachTopInContainer(margin: CGFloat = 0) -> [NSLayoutConstraint] {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        return self.superview!.addMargin(margin, from: NSLayoutAttribute.top, items: [self])
    }
    
    @discardableResult
    public func attachBottomInContainer(margin: CGFloat = 0) -> [NSLayoutConstraint] {
        assert(self.superview != nil && self.translatesAutoresizingMaskIntoConstraints == false)
        return self.superview!.addMargin(-margin, from: NSLayoutAttribute.bottom, items: [self])
    }
    
}
