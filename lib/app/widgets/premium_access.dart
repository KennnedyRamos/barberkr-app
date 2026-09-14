import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded,
              size: 13, color: colors.onTertiaryContainer),
          const SizedBox(width: 4),
          Text(
            'PREMIUM',
            style: TextStyle(
              color: colors.onTertiaryContainer,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onSubscribe;

  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PremiumBadge(),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(description, style: Theme.of(context).textTheme.bodySmall),
            if (onSubscribe != null) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onSubscribe,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Conhecer o Premium'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PremiumScreenGate extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onSubscribe;

  const PremiumScreenGate({
    super.key,
    required this.title,
    required this.description,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.workspace_premium_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),
        PremiumFeatureCard(
          title: 'Desbloqueie todos os recursos da sua barbearia',
          description:
              'Tenha pagamentos online, gestão completa de agendamentos e acesso ao financeiro com o BarberKR Premium.',
          onSubscribe: onSubscribe,
        ),
      ],
    );
  }
}
