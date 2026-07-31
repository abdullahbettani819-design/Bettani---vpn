import 'dart:async';
import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

void main() {
  runApp(const BettaniVpnApp());
}

class BettaniVpnApp extends StatelessWidget {
  const BettaniVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bettani VPN',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
      ),
      home: const VpnHomeScreen(),
    );
  }
}

class VpnServer {
  final String country;
  final String flag;
  final String ip;
  final int ping;
  final String ovpnConfig;

  VpnServer({
    required this.country,
    required this.flag,
    required this.ip,
    required this.ping,
    required this.ovpnConfig,
  });
}

class VpnHomeScreen extends StatefulWidget {
  const VpnHomeScreen({super.key});

  @override
  State<VpnHomeScreen> createState() => _VpnHomeScreenState();
}

class _VpnHomeScreenState extends State<VpnHomeScreen> with SingleTickerProviderStateMixin {
  late OpenVPN engine;
  VpnStage? vpnStage;
  VPNData? vpnData;

  late AnimationController _pulseController;

  final List<VpnServer> serverList = [
    VpnServer(
      country: "Japan",
      flag: "🇯🇵",
      ip: "110.163.147.10",
      ping: 28,
      ovpnConfig: '''client\ndev tun\nproto udp\nremote 110.163.147.10 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\ncipher AES-128-CBC\nauth SHA1\nverb 3''',
    ),
    VpnServer(
      country: "Germany",
      flag: "🇩🇪",
      ip: "185.220.101.5",
      ping: 42,
      ovpnConfig: '''client\ndev tun\nproto udp\nremote 185.220.101.5 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\ncipher AES-128-CBC\nauth SHA1\nverb 3''',
    ),
    VpnServer(
      country: "France",
      flag: "🇫🇷",
      ip: "51.15.122.34",
      ping: 55,
      ovpnConfig: '''client\ndev tun\nproto udp\nremote 51.15.122.34 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\ncipher AES-128-CBC\nauth SHA1\nverb 3''',
    ),
    VpnServer(
      country: "Switzerland",
      flag: "🇨🇭",
      ip: "179.43.149.12",
      ping: 35,
      ovpnConfig: '''client\ndev tun\nproto udp\nremote 179.43.149.12 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\ncipher AES-128-CBC\nauth SHA1\nverb 3''',
    ),
    VpnServer(
      country: "United States",
      flag: "🇺🇸",
      ip: "209.222.252.222",
      ping: 120,
      ovpnConfig: '''client\ndev tun\nproto udp\nremote 209.222.252.222 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\ncipher AES-128-CBC\nauth SHA1\nverb 3''',
    ),
    VpnServer(
      country: "South Korea",
      flag: "🇰🇷",
      ip: "211.218.231.118",
      ping: 65,
      ovpnConfig: '''client\ndev tun\nproto udp\nremote 211.218.231.118 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\ncipher AES-128-CBC\nauth SHA1\nverb 3''',
    ),
    VpnServer(
      country: "United Kingdom",
      flag: "🇬🇧",
      ip: "51.89.152.12",
      ping: 48,
      ovpnConfig: '''client\ndev tun\nproto udp\nremote 51.89.152.12 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\ncipher AES-128-CBC\nauth SHA1\nverb 3''',
    ),
  ];

  late VpnServer selectedServer;

  @override
  void initState() {
    super.initState();
    selectedServer = serverList[0];

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    engine = OpenVPN(
      onVpnStageChanged: (stage, raw) {
        setState(() {
          vpnStage = stage;
          if (stage == VpnStage.connected) {
            _pulseController.repeat(reverse: true);
          } else if (stage == VpnStage.disconnected) {
            _pulseController.stop();
            _pulseController.reset();
          }
        });
      },
      onVpnStatusChanged: (status, raw) {
        setState(() {
          vpnData = status;
        });
      },
    );

    engine.initialize(
      groupIdentifier: "group.com.bettani.vpn",
      providerBundleIdentifier: "com.bettani.vpn.VPNExtension",
      localizedDescription: "Bettani VPN Connection",
    );
  }

  void toggleVpn() {
    if (vpnStage == VpnStage.connected) {
      engine.disconnect();
    } else {
      engine.connect(
        selectedServer.ovpnConfig,
        selectedServer.country,
        username: "",
        password: "",
        certIsRequired: false,
      );
    }
  }

  void _openServerSelectionSheet() {
    if (vpnStage == VpnStage.connected) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: serverList.length,
                  itemBuilder: (context, index) {
                    final server = serverList[index];
                    final isSelected = server.country == selectedServer.country;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.cyan.withAlpha(40) : const Color(0xFF0B0F19),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? Colors.cyanAccent : Colors.white.withAlpha(25),
                        ),
                      ),
                      child: ListTile(
                        leading: Text(server.flag, style: const TextStyle(fontSize: 24)),
                        title: Text(server.country, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("IP: ${server.ip}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi, color: server.ping < 50 ? Colors.greenAccent : Colors.orangeAccent, size: 18),
                            const SizedBox(width: 5),
                            Text("${server.ping} ms", style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            selectedServer = server;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = vpnStage == VpnStage.connected;
    final activeColor = const Color(0xFF00FFA3);
    final inactiveColor = const Color(0xFFFF5252);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "BETTANI VPN",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151C2C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConnected ? activeColor.withAlpha(75) : Colors.white10,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text("IP ADDRESS", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          isConnected ? selectedServer.ip : "192.168.1.1 (Original)",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.white10),
                    Column(
                      children: [
                        const Text("STATUS", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          vpnStage != null ? vpnStage.toString().split('.').last.toUpperCase() : "DISCONNECTED",
                          style: TextStyle(fontWeight: FontWeight.bold, color: isConnected ? activeColor : inactiveColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              GestureDetector(
                onTap: _openServerSelectionSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151C2C),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.cyanAccent.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selectedServer.flag, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Text(selectedServer.country, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.cyanAccent, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: toggleVpn,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isConnected ? activeColor : inactiveColor).withAlpha(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isConnected ? activeColor : inactiveColor)
                                .withAlpha(isConnected ? (50 + (_pulseController.value * 60)).toInt() : 25),
                            blurRadius: isConnected ? 30 + (_pulseController.value * 20) : 15,
                            spreadRadius: isConnected ? 5 + (_pulseController.value * 10) : 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected ? activeColor : inactiveColor,
                          ),
                          child: Icon(
                            Icons.power_settings_new_rounded,
                            size: 60,
                            color: Colors.black.withAlpha(220),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              Text(
                isConnected ? "CONNECTED TO ${selectedServer.country.toUpperCase()}" : "TAP TO CONNECT",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isConnected ? activeColor : Colors.white60,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF151C2C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_downward_rounded, color: activeColor, size: 28),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("DOWNLOAD", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(vpnData?.byteIn ?? "0 KB", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        )
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.white10),
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: Colors.orangeAccent, size: 28),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("UPLOAD", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(vpnData?.byteOut ?? "0 KB", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
