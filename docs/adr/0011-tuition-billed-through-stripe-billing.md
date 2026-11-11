# Tuition is billed through Stripe Billing

Each Payer gets one Stripe subscription in their Center's Stripe account, with one item per enrolled child. Stripe creates an invoice every billing period and handles collection, autopay, retries and receipts. DC Management still holds the Tuition Plans, discounts and rules. It pushes each change to the Stripe subscription, and turns approved Charges and subsidy credits into Stripe invoice items. This was chosen over running our own billing run, which creates one-off invoices each period. That would have needed Step Functions, stable invoice keys, and care to never charge twice once Stripe's 24-hour idempotency window has passed. The tradeoffs:

- Stripe Billing's fee is higher than one-off invoicing, and it falls on the Center.
- The rules live in DC Management but take effect in Stripe, so every change must be synced and retried until it lands.
- Stripe's automatic proration is turned off. An Admin's edited prorated amount is added as an invoice item instead.

"Stripe subscription" always means this Stripe object. It's distinct from a Tuition Plan and from the Organization's own subscription to DC Management, which also uses Stripe Billing, on DC Management's account.
