import Flutter
import UIKit
import WireGuardKit
import NetworkExtension
import os

public class SwiftWireguardDartPlugin: NSObject, FlutterPlugin {

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SwiftWireguardDartPlugin.self)
    )

    var bundleId: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "wireguard_dart", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "wireguard_dart_events", binaryMessenger: registrar.messenger())
        let streamHandler : WGEventChannel = WGEventChannel();
        eventChannel.setStreamHandler(streamHandler);
        let instance = SwiftWireguardDartPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "generateKeyPair":
            let privateKey = PrivateKey()
            let privateKeyResponse: [String: Any] = [
                "privateKey": privateKey.base64Key,
                "publicKey": privateKey.publicKey.base64Key,
            ]
            result(privateKeyResponse)
        case "setupTunnel":
            Self.logger.debug("handle setupTunnel")
            if let args = call.arguments as? Dictionary<String, Any>,
               let argBundleId = args["bundleId"] as? String {
                bundleId = argBundleId
            } else {
                result(FlutterError.init(code: "NATIVE_ERR", message: "required argument: 'bundleId'", details: nil))
                return
            }
            guard let bundleId else {
                Self.logger.error("Tunnel not initialized, missing 'bundleId'")
                result(FlutterError.init(code: "NATIVE_ERR", message: "tunnel not initialized, missing 'bundleId'", details: nil))
                return
            }
            Self.logger.debug("Tunnel bundle ID: \(bundleId)")
            Task {
                do {
                    _ = try await setupProviderManager(bundleId: bundleId)
                    Self.logger.debug("Tunnel setup OK")
                    result("")
                } catch {
                    Self.logger.error("Tunnel setup ERROR: \(error)")
                    result(
                        FlutterError.init(
                            code: "NATIVE_ERR", message: "could not setup VPN tunnel: \(error)", details: nil))
                    return
                }
            }
        case "connect":
            Self.logger.debug("handle connect")
            let cfg: String
            if let args = call.arguments as? Dictionary<String, Any>,
               let argCfg = args["cfg"] as? String {
                cfg = argCfg
            } else {
                Self.logger.error("Required argument 'cfg' not provided")
                result(FlutterError.init(code: "NATIVE_ERR", message: "required argument: 'cfg'", details: nil))
                return
            }
            Self.logger.debug("Connection configuration: \(cfg)")
            guard let bundleId else {
                Self.logger.error("Tunnel not initialized, missing 'bundleId'")
                result(FlutterError.init(code: "NATIVE_ERR", message: "tunnel not initialized, missing 'bundleId'", details: nil))
                return
            }
            Task {
                var mgr: NETunnelProviderManager
                do {
                    mgr = try await setupProviderManager(bundleId: bundleId)
                    Self.logger.debug("VPN tunnel provider OK")
                } catch {
                    Self.logger.error("Could not find VPN Tunnel provider: \(error)")
                    result(
                        FlutterError.init(
                            code: "NATIVE_ERR", message: "could not find VPN tunnel provider: \(error)",
                            details: nil))
                    return
                }
                do {
                    try mgr.connection.startVPNTunnel(options: [
                        "cfg": cfg as NSObject
                    ])
                    Self.logger.debug("Start VPN tunnel OK")
                    WGEventChannel.sendState(state: "connected")
                    result("")
                } catch {
                    Self.logger.error("Start VPN tunnel ERROR: \(error)")
                    result(
                        FlutterError.init(
                            code: "NATIVE_ERR", message: "could not start VPN tunnel: \(error)", details: nil))
                }
            }
        case "disconnect":
            Self.logger.debug("handle disconnect")
            guard let bundleId else {
                Self.logger.error("Required arg 'bundleId' not provided")
                result(FlutterError.init(code: "NATIVE_ERR", message: "tunnel not initialized, missing 'bundleId'", details: nil))
                return
            }
            Task {
                var mgr: NETunnelProviderManager
                do {
                    mgr = try await setupProviderManager(bundleId: bundleId)
                    Self.logger.debug("VPN tunnel provider OK")
                } catch {
                    Self.logger.error("Could not find VPN tunnel provider: \(error)")
                    result(
                        FlutterError.init(
                            code: "NATIVE_ERR", message: "could not find VPN tunnel provider: \(error)",
                            details: nil))
                    return
                }
                mgr.connection.stopVPNTunnel()
                Self.logger.debug("Stop tunnel OK")
                WGEventChannel.sendState(state: "disconnected")
                result("")
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func setupProviderManager(bundleId: String) async throws -> NETunnelProviderManager {
        let mgrs = await fetchManagers()
        let existingMgr = mgrs.first(where: { $0.localizedDescription == "Dostup VPN" })
        let mgr = existingMgr ?? NETunnelProviderManager()

        mgr.localizedDescription = "Dostup VPN"
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = bundleId
        proto.serverAddress = "91.217.153.6:34342"
        mgr.protocolConfiguration = proto
        mgr.isEnabled = true

        try await saveManager(mgr: mgr)
        return mgr
    }

    func fetchManagers() async -> [NETunnelProviderManager] {
        return await withCheckedContinuation { continuation in
            NETunnelProviderManager.loadAllFromPreferences { managers, error in
                continuation.resume(returning: (managers ?? []))
            }
        }
    }

    func saveManager(mgr: NETunnelProviderManager) async throws -> Void {
        return try await withCheckedThrowingContinuation { continuation in
            mgr.saveToPreferences { error in
                if let error: Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}



