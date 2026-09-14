const test = require('node:test');
const assert = require('node:assert/strict');

process.env.MP_WEBHOOK_URL = 'https://example.test/mercadoPagoWebhook';

const {
  PREMIUM_ANNUAL_PRICE,
  buildPremiumPreference,
} = require('../mercado_pago');

test('Premium anual usa valor fixo e Pix em pagamento unico', () => {
  const preference = buildPremiumPreference({
    intentId: 'intent-1',
    clientEmail: 'cliente@example.com',
    paymentMethod: 'pix',
  });

  assert.equal(PREMIUM_ANNUAL_PRICE, 359.88);
  assert.equal(preference.items[0].unit_price, 359.88);
  assert.equal(preference.items[0].quantity, 1);
  assert.equal(preference.external_reference, 'premium:intent-1');
  assert.equal(preference.metadata.auto_renew, false);
  assert.equal(preference.payment_methods.installments, 1);
  assert.deepEqual(preference.payment_methods.excluded_payment_types, [
    { id: 'credit_card' },
    { id: 'debit_card' },
  ]);
});

test('cartao usa Checkout Pro explicitamente sem virar recorrencia', () => {
  const preference = buildPremiumPreference({
    intentId: 'intent-2',
    paymentMethod: 'card',
  });

  assert.equal(preference.payment_methods.installments, 12);
  assert.equal(preference.metadata.premium_plan, 'annual');
  assert.equal(preference.metadata.auto_renew, false);
  assert.match(preference.items[0].description, /pagamento unico/);
  assert.deepEqual(preference.payment_methods.excluded_payment_types, [
    { id: 'ticket' },
    { id: 'bank_transfer' },
  ]);
});

test('rejeita forma de pagamento desconhecida', () => {
  assert.throws(
    () => buildPremiumPreference({ intentId: 'intent-3', paymentMethod: 'subscription' }),
    /Forma de pagamento invalida/
  );
});
