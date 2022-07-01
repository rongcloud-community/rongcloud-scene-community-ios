// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let black000000 = ColorAsset(name: "black000000")
    internal static let black020037 = ColorAsset(name: "black020037")
    internal static let black111F2C = ColorAsset(name: "black111F2C")
    internal static let black282828 = ColorAsset(name: "black282828")
    internal static let black313131 = ColorAsset(name: "black313131")
    internal static let black363636 = ColorAsset(name: "black363636")
    internal static let black838383 = ColorAsset(name: "black838383")
    internal static let black949494 = ColorAsset(name: "black949494")
    internal static let blue0099FF = ColorAsset(name: "blue0099FF")
    internal static let blue667C8A = ColorAsset(name: "blue667C8A")
    internal static let blue72BEF8 = ColorAsset(name: "blue72BEF8")
    internal static let blue7983FE = ColorAsset(name: "blue7983FE")
    internal static let blueA0D9FF = ColorAsset(name: "blueA0D9FF")
    internal static let blueE1F3FF = ColorAsset(name: "blueE1F3FF")
    internal static let gray7A808E = ColorAsset(name: "gray7A808E")
    internal static let gray8E8E8E = ColorAsset(name: "gray8E8E8E")
    internal static let grayA0A5AB = ColorAsset(name: "grayA0A5AB")
    internal static let grayB4B4B4 = ColorAsset(name: "grayB4B4B4")
    internal static let grayBEBEBE = ColorAsset(name: "grayBEBEBE")
    internal static let grayC1C1C1 = ColorAsset(name: "grayC1C1C1")
    internal static let grayC4C4C4 = ColorAsset(name: "grayC4C4C4")
    internal static let grayC8CCD4 = ColorAsset(name: "grayC8CCD4")
    internal static let grayDBDBDB = ColorAsset(name: "grayDBDBDB")
    internal static let grayE3E5E6 = ColorAsset(name: "grayE3E5E6")
    internal static let grayE5E8EF = ColorAsset(name: "grayE5E8EF")
    internal static let grayEAEAEA = ColorAsset(name: "grayEAEAEA")
    internal static let grayEDEDED = ColorAsset(name: "grayEDEDED")
    internal static let grayF1F1F1 = ColorAsset(name: "grayF1F1F1")
    internal static let grayF3F3F3 = ColorAsset(name: "grayF3F3F3")
    internal static let grayF3F4F5 = ColorAsset(name: "grayF3F4F5")
    internal static let grayF4F6FA = ColorAsset(name: "grayF4F6FA")
    internal static let grayF6F6F6 = ColorAsset(name: "grayF6F6F6")
    internal static let green55BD53 = ColorAsset(name: "green55BD53")
    internal static let green74E971 = ColorAsset(name: "green74E971")
    internal static let pinkF31D8A = ColorAsset(name: "pinkF31D8A")
    internal static let redD43030 = ColorAsset(name: "redD43030")
    internal static let redD96565 = ColorAsset(name: "redD96565")
    internal static let redED8CAA = ColorAsset(name: "redED8CAA")
    internal static let redF31D8A = ColorAsset(name: "redF31D8A")
    internal static let whiteF5F6F9 = ColorAsset(name: "whiteF5F6F9")
    internal static let whiteFAFAFA = ColorAsset(name: "whiteFAFAFA")
    internal static let whiteFFFFFF = ColorAsset(name: "whiteFFFFFF")
  }
  internal enum Images {
    internal static let arrowIcon = ImageAsset(name: "arrow_icon")
    internal static let bigGrayHashtagIcon = ImageAsset(name: "big_gray_hashtag_icon")
    internal static let bigHashtagIcon = ImageAsset(name: "big_hashtag_icon")
    internal static let bigIcon = ImageAsset(name: "big_icon")
    internal static let cameraIcon = ImageAsset(name: "camera_icon")
    internal static let channelCloseIcon = ImageAsset(name: "channel_close_icon")
    internal static let channelDailyIcon = ImageAsset(name: "channel_daily_icon")
    internal static let channelGroupAddIcon = ImageAsset(name: "channel_group_add_icon")
    internal static let channelHashtagIcon = ImageAsset(name: "channel_hashtag_icon")
    internal static let channelOpenIcon = ImageAsset(name: "channel_open_icon")
    internal static let channelSpeakerIcon = ImageAsset(name: "channel_speaker_icon")
    internal static let communityAdd = ImageAsset(name: "community_add")
    internal static let communityMgrIcon = ImageAsset(name: "community_mgr_icon")
    internal static let communityNotiIcon = ImageAsset(name: "community_noti_icon")
    internal static let additionImage = ImageAsset(name: "addition_image")
    internal static let additionVideo = ImageAsset(name: "addition_video")
    internal static let coversationEmpty = ImageAsset(name: "coversation_empty")
    internal static let emoji = ImageAsset(name: "emoji")
    internal static let messageConversationMore = ImageAsset(name: "message_conversation_more")
    internal static let messageCopy = ImageAsset(name: "message_copy")
    internal static let messageDelete = ImageAsset(name: "message_delete")
    internal static let messageDeleteIcon = ImageAsset(name: "message_delete_icon")
    internal static let messageEdit = ImageAsset(name: "message_edit")
    internal static let messageEditIcon = ImageAsset(name: "message_edit_icon")
    internal static let messageJumpToUnread = ImageAsset(name: "message_jump_to_unread")
    internal static let messageMark = ImageAsset(name: "message_mark")
    internal static let messageMarkDeleteIcon = ImageAsset(name: "message_mark_delete_icon")
    internal static let messageMarkHubIcon = ImageAsset(name: "message_mark_hub_icon")
    internal static let messagePlay = ImageAsset(name: "message_play")
    internal static let messageQuote = ImageAsset(name: "message_quote")
    internal static let messageQuoteIcon = ImageAsset(name: "message_quote_icon")
    internal static let messageRecall = ImageAsset(name: "message_recall")
    internal static let messageScorllToBottom = ImageAsset(name: "message_scorll_to_bottom")
    internal static let messageSendFail = ImageAsset(name: "message_send_fail")
    internal static let messageSystemAvatar = ImageAsset(name: "message_system_avatar")
    internal static let messageUserArrow = ImageAsset(name: "message_user_arrow")
    internal static let plugin = ImageAsset(name: "plugin")
    internal static let createCommunityIcon = ImageAsset(name: "create_community_icon")
    internal static let defaultAvatarIcon = ImageAsset(name: "default_avatar_icon")
    internal static let deleteIcon = ImageAsset(name: "delete_icon")
    internal static let discoverEmptyIcon = ImageAsset(name: "discover_empty_icon")
    internal static let discoverIcon = ImageAsset(name: "discover_icon")
    internal static let editIcon = ImageAsset(name: "edit_icon")
    internal static let femaleIcon = ImageAsset(name: "female_icon")
    internal static let lockIcon = ImageAsset(name: "lock_icon")
    internal static let maleIcon = ImageAsset(name: "male_icon")
    internal static let menuIcon = ImageAsset(name: "menu_icon")
    internal static let moreIcon = ImageAsset(name: "more_icon")
    internal static let naviBackIcon = ImageAsset(name: "navi_back_icon")
    internal static let notifySettingNormalIcon = ImageAsset(name: "notify_setting_normal_icon")
    internal static let notifySettingSelectedIcon = ImageAsset(name: "notify_setting_selected_icon")
    internal static let postIcon = ImageAsset(name: "post_icon")
    internal static let profileFemaleNormalIcon = ImageAsset(name: "profile_female_normal_icon")
    internal static let profileFemaleSelectedIcon = ImageAsset(name: "profile_female_selected_icon")
    internal static let profileLogoIcon = ImageAsset(name: "profile_logo_icon")
    internal static let profileMaleNormalIcon = ImageAsset(name: "profile_male_normal_icon")
    internal static let profileMaleSelectedIcon = ImageAsset(name: "profile_male_selected_icon")
    internal static let speakerIcon = ImageAsset(name: "speaker_icon")
    internal static let sysnoticeInfoIcon = ImageAsset(name: "sysnotice_info_icon")
    internal static let userListMoreIcon = ImageAsset(name: "user_list_more_icon")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = RCSCBundle.sharedBundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = RCSCBundle.sharedBundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = RCSCBundle.sharedBundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = RCSCBundle.sharedBundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = RCSCBundle.sharedBundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
