import Flutter
import UIKit
import WireGuardKit
import NetworkExtension
import os

public enum TunnelConfError : Error {
    case invalidConfig
    case nullPointer
}

extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.com.dostupvpn")
}

public class SwiftWireguardDartPlugin: NSObject, FlutterPlugin {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SwiftWireguardDartPlugin.self)
    )
    
    var bundleId: String?
    var tunnelConfig: Dictionary<String, Any>?
    
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
            
        // Генерация ключей
        case "generateKeyPair":
            let privateKey = PrivateKey()
            let privateKeyResponse: [String: Any] = [
                "privateKey": privateKey.base64Key,
                "publicKey": privateKey.publicKey.base64Key,
            ]
            result(privateKeyResponse)
        
        // Установка конфигурации туннеля
        case "setupTunnel":
            Self.logger.debug("handle setupTunnel")
            if let args = call.arguments as? Dictionary<String, Any>,
               let argBundleId = args["bundleId"] as? String,
            let argTunnelConfig = args["cfg"] as? Dictionary<String, Any> {
                bundleId = argBundleId
                tunnelConfig = argTunnelConfig
            } else {
                result(FlutterError.init(code: "NATIVE_ERR", message: "required argument: 'bundleId'", details: nil))
                return
            }
            guard let bundleId else {
                Self.logger.error("Tunnel not initialized, missing 'bundleId'")
                result(FlutterError.init(code: "NATIVE_ERR", message: "tunnel not initialized, missing 'bundleId'", details: nil))
                return
            }
            guard let tunnelConfig else {
                Self.logger.error("Tunnel not initialized, missing 'tunnelConfig'")
                result(FlutterError.init(code: "NATIVE_ERR", message: "tunnel not initialized, missing 'tunnelConfig'", details: nil))
                return
            }
            Self.logger.debug("Tunnel bundle ID: \(bundleId)")
            Task {
                do {
                    _ = try await setupProviderManager(bundleId: bundleId, cfg: tunnelConfig)
                    Self.logger.debug("Tunnel setup OK")
                    result("")
                }
                catch {
                    Self.logger.error("Tunnel setup ERROR: \(error)")
                    result(
                        FlutterError.init(
                            code: "NATIVE_ERR", message: "could not setup VPN tunnel: \(error)", details: nil))
                    return
                }
            }
        
        // Подключение
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
            guard let tunnelConfig else {
                Self.logger.error("Tunnel not initialized, missing 'tunnel config'")
                result(FlutterError.init(code: "NATIVE_ERR", message: "tunnel not initialized, missing 'tunnel config'", details: nil))
                return
            }
            Task {
                var mgr: NETunnelProviderManager
                do {
                    mgr = try await setupProviderManager(bundleId: bundleId, cfg: tunnelConfig)
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
            guard let tunnelConfig else {
                Self.logger.error("Required arg 'tunnelConfig' not provided")
                result(FlutterError.init(code: "NATIVE_ERR", message: "tunnel not initialized, missing 'tunnelConfig'", details: nil))
                return
            }
            Task {
                var mgr: NETunnelProviderManager
                do {
                    mgr = try await setupProviderManager(bundleId: bundleId, cfg: tunnelConfig)
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
                result("")
            }
            
            
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func setupProviderManager(bundleId: String, cfg: Dictionary<String, Any>) async throws -> NETunnelProviderManager {
        let mgrs = await fetchManagers()
        let existingMgr = mgrs.first(where: { $0.localizedDescription == "VPN Dostup" })
        let mgr = existingMgr ?? NETunnelProviderManager()
        
        mgr.localizedDescription = "VPN Dostup"
        
        guard let tunnelConfig else {
            Self.logger.error("Required arg 'tunnelConfig' not provided")
            throw TunnelConfError.nullPointer
        }
        
        let interface = cfg["interface"] as? Dictionary<String, String>
        let peer = cfg["peer"] as? Dictionary<String, String>
        
        guard let interface else {
            Self.logger.error("Required arg 'tunnelConfig.interface' not provided")
            throw TunnelConfError.nullPointer
        }
        
        guard let peer else {
            Self.logger.error("Required arg 'tunnelConfig.peer' not provided")
            throw TunnelConfError.nullPointer
        }
        
        let privateKey = interface["privateKey"]
        let address = interface["address"]
        let dns = interface["dns"]
        
        let publicKey : String? = peer["publicKey"]
        let allowedIps : String? = peer["allowedIps"]
        let endpoint : String? = peer["endpoint"]
        
        Self.logger.debug("Private key: \(privateKey ?? "null")")
        Self.logger.debug("Address: \(address ?? "null")")
        Self.logger.debug("Dns: \(dns ?? "null")")
        Self.logger.debug("Public key: \(publicKey ?? "null")")
        Self.logger.debug("Allowed Ips: \(allowedIps ?? "null")")
        Self.logger.debug("Endpoint key: \(endpoint ?? "null")")
        
        var interfaceConf = InterfaceConfiguration(privateKey: PrivateKey(base64Key: privateKey!)!)
        interfaceConf.addresses = [IPAddressRange(from: address!)!]
        interfaceConf.dns = [DNSServer(address: IPv4Address(dns!)!)]
        
        var peerConf = PeerConfiguration(publicKey: PublicKey(base64Key: publicKey!)!)
        peerConf.allowedIPs = [IPAddressRange(from: allowedIps!)!]
        peerConf.endpoint = Endpoint(from: endpoint!)
        
        let tunnelConfiguration = TunnelConfiguration(name: bundleId, interface: interfaceConf, peers: [peerConf])
        
        let proto = NETunnelProviderProtocol(tunnelConfiguration: tunnelConfiguration)!
        proto.providerBundleIdentifier = bundleId
        
        mgr.protocolConfiguration = proto
        mgr.isEnabled = true
        
        try await saveManager(mgr: mgr)
        writeToPrefences(cfg: tunnelConfiguration.asWgQuickConfig())
        
        self.onVpnStatusChanged(notification: mgr.connection.status)
        
        do {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil , queue: nil) {
                notification in
                
                let nevpnconn = notification.object as! NEVPNConnection
                let status = nevpnconn.status
                self.onVpnStatusChanged(notification: status)
            }
        }
        
        return mgr
        
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
        
        func writeToPrefences(cfg: String) {
            Self.logger.debug("Write to shared: \(cfg)")
            UserDefaults.group?.set(cfg, forKey: "dostupvpn.shared")
        }
    }
    
    func onVpnStatusChanged(notification : NEVPNStatus) {
        switch notification {
        case NEVPNStatus.connected:
            WGEventChannel.sendState(state: "connected");
            break;
        case NEVPNStatus.connecting:
            WGEventChannel.sendState(state: "connecting");
            break;
        case NEVPNStatus.disconnected:
            WGEventChannel.sendState(state: "disconnected");
            break;
        case NEVPNStatus.disconnecting:
            WGEventChannel.sendState(state: "disconnecting");
            break;
        case NEVPNStatus.invalid:
            WGEventChannel.sendState(state: "invalid");
            break;
        case NEVPNStatus.reasserting:
            WGEventChannel.sendState(state: "reasserting");
            break;
        default:
            WGEventChannel.sendState(state: "none");
            break;
        }
    }
}


