import 'package:flutter_test/flutter_test.dart';
import 'package:nexpeer/main.dart';
void main() {
 testWidgets('NexPeer displays its splash screen', (tester) async { await tester.pumpWidget(const NexPeerApp()); expect(find.text('NexPeer'), findsOneWidget); expect(find.text('Private. Direct. Peer-to-Peer.'), findsOneWidget); });
 testWidgets('NexPeer reports missing Supabase configuration gracefully', (tester) async { await tester.pumpWidget(const NexPeerApp()); await tester.pump(const Duration(seconds: 2)); await tester.pump(); expect(find.text('Supabase belum dikonfigurasi'), findsOneWidget); expect(tester.takeException(), isNull); });
}
