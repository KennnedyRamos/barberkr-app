import 'package:agendamento_app/app/screens/client_appointments_tab.dart';
import 'package:agendamento_app/app/screens/client_barbershops_tab.dart';
import 'package:agendamento_app/app/screens/client_financial_tab.dart';
import 'package:agendamento_app/app/screens/client_profile_page.dart';
import 'package:agendamento_app/app/services/messaging_service.dart';
import 'package:agendamento_app/app/widgets/notification_bell_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientHomePage extends StatefulWidget {
  final int initialTab;

  const ClientHomePage({super.key, this.initialTab = 1});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _currentIndex = widget.initialTab;
    _tabController.addListener(_syncSelectedTab);
  }

  void _syncSelectedTab() {
    if (!mounted || _currentIndex == _tabController.index) return;
    setState(() => _currentIndex = _tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_syncSelectedTab);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await MessagingService().clearForUser(userId);
    }
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 62,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14, top: 7, bottom: 7),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.content_cut_rounded,
              color: colors.onPrimary,
              size: 20,
            ),
          ),
        ),
        title: Column(
          children: [
            const Text('BarberKR'),
            Text(
                switch (_currentIndex) {
                  0 => 'Descobrir',
                  1 => 'Minha agenda',
                  _ => 'Financeiro',
                },
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          if (userId != null) NotificationBellButton(userId: userId),
          IconButton(
            tooltip: 'Meu perfil',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClientProfilePage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ClientBarbershopsTab(),
          ClientAppointmentsTab(
            onOpenBarbershops: () => _tabController.animateTo(0),
          ),
          const ClientFinancialTab(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _tabController.animateTo,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Barbearias',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Agenda',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Financeiro',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
