import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../blocs/server_list/server_list_bloc.dart';
import '../../blocs/server/server_bloc.dart';
import '../../blocs/version_selector/version_selector_bloc.dart';
import '../console/console_screen.dart';
import '../server_creation/server_creation_screen.dart';
import '../../screens/server_download/utility/server_download_utility_screen.dart';
import '../../common_widgets/server_status_indicator.dart';
import '../../themes/app_theme.dart';
import '../../../domain/usecases/download_server.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedServerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<ServerListBloc>().add(LoadServerList());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // App Bar / Header
          _buildAppBar(),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Left sidebar with server list
                _buildServerList(),

                // Main content area
                Expanded(
                  child: _selectedServerId != null
                      ? BlocBuilder<ServerBloc, ServerState>(
                    builder: (context, state) {
                      if (state is ServerLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ServerLoaded) {
                        return _buildServerDashboard(state.server);
                      } else if (state is ServerOperationFailure) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      return const Center(child: Text('Select a server from the sidebar'));
                    },
                  )
                      : const Center(child: Text('No server selected')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.storage, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Text(
            'MCSM',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 32),

          // Navigation items
          _buildNavItem('Dashboard', Icons.dashboard, true),
          _buildNavItem('Servers', Icons.dns, false),
          _buildNavItem('Plugins', Icons.extension, false),
          _buildNavItem('Settings', Icons.settings, false),

          const Spacer(),

          // Notifications and user menu
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isActive) {
    final color = isActive ? AppTheme.primaryColor : Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton.icon(
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildServerList() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Servers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 32),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider(
                        create: (context) => GetIt.instance<VersionSelectorBloc>(),
                        child: const ServerCreationDialog(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ServerListBloc, ServerListState>(
              builder: (context, state) {
                if (state is ServerListLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ServerListLoaded) {
                  final servers = state.servers;

                  // Auto-select first server if none selected
                  if (_selectedServerId == null && servers.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedServerId = servers.first.id;
                      });
                      context.read<ServerBloc>().add(LoadServer(servers.first.id));
                    });
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      final isSelected = server.id == _selectedServerId;

                      return _buildServerCard(
                        name: server.name,
                        type: server.version,
                        isOnline: server.isRunning,
                        isSelected: isSelected,
                        playerCount: '3/20', // Esempio - sostituire con dati reali
                        onTap: () {
                          setState(() {
                            _selectedServerId = server.id;
                          });
                          context.read<ServerBloc>().add(LoadServer(server.id));
                        },
                      );
                    },
                  );
                } else if (state is ServerListError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard({
    required String name,
    required String type,
    required bool isOnline,
    required bool isSelected,
    required String playerCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : null,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? AppTheme.onlineColor.withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOnline ? 'online' : 'offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? AppTheme.onlineColor : AppTheme.offlineColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      playerCount,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerDashboard(dynamic server) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Server header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Vanilla Server', // Sostituire con il tipo effettivo
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Server'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: server.isRunning
                        ? () {
                      context.read<ServerBloc>().add(StopServer(server.id));
                    }
                        : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Aggiorna Server',
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<ServerBloc>().add(LoadServer(server.id));
                    },
                  ),
                  IconButton(
                    tooltip: 'Scarica Aggiornamenti',
                    icon: const Icon(Icons.download),
                    onPressed: !server.isRunning
                        ? () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => GetIt.instance<VersionSelectorBloc>(),
                            child: const ServerDownloadUtilityScreen(),
                          ),
                        ),
                      );
                    }
                        : null,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats cards
          Row(
            children: [
              Expanded(child: _buildStatCard('CPU Usage', '32%', Icons.memory)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Memory Usage', '68%', Icons.sd_storage)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Storage', '45%', Icons.storage)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPlayerStatCard('Players', '3/20', 'Uptime: 2d 7h 15m', Icons.people),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Console'),
              Tab(text: 'Players'),
              Tab(text: 'Mods & Plugins'),
              Tab(text: 'Settings'),
            ],
          ),

          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Console tab
                _buildConsole(),

                // Players tab
                const Center(child: Text('Players tab content')),

                // Mods & Plugins tab
                const Center(child: Text('Mods & Plugins tab content')),

                // Settings tab
                const Center(child: Text('Settings tab content')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    // Parse percentage value
    final percentValue = double.tryParse(value.replaceAll('%', '')) ?? 0;
    final normalizedValue = percentValue / 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 18, color: Colors.grey.shade600),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: normalizedValue,
            backgroundColor: Colors.grey.shade200,
            color: _getProgressColor(normalizedValue),
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatCard(String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 18, color: Colors.grey.shade600),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double value) {
    if (value > 0.8) {
      return Colors.red;
    } else if (value > 0.6) {
      return Colors.orange;
    } else {
      return AppTheme.primaryColor;
    }
  }

  Widget _buildConsole() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Console header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Server Console',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export Logs'),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Console output
          Expanded(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildConsoleLine("[12:45:32]", "INFO", "Server started on port 25565"),
                  _buildConsoleLine("[12:45:33]", "INFO", "Loading properties"),
                  _buildConsoleLine("[12:45:34]", "INFO", "Default game type: SURVIVAL"),
                  _buildConsoleLine("[12:45:35]", "INFO", "Preparing level 'world'"),
                  _buildConsoleLine("[12:45:40]", "INFO", "Preparing start region for dimension minecraft:overworld"),
                  _buildConsoleLine("[12:46:02]", "INFO", "Preparing spawn area: 85%"),
                  _buildConsoleLine("[12:46:12]", "INFO", "Done (42.069s)! For help, type 'help'"),
                  _buildConsoleLine("[12:50:23]", "INFO", "Player 'Steve' joined the game", isPlayerJoin: true),
                  _buildConsoleLine("[12:51:45]", "INFO", "Player 'Alex' joined the game", isPlayerJoin: true),
                  _buildConsoleLine("[12:55:12]", "INFO", "Player 'Notch' joined the game", isPlayerJoin: true),
                  _buildConsoleLine("[13:02:34]", "WARN", "Can't keep up! Is the server overloaded?"),
                  _buildConsoleLine("[13:10:45]", "INFO", "Player 'Notch' lost connection: Disconnected", isPlayerLeave: true),
                ],
              ),
            ),
          ),

          // Command input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Type a command...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleLine(String timestamp, String level, String message, {bool isPlayerJoin = false, bool isPlayerLeave = false}) {
    Color levelColor;
    Color messageColor = Colors.white;

    // Set color based on level
    switch (level) {
      case "WARN":
        levelColor = Colors.orange;
        break;
      case "ERROR":
        levelColor = Colors.red;
        break;
      case "INFO":
      default:
        levelColor = Colors.lightBlue;
    }

    // Override message color for player events
    if (isPlayerJoin) {
      messageColor = Colors.green;
    } else if (isPlayerLeave) {
      messageColor = Colors.yellow;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        children: [
          TextSpan(
            text: "$timestamp ",
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          TextSpan(
            text: "[$level] ",
            style: TextStyle(
              color: levelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: message,
            style: TextStyle(
              color: messageColor,
            ),
          ),
        ],
      ),
    );
  }
}