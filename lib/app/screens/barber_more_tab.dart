import 'package:agendamento_app/app/widgets/premium_access.dart';
import 'package:flutter/material.dart';

class BarberMoreTab extends StatelessWidget {
  final VoidCallback onOpenFinancial;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenBarbershop;
  final VoidCallback onLogout;
  final VoidCallback? onOpenPremium;
  final bool isPremium;

  const BarberMoreTab({
    super.key,
    required this.onOpenFinancial,
    required this.onOpenHistory,
    required this.onOpenBarbershop,
    required this.onLogout,
    this.onOpenPremium,
    this.isPremium = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        if (!isPremium) ...[
          PremiumFeatureCard(
            title: 'Libere o potencial da sua barbearia',
            description:
                'Pagamentos online, cancelamentos, histórico e financeiro são recursos Premium.',
            onSubscribe: onOpenPremium,
          ),
          const SizedBox(height: 22),
        ],
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sua gestão em um só lugar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Financeiro, histórico e configurações sem poluir a navegação.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text('Gestão', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Financeiro',
          subtitle: 'Faturamento, taxas, entradas e serviços realizados',
          onTap: onOpenFinancial,
          isPremium: !isPremium,
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.history_rounded,
          title: 'Histórico',
          subtitle: 'Atendimentos concluídos e filtros por período',
          onTap: onOpenHistory,
          isPremium: !isPremium,
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.storefront_rounded,
          title: 'Minha barbearia',
          subtitle: 'Serviços, horários, logo, endereço e pagamentos',
          onTap: onOpenBarbershop,
        ),
        const SizedBox(height: 22),
        Text('Conta', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.logout_rounded,
          title: 'Sair da conta',
          subtitle: 'Encerrar a sessão neste aparelho',
          onTap: onLogout,
          isDestructive: true,
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isPremium;

  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isDestructive ? colors.error : colors.primary;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isDestructive ? colors.error : null,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isPremium) const PremiumBadge(),
              if (isPremium) const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
