import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_energy_controller/providers/energy_provider.dart';
import 'package:smart_energy_controller/models/alert_model.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  AlertPriority? _filterPriority;
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final energyProvider = Provider.of<EnergyProvider>(context);
    final alerts = energyProvider.alerts;

    // Parse alerts to AlertModel objects
    final alertModels = alerts
        .whereType<Map>()
        .map((alert) => AlertModel.fromJson(Map<String, dynamic>.from(alert)))
        .toList();

    // Apply filters
    final filteredAlerts = _applyFilters(alertModels);

    // Split into unread and read
    final unreadAlerts = filteredAlerts.where((a) => !a.isRead).toList();
    final readAlerts = filteredAlerts.where((a) => a.isRead).toList();

    final currentAlerts = _tabController.index == 0 ? unreadAlerts : readAlerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unread'),
                  if (unreadAlerts.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${unreadAlerts.length}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'History'),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _filterPriority != null || _showOnlyUnread,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsBar(alertModels, unreadAlerts.length),
          if (_searchQuery.isNotEmpty ||
              _filterPriority != null ||
              _showOnlyUnread)
            _buildActiveFiltersBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => energyProvider.loadAllData(showLoading: false),
              child: currentAlerts.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.58,
                          child: _buildEmptyState(_tabController.index == 0),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: currentAlerts.length,
                      itemBuilder: (context, index) {
                        return _buildAlertCard(
                          currentAlerts[index],
                          energyProvider,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== FILTER LOGIC ==========

  List<AlertModel> _applyFilters(List<AlertModel> alerts) {
    var result = alerts;

    if (_filterPriority != null) {
      result = result.where((a) => a.priority == _filterPriority).toList();
    }

    if (_showOnlyUnread) {
      result = result.where((a) => !a.isRead).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((a) =>
              a.message.toLowerCase().contains(query) ||
              (a.details?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    return result;
  }

  // ========== STATS BAR ==========

  Widget _buildStatsBar(List<AlertModel> alerts, int unreadCount) {
    final highCount =
        alerts.where((a) => a.priority == AlertPriority.high).length;
    final mediumCount =
        alerts.where((a) => a.priority == AlertPriority.medium).length;
    final lowCount =
        alerts.where((a) => a.priority == AlertPriority.low).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', alerts.length.toString(), Icons.notifications,
              Colors.grey),
          _buildStatItem('Unread', unreadCount.toString(),
              Icons.mark_email_unread, Colors.blue),
          _buildStatItem('High', highCount.toString(), Icons.error, Colors.red),
          _buildStatItem(
              'Medium', mediumCount.toString(), Icons.warning, Colors.orange),
          _buildStatItem('Low', lowCount.toString(), Icons.info, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  // ========== ACTIVE FILTERS BAR ==========

  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_searchQuery.isNotEmpty)
            Chip(
              label: Text('Search: $_searchQuery'),
              onDeleted: () => setState(() => _searchQuery = ''),
              deleteIcon: const Icon(Icons.close, size: 16),
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          if (_filterPriority != null)
            Chip(
              label: Text(
                  'Priority: ${_filterPriority.toString().split('.').last.toUpperCase()}'),
              onDeleted: () => setState(() => _filterPriority = null),
              deleteIcon: const Icon(Icons.close, size: 16),
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
            ),
          if (_showOnlyUnread)
            Chip(
              label: const Text('Unread Only'),
              onDeleted: () => setState(() => _showOnlyUnread = false),
              deleteIcon: const Icon(Icons.close, size: 16),
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
            ),
        ],
      ),
    );
  }

  // ========== ALERT CARD ==========

  Widget _buildAlertCard(AlertModel alert, EnergyProvider provider) {
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Dismiss Alert'),
            content: const Text('Are you sure you want to dismiss this alert?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        provider.dismissAlert(alert.id);
        _showSnackBar('Alert dismissed');
      },
      child: InkWell(
        onTap: () => _showAlertDetails(alert, provider),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getPriorityColor(alert.priority).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(alert.priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    alert.priorityText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(alert.priority),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!alert.isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    alert.formattedTime,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alert.message,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              if (alert.details != null && alert.details!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  alert.details!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (alert.priority == AlertPriority.high) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showQuickActions(alert),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('TAKE ACTION'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showAlertDetails(alert, provider),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('DETAILS'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== EMPTY STATE ==========

  Widget _buildEmptyState(bool isUnread) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnread ? Icons.notifications_none : Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isUnread ? 'No unread alerts' : 'No alerts in history',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            isUnread
                ? 'All caught up! No new notifications.'
                : 'Alert history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final provider =
                  Provider.of<EnergyProvider>(context, listen: false);
              provider.loadAllData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  // ========== DIALOGS & SHEETS ==========

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Alerts'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by message or details...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Alerts',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Priority',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: AlertPriority.values.map((priority) {
                      return FilterChip(
                        label: Text(
                            priority.toString().split('.').last.toUpperCase()),
                        selected: _filterPriority == priority,
                        onSelected: (selected) {
                          setStateSheet(() =>
                              _filterPriority = selected ? priority : null);
                          setState(() =>
                              _filterPriority = selected ? priority : null);
                        },
                        selectedColor:
                            _getPriorityColor(priority).withValues(alpha: 0.2),
                        checkmarkColor: _getPriorityColor(priority),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Status',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  FilterChip(
                    label: const Text('UNREAD ONLY'),
                    selected: _showOnlyUnread,
                    onSelected: (selected) {
                      setStateSheet(() => _showOnlyUnread = selected);
                      setState(() => _showOnlyUnread = selected);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setStateSheet(() {
                              _filterPriority = null;
                              _showOnlyUnread = false;
                            });
                            setState(() {
                              _filterPriority = null;
                              _showOnlyUnread = false;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAlertDetails(AlertModel alert, EnergyProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(alert.priority)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          alert.priority == AlertPriority.high
                              ? Icons.error
                              : alert.priority == AlertPriority.medium
                                  ? Icons.warning
                                  : Icons.info,
                          color: _getPriorityColor(alert.priority),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.priorityText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(alert.priority),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert.message,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Time', alert.formattedDateTime,
                              Icons.access_time),
                          const SizedBox(height: 12),
                          _buildDetailRow('Priority', alert.priorityText,
                              Icons.priority_high),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                              'Type',
                              alert.type
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              Icons.category),
                          if (alert.details != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                                'Details', alert.details!, Icons.description,
                                isLongText: true),
                          ],
                          const SizedBox(height: 12),
                          _buildDetailRow(
                              'Status',
                              alert.isRead ? 'Read' : 'Unread',
                              Icons.mark_email_read),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              if (!alert.isRead) ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      provider.markAlertRead(alert.id);
                                      Navigator.pop(context);
                                      _showSnackBar('Marked as read');
                                    },
                                    icon: const Icon(Icons.mark_email_read),
                                    label: const Text('Mark as Read'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Close'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {bool isLongText = false}) {
    return Row(
      crossAxisAlignment:
          isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  void _showQuickActions(AlertModel alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading:
                    const Icon(Icons.electrical_services, color: Colors.orange),
                title: const Text('Check Grid Status'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Navigating to Controls...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_backup_restore),
                title: const Text('Reset System'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmReset();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('Mute Similar Alerts'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Similar alerts muted for 1 hour');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Alerts'),
        content: const Text(
            'Are you sure you want to clear all alerts? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider =
                  Provider.of<EnergyProvider>(context, listen: false);
              provider.clearAlerts();
              _showSnackBar('All alerts cleared');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset System'),
        content: const Text(
            'Are you sure you want to reset the system? This will restart all services.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider =
                  Provider.of<EnergyProvider>(context, listen: false);
              provider.sendCommand('RESET', 1);
              _showSnackBar('System reset command sent');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // ========== HELPERS ==========

  Color _getPriorityColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.high:
        return Colors.red;
      case AlertPriority.medium:
        return Colors.orange;
      case AlertPriority.low:
        return Colors.blue;
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
