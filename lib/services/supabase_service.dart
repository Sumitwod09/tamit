import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  // Convenience getters
  GoTrueClient get auth => client.auth;
  SupabaseStorageClient get storage => client.storage;
  RealtimeClient get realtime => client.realtime;

  SupabaseQueryBuilder from(String table) => client.from(table);

  RealtimeChannel channel(String topic,
          {RealtimeChannelConfig opts = const RealtimeChannelConfig()}) =>
      client.channel(topic, opts: opts);
}
