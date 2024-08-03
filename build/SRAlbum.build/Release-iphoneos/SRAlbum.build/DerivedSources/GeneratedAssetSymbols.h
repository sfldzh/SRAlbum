#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "adjustment" asset catalog image resource.
static NSString * const ACImageNameAdjustment AC_SWIFT_PRIVATE = @"adjustment";

/// The "aspectratio" asset catalog image resource.
static NSString * const ACImageNameAspectratio AC_SWIFT_PRIVATE = @"aspectratio";

/// The "blur" asset catalog image resource.
static NSString * const ACImageNameBlur AC_SWIFT_PRIVATE = @"blur";

/// The "brightness" asset catalog image resource.
static NSString * const ACImageNameBrightness AC_SWIFT_PRIVATE = @"brightness";

/// The "check" asset catalog image resource.
static NSString * const ACImageNameCheck AC_SWIFT_PRIVATE = @"check";

/// The "color" asset catalog image resource.
static NSString * const ACImageNameColor AC_SWIFT_PRIVATE = @"color";

/// The "contrast" asset catalog image resource.
static NSString * const ACImageNameContrast AC_SWIFT_PRIVATE = @"contrast";

/// The "fade" asset catalog image resource.
static NSString * const ACImageNameFade AC_SWIFT_PRIVATE = @"fade";

/// The "highlights" asset catalog image resource.
static NSString * const ACImageNameHighlights AC_SWIFT_PRIVATE = @"highlights";

/// The "magic" asset catalog image resource.
static NSString * const ACImageNameMagic AC_SWIFT_PRIVATE = @"magic";

/// The "mask" asset catalog image resource.
static NSString * const ACImageNameMask AC_SWIFT_PRIVATE = @"mask";

/// The "rotate" asset catalog image resource.
static NSString * const ACImageNameRotate AC_SWIFT_PRIVATE = @"rotate";

/// The "saturation" asset catalog image resource.
static NSString * const ACImageNameSaturation AC_SWIFT_PRIVATE = @"saturation";

/// The "shadows" asset catalog image resource.
static NSString * const ACImageNameShadows AC_SWIFT_PRIVATE = @"shadows";

/// The "sharpen" asset catalog image resource.
static NSString * const ACImageNameSharpen AC_SWIFT_PRIVATE = @"sharpen";

/// The "slider_thumb" asset catalog image resource.
static NSString * const ACImageNameSliderThumb AC_SWIFT_PRIVATE = @"slider_thumb";

/// The "structure" asset catalog image resource.
static NSString * const ACImageNameStructure AC_SWIFT_PRIVATE = @"structure";

/// The "temperature" asset catalog image resource.
static NSString * const ACImageNameTemperature AC_SWIFT_PRIVATE = @"temperature";

/// The "vignette" asset catalog image resource.
static NSString * const ACImageNameVignette AC_SWIFT_PRIVATE = @"vignette";

#undef AC_SWIFT_PRIVATE
