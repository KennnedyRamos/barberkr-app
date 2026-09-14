import 'package:agendamento_app/app/widgets/premium_access.dart';
import 'package:flutter/material.dart';

class BarberPremiumPage extends StatelessWidget {
  const BarberPremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BarberKR Premium')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        children: [
          Text(
            'Mais controle para sua barbearia',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Assine o Premium para liberar os recursos avançados do BarberKR.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          const PremiumFeatureCard(
            title: 'Tudo em um só lugar',
            description:
                'Receba pagamentos online, gerencie cancelamentos, acompanhe seu financeiro e tenha acesso completo à operação.',
          ),
          const SizedBox(height: 14),
          const PremiumFeatureCard(
            title: 'Sem perder sua agenda',
            description:
                'A agenda básica continua disponível mesmo sem assinatura. O Premium libera as ferramentas avançadas para você crescer.',
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'A contratação do Premium será concluída pelo Mercado Pago.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.workspace_premium_rounded),
            label: const Text('Assinar Premium'),
          ),
        ],
      ),
    );
  }
}
