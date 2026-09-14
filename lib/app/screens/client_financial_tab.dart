import 'package:agendamento_app/app/models/barbershop.dart';
import 'package:agendamento_app/app/services/app_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientFinancialTab extends StatefulWidget {
  const ClientFinancialTab({super.key});

  @override
  State<ClientFinancialTab> createState() => _ClientFinancialTabState();
}

class _ClientFinancialTabState extends State<ClientFinancialTab> {
  final AppFirestoreService _firestoreService = AppFirestoreService();
  late Future<List<Map<String, dynamic>>> _subscriptions;

  @override
  void initState() {
    super.initState();
    _subscriptions = _loadSubscriptions();
  }

  Future<List<Map<String, dynamic>>> _loadSubscriptions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const [];
    final subscriptions = await _firestoreService.getMonthlyPlansForClient(
      user.uid,
    );
    return Future.wait(
      subscriptions.map((subscription) async {
        final barbershop = await _firestoreService.getBarbershopById(
          subscription['barbershopId']?.toString() ?? '',
        );
        return {'subscription': subscription, 'barbershop': barbershop};
      }),
    );
  }

  DateTime? _dateValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }

  bool _isSubscriptionActive(Map<String, dynamic> subscription) {
    final startedAt = _dateValue(
      subscription['startedAt'] ?? subscription['updatedAt'],
    );
    if (startedAt == null) return false;
    final activeUntil = startedAt.add(const Duration(days: 30));
    return DateTime.now().isBefore(activeUntil);
  }

  Future<void> _cancelSubscription(
    Map<String, dynamic> subscription,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar assinatura?'),
        content: const Text(
          'Não haverá reembolso. Você continuará usando o plano até o '
          'fim dos 30 dias do período atual e não haverá renovação no próximo mês.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Manter assinatura'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar renovação'),
          ),
        ],
      ),
    );
    if (shouldCancel != true || !mounted) return;

    try {
      await _firestoreService.cancelMonthlyPlan(
        clientId: FirebaseAuth.instance.currentUser!.uid,
        barberId: subscription['barberId']?.toString() ?? '',
      );
      if (!mounted) return;
      setState(() => _subscriptions = _loadSubscriptions());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Renovação cancelada. O plano continua ativo até o fim do período.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível cancelar: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _subscriptions = _loadSubscriptions());
        await _subscriptions;
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        children: [
          Text(
            'FINANCEIRO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            'Minhas assinaturas',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Acompanhe seus planos e encontre novas vantagens nas barbearias.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _subscriptions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _InlineMessage(
                  message: 'Não foi possível carregar suas assinaturas.',
                  onRetry: () =>
                      setState(() => _subscriptions = _loadSubscriptions()),
                );
              }
              final subscriptions = (snapshot.data ?? const [])
                  .where((item) => _isSubscriptionActive(
                        item['subscription'] as Map<String, dynamic>,
                      ))
                  .toList(growable: false);
              if (subscriptions.isNotEmpty) {
                return _ActiveSubscriptions(
                  subscriptions: subscriptions,
                  onCancel: _cancelSubscription,
                );
              }
              return const _PlansInfo();
            },
          ),
        ],
      ),
    );
  }
}

class _PlansInfo extends StatelessWidget {
  const _PlansInfo();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: .78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: .25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: colors.onPrimary,
            size: 30,
          ),
          const SizedBox(height: 14),
          Text(
            'Planos das barbearias',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cada barbearia define seus próprios planos. Para consultar ou assinar, abra a página da barbearia desejada.',
            style: TextStyle(
              color: colors.onPrimary.withValues(alpha: .9),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSubscriptions extends StatelessWidget {
  final List<Map<String, dynamic>> subscriptions;
  final Future<void> Function(Map<String, dynamic> subscription) onCancel;

  const _ActiveSubscriptions({
    required this.subscriptions,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Planos ativos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...subscriptions.map((item) {
          final subscription = item['subscription'] as Map<String, dynamic>;
          final shop = item['barbershop'] as Barbershop?;
          final price = (subscription['price'] as num?)?.toDouble() ?? 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_rounded),
                    title: Text(
                      subscription['planName']?.toString() ?? 'Plano mensal',
                    ),
                    subtitle: Text(
                      '${shop?.nome ?? 'Barbearia'} • ${currency.format(price)} por mês',
                    ),
                  ),
                  Text(
                    subscription['renewalEnabled'] == false
                        ? 'Cancelada: ativa até o fim do período atual, sem reembolso.'
                        : 'Ativa por 30 dias. A renovação acontece no próximo ciclo.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (subscription['renewalEnabled'] != false)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => onCancel(subscription),
                        child: const Text('Cancelar renovação'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _InlineMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(child: Text(message)),
            if (onRetry != null)
              IconButton(
                onPressed: onRetry,
                tooltip: 'Tentar novamente',
                icon: const Icon(Icons.refresh_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
