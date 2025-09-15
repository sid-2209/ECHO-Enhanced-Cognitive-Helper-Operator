import AppKit
import Carbon

class HotKeyManager {
    static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private let hotKeySignature: FourCharCode = 0x6563686F // 'echo'
    private let hotKeyID: UInt32 = 1

    private init() {}

    func registerGlobalHotKey() {
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
        let keyCode: UInt32 = 14 // 'E' key

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))

        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(theEvent, OSType(kEventParamDirectObject), OSType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)

            if hotKeyID.signature == HotKeyManager.shared.hotKeySignature && hotKeyID.id == HotKeyManager.shared.hotKeyID {
                DispatchQueue.main.async {
                    WindowManager.shared.toggleWindow()
                }
            }

            return noErr
        }, 1, &eventType, nil, nil)

        var hotKeyID = EventHotKeyID(signature: hotKeySignature, id: hotKeyID)
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    func unregisterGlobalHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }

    deinit {
        unregisterGlobalHotKey()
    }
}