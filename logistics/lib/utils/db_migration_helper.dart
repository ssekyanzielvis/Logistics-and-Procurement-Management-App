import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A utility class to help ensure the database schema is properly set up
class DbMigrationHelper {
  final SupabaseClient _supabase;

  DbMigrationHelper(this._supabase);

  /// Run necessary database migrations and setup tasks
  Future<void> ensureDbSetup() async {
    try {
      debugPrint('Running database migrations and setup tasks');
      
      // Check if users table exists with proper columns
      await _ensureUsersTable();
      
      // Add more migration steps as needed
      
      debugPrint('Database setup complete');
    } catch (e) {
      debugPrint('Error during database setup: $e');
      // We'll continue even if migrations fail
    }
  }

  /// Ensure the users table exists and has the right columns
  Future<void> _ensureUsersTable() async {
    try {
      // First check if we can read from the users table
      try {
        await _supabase.from('users').select('id').limit(1);
        debugPrint('Users table exists and is readable');
      } catch (e) {
        debugPrint('Error accessing users table: $e');
        // Try to create the users table if we get an error
        await _supabase.rpc('create_users_table_if_needed');
      }
      
      // Check if we can create a test entry and delete it
      // This tests both read and write permissions
      final testId = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        await _supabase.from('users').insert({
          'id': testId,
          'email': 'test_${testId}@example.com',
          'full_name': 'Test User',
        });
        debugPrint('Successfully inserted test user');
        
        // Clean up test entry
        await _supabase.from('users').delete().eq('id', testId);
        debugPrint('Successfully deleted test user');
      } catch (e) {
        debugPrint('Error testing user table write access: $e');
        // We'll try to create RLS policies
        await _fixRlsPolicies();
      }
    } catch (e) {
      debugPrint('Error ensuring users table: $e');
    }
  }

  /// Try to fix RLS policies for the users table
  Future<void> _fixRlsPolicies() async {
    try {
      // Call stored procedure to fix RLS policies
      await _supabase.rpc('fix_users_rls_policies');
      debugPrint('RLS policies updated');
    } catch (e) {
      debugPrint('Error fixing RLS policies: $e');
      // We can't do much if this fails
    }
  }
}
