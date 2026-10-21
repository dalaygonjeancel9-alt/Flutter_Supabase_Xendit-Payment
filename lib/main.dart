import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Supabase project values.
// The URL must be https://<project-ref>.supabase.co (NOT the dashboard link).
const supabaseUrl = 'https://zexgngmgbipaexcizjix.supabase.co';
const supabaseAnonKey = 'sb_publishable_ZW_LLEg6OvwP2gkMFr6k3A_TrJGPYlV';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

// ---------------------------------------------------------------------------
// Theme tokens
// ---------------------------------------------------------------------------

const kInk = Color(0xFF1E1B4B); // deep indigo for text
const kViolet = Color(0xFF6D4AFF); // primary
const kCoral = Color(0xFFFF5A7A); // accent
const kBg = Color(0xFFF6F4FF); // page background
const kMuted = Color(0xFF6B6890); // secondary text
const kLine = Color(0xFFE6E2FA); // card borders

const kGradient = LinearGradient(
  colors: [kCoral, kViolet],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ---------------------------------------------------------------------------
// Helpers + products
// ---------------------------------------------------------------------------

String peso(num value) {
  final parts = value.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return '₱$whole.${parts[1]}';
}

class Product {
  final String name;
  final String description;
  final double price;
  final IconData icon;
  final Color color;

  const Product(this.name, this.description, this.price, this.icon, this.color);
}

const products = [
  Product('Mechanical Gaming Keyboard', 'RGB backlight, blue switches', 1500,
      Icons.keyboard, Color(0xFFFF7A8A)),
  Product('Wireless Ergonomic Mouse', 'Silent clicks, 2.4GHz receiver', 850,
      Icons.mouse, Color(0xFF5B9DFF)),
  Product('USB-C Hub Multiport Adapter', '7-in-1: HDMI, USB 3.0, SD card', 600,
      Icons.usb, Color(0xFF34C28B)),
  Product('Noise-Cancelling Headphones', 'Bluetooth 5.0, 30-hour battery', 2200,
      Icons.headphones, Color(0xFF9B6BFF)),
  Product('1080p Webcam', 'Built-in mic, auto light correction', 1200,
      Icons.videocam, Color(0xFFFFA24C)),
  Product('Portable Power Bank 20,000mAh', 'Fast charge, dual USB output', 1100,
      Icons.battery_charging_full, Color(0xFF2EB5C9)),
];

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------

/// Gradient button used everywhere in the app.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool compact;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.compact = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(compact ? 12 : 16);

    return Opacity(
      opacity: enabled ? 1 : 0.65,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: kGradient,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: kViolet.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : 20,
                vertical: compact ? 10 : 16,
              ),
              child: Row(
                mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  else ...[
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: compact ? 16 : 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 13 : 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White card with a thin border.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kLine),
        boxShadow: [
          BoxShadow(
            color: kViolet.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;
  final double size;

  const ProductTile({super.key, required this.product, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [product.color, product.color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(product.icon, size: size * 0.5, color: Colors.white),
    );
  }
}

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMC Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kViolet,
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          surfaceTintColor: Colors.transparent,
          foregroundColor: kInk,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: kInk,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: kViolet.withValues(alpha: 0.14),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: states.contains(WidgetState.selected) ? kViolet : kMuted,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? kViolet : kMuted,
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_index == 0 ? 'BMC Shop' : 'My Orders')),
      // A fresh OrdersScreen is built each time the tab opens, so it reloads.
      body: _index == 0 ? const ShopScreen() : const OrdersScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'My Orders',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shop: list of products
// ---------------------------------------------------------------------------

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        // Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kInk, kViolet],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gear up for class',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Student-friendly tech, paid in seconds with GCash.',
                      style: TextStyle(color: Color(0xFFD9D3FF), height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Popular products',
          style: TextStyle(
            color: kInk,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        for (final p in products) ...[
          SoftCard(
            child: Row(
              children: [
                ProductTile(product: p),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          color: kInk,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.description,
                        style: const TextStyle(color: kMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        peso(p.price),
                        style: const TextStyle(
                          color: kViolet,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  label: 'Buy Now',
                  compact: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderSummaryScreen(product: p),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Order summary + pay with GCash (Xendit invoice)
// ---------------------------------------------------------------------------

class OrderSummaryScreen extends StatefulWidget {
  final Product product;
  const OrderSummaryScreen({super.key, required this.product});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  int _qty = 1;
  bool _loading = false;

  double get _total => widget.product.price * _qty;

  Future<void> _pay() async {
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final p = widget.product;
      final res = await supabase.functions.invoke(
        'create-invoice',
        body: {
          'product_name': _qty > 1 ? '${p.name} x$_qty' : p.name,
          'amount': _total.round(),
        },
      );

      final data = res.data;
      final url = data is Map ? data['invoice_url'] as String? : null;
      if (url == null) {
        throw Exception(
            data is Map ? (data['error'] ?? 'No invoice URL') : 'Bad response');
      }

      final opened =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!opened) throw Exception('Could not open the payment page');

      navigator.pop();
      messenger.showSnackBar(const SnackBar(
        content: Text('Finish paying in the browser, then check My Orders.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Payment error: $e')));
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _qtyButton(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? kViolet.withValues(alpha: 0.12) : kLine,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: enabled ? kViolet : kMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Summary')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          SoftCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ProductTile(product: p, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          color: kInk,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.description,
                        style: const TextStyle(color: kMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        color: kInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        _qtyButton(Icons.remove,
                            _qty > 1 ? () => setState(() => _qty--) : null),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$_qty',
                            style: const TextStyle(
                              color: kInk,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _qtyButton(Icons.add,
                            _qty < 10 ? () => setState(() => _qty++) : null),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28, color: kLine),
                _row('Unit price', peso(p.price)),
                _row('Quantity', '$_qty'),
                const Divider(height: 28, color: kLine),
                _row('Total amount', peso(_total), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: Color(0xFF0070E0)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pay securely with GCash through Xendit (test mode, no real money).',
                    style: TextStyle(color: Color(0xFF14436F), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GradientButton(
            label: 'Pay ${peso(_total)} with GCash',
            icon: Icons.lock_outline,
            loading: _loading,
            onPressed: _loading ? null : _pay,
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = bold
        ? const TextStyle(
            color: kInk, fontWeight: FontWeight.w800, fontSize: 18)
        : const TextStyle(color: kMuted);
    final valueStyle = bold
        ? const TextStyle(
            color: kViolet, fontWeight: FontWeight.w800, fontSize: 18)
        : const TextStyle(color: kInk, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: valueStyle)],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// My Orders: reads the orders table (status is updated by xendit-webhook)
// ---------------------------------------------------------------------------

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _fetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Reload when the user comes back from the browser after paying.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  Future<List<Map<String, dynamic>>> _fetch() async {
    final rows = await supabase.from('orders').select();
    final list = List<Map<String, dynamic>>.from(rows);
    // external_id looks like order_<timestamp>, so this sorts newest first
    list.sort((a, b) => '${b['external_id']}'.compareTo('${a['external_id']}'));
    return list;
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() => _future = _fetch());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kViolet,
      onRefresh: _reload,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: kViolet),
            );
          }
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load orders:\n${snap.error}'),
                ),
              ],
            );
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Icon(Icons.receipt_long_outlined, size: 64, color: kMuted),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'No orders yet',
                    style: TextStyle(
                      color: kInk,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Center(
                  child: Text(
                    'Pick something from the Shop tab to place your first order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kMuted),
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _OrderTile(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = '${order['status'] ?? 'PENDING'}'.toUpperCase();
    final paid = status == 'PAID' || status == 'SETTLED';
    final expired = status == 'EXPIRED' || status == 'FAILED';

    final Color color = paid
        ? const Color(0xFF1FA971)
        : expired
            ? const Color(0xFFE5484D)
            : const Color(0xFFF59E0B);
    final IconData icon = paid
        ? Icons.check_circle
        : expired
            ? Icons.cancel
            : Icons.access_time_filled;
    final String label = paid ? 'Paid' : (expired ? status : 'Pending');
    final amount = (order['amount'] as num?) ?? 0;

    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order['product_name'] ?? 'Order'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ref: ${order['external_id']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                peso(amount),
                style: const TextStyle(
                  color: kInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}