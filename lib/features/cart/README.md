# Cart Feature

Provides client-side shopping cart state enforcing single-cafeteria order rules, itemized totals, preparation notes, and cash-at-pickup / pre-order checkout.

## Structure
- `domain/entities/`: `CartItem`
- `presentation/`: `CartNotifier` (`cartProvider`), `CartScreen`

## Behavior
- Blocks mixing items from multiple cafeterias unless the user confirms clearing the existing cart.
- Blocks ordering unavailable meals or from closed cafeterias for immediate orders.
