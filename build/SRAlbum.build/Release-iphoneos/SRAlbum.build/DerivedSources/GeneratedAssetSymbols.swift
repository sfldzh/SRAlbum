import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "adjustment" asset catalog image resource.
    static let adjustment = ImageResource(name: "adjustment", bundle: resourceBundle)

    /// The "aspectratio" asset catalog image resource.
    static let aspectratio = ImageResource(name: "aspectratio", bundle: resourceBundle)

    /// The "blur" asset catalog image resource.
    static let blur = ImageResource(name: "blur", bundle: resourceBundle)

    /// The "brightness" asset catalog image resource.
    static let brightness = ImageResource(name: "brightness", bundle: resourceBundle)

    /// The "check" asset catalog image resource.
    static let check = ImageResource(name: "check", bundle: resourceBundle)

    /// The "color" asset catalog image resource.
    static let color = ImageResource(name: "color", bundle: resourceBundle)

    /// The "contrast" asset catalog image resource.
    static let contrast = ImageResource(name: "contrast", bundle: resourceBundle)

    /// The "fade" asset catalog image resource.
    static let fade = ImageResource(name: "fade", bundle: resourceBundle)

    /// The "highlights" asset catalog image resource.
    static let highlights = ImageResource(name: "highlights", bundle: resourceBundle)

    /// The "magic" asset catalog image resource.
    static let magic = ImageResource(name: "magic", bundle: resourceBundle)

    /// The "mask" asset catalog image resource.
    static let mask = ImageResource(name: "mask", bundle: resourceBundle)

    /// The "rotate" asset catalog image resource.
    static let rotate = ImageResource(name: "rotate", bundle: resourceBundle)

    /// The "saturation" asset catalog image resource.
    static let saturation = ImageResource(name: "saturation", bundle: resourceBundle)

    /// The "shadows" asset catalog image resource.
    static let shadows = ImageResource(name: "shadows", bundle: resourceBundle)

    /// The "sharpen" asset catalog image resource.
    static let sharpen = ImageResource(name: "sharpen", bundle: resourceBundle)

    /// The "slider_thumb" asset catalog image resource.
    static let sliderThumb = ImageResource(name: "slider_thumb", bundle: resourceBundle)

    /// The "structure" asset catalog image resource.
    static let structure = ImageResource(name: "structure", bundle: resourceBundle)

    /// The "temperature" asset catalog image resource.
    static let temperature = ImageResource(name: "temperature", bundle: resourceBundle)

    /// The "vignette" asset catalog image resource.
    static let vignette = ImageResource(name: "vignette", bundle: resourceBundle)

}

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif