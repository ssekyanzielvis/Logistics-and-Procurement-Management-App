import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

/// Class that helps with database schema migrations and checks
class DatabaseMigrations {
  final SupabaseClient _supabase;

  DatabaseMigrations(this._supabase);

  /// Check if a column exists in a table
  Future<bool> columnExists(String tableName, String columnName) async {
    try {
      // This is a postgres-specific query that checks if a column exists
      final result = await _supabase.rpc('column_exists', 
        params: {'table_name': tableName, 'column_name': columnName});
      return result == true;
    } catch (e) {
      // If the RPC function doesn't exist, we'll create it
      try {
        await _createColumnExistsFunction();
        // Try again after creating the function
        final result = await _supabase.rpc('column_exists', 
          params: {'table_name': tableName, 'column_name': columnName});
        return result == true;
      } catch (e) {
        debugPrint('Failed to check if column exists: $e');
        return false;
      }
    }
  }

  /// Check if a table exists
  Future<bool> tableExists(String tableName) async {
    try {
      // This is a postgres-specific query that checks if a table exists
      final result = await _supabase.rpc('table_exists', 
        params: {'table_name': tableName});
      return result == true;
    } catch (e) {
      // If the RPC function doesn't exist, we'll create it
      try {
        await _createTableExistsFunction();
        // Try again after creating the function
        final result = await _supabase.rpc('table_exists', 
          params: {'table_name': tableName});
        return result == true;
      } catch (e) {
        debugPrint('Failed to check if table exists: $e');
        return false;
      }
    }
  }

  /// Create a SQL function to check if a table exists
  Future<void> _createTableExistsFunction() async {
    try {
      // Create a PostgreSQL function to check if a table exists
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
        CREATE OR REPLACE FUNCTION table_exists(table_name text)
        RETURNS boolean AS \$\$
        BEGIN
          RETURN EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_name = \$1
          );
        END;
        \$\$ LANGUAGE plpgsql;
        '''
      });
    } catch (e) {
      debugPrint('Failed to create table_exists function: $e');
      throw e;
    }
  }

  /// Create a SQL function to check if a column exists
  Future<void> _createColumnExistsFunction() async {
    try {
      // Create a PostgreSQL function to check if a column exists
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
        CREATE OR REPLACE FUNCTION column_exists(table_name text, column_name text)
        RETURNS boolean AS \$\$
        BEGIN
          RETURN EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_name = \$1
            AND column_name = \$2
          );
        END;
        \$\$ LANGUAGE plpgsql;
        '''
      });
    } catch (e) {
      debugPrint('Failed to create column_exists function: $e');
      throw e;
    }
  }

  /// Create users table if it doesn't exist
  Future<bool> createUsersTableIfNeeded() async {
    try {
      // Check if table exists first
      final exists = await tableExists('users');
      if (exists) {
        debugPrint('Users table already exists');
        return true;
      }
      
      // Create the users table if it doesn't exist
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
        CREATE TABLE IF NOT EXISTS users (
          id UUID PRIMARY KEY REFERENCES auth.users(id),
          email TEXT UNIQUE NOT NULL,
          full_name TEXT,
          phone TEXT,
          role TEXT DEFAULT 'user',
          profile_image TEXT,
          avatar_url TEXT,
          created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
          updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
        );
        '''
      });
      debugPrint('Created users table');
      return true;
    } catch (e) {
      debugPrint('Failed to create users table: $e');
      return false;
    }
  }
  
  /// Try to add an avatar_url column to the users table
  Future<bool> addAvatarUrlColumn() async {
    try {
      // Try to add the avatar_url column if it doesn't exist
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
        ALTER TABLE users 
        ADD COLUMN IF NOT EXISTS avatar_url TEXT;
        '''
      });
      return true;
    } catch (e) {
      debugPrint('Failed to add avatar_url column: $e');
      return false;
    }
  }

  /// Fix RLS policies for the users table
  Future<bool> fixRlsPolicies() async {
    try {
      // Create a stored function to fix RLS policies if it doesn't exist
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
        CREATE OR REPLACE FUNCTION fix_users_rls_policies()
        RETURNS void AS \$\$
        BEGIN
          -- Enable RLS on users table
          ALTER TABLE users ENABLE ROW LEVEL SECURITY;
          
          -- Drop existing policies if they exist
          DROP POLICY IF EXISTS "Allow authenticated users to select" ON users;
          DROP POLICY IF EXISTS "Allow authenticated users to insert" ON users;
          DROP POLICY IF EXISTS "Allow users to update own data" ON users;
          
          -- Create new policies
          CREATE POLICY "Allow authenticated users to select" 
            ON users FOR SELECT 
            USING (auth.role() = 'authenticated');
            
          CREATE POLICY "Allow authenticated users to insert" 
            ON users FOR INSERT 
            WITH CHECK (true);
            
          CREATE POLICY "Allow users to update own data" 
            ON users FOR UPDATE 
            USING (auth.uid() = id)
            WITH CHECK (auth.uid() = id);
        END;
        \$\$ LANGUAGE plpgsql;
        '''
      });
      
      // Now run the function to fix the policies
      await _supabase.rpc('fix_users_rls_policies');
      return true;
    } catch (e) {
      debugPrint('Failed to fix RLS policies: $e');
      return false;
    }
  }

  /// Ensure the chat_rooms table exists with proper columns
  Future<bool> ensureChatRoomsTable() async {
    try {
      final tableExists = await this.tableExists('chat_rooms');
      if (!tableExists) {
        // Create the chat_rooms table
        await _supabase.rpc('exec_sql', params: {
          'sql': '''
          CREATE TABLE IF NOT EXISTS chat_rooms (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user1_id UUID NOT NULL,
            user2_id UUID NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            last_message_id UUID,
            UNIQUE(user1_id, user2_id)
          );
          '''
        });
        debugPrint('Created chat_rooms table');
        return true;
      } else {
        // Check if columns exist
        final hasUser1Id = await columnExists('chat_rooms', 'user1_id');
        final hasUser2Id = await columnExists('chat_rooms', 'user2_id');

        if (!hasUser1Id || !hasUser2Id) {
          // Alter table to add missing columns
          if (!hasUser1Id) {
            await _supabase.rpc('exec_sql', params: {
              'sql': 'ALTER TABLE chat_rooms ADD COLUMN IF NOT EXISTS user1_id UUID;'
            });
            debugPrint('Added user1_id column to chat_rooms table');
          }
          
          if (!hasUser2Id) {
            await _supabase.rpc('exec_sql', params: {
              'sql': 'ALTER TABLE chat_rooms ADD COLUMN IF NOT EXISTS user2_id UUID;'
            });
            debugPrint('Added user2_id column to chat_rooms table');
          }
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error ensuring chat_rooms table: $e');
      return false;
    }
  }

  /// Initialize all migrations
  Future<void> runMigrations() async {
    try {
      // Create necessary SQL helper functions
      try {
        await _supabase.rpc('exec_sql', params: {
          'sql': '''
          CREATE OR REPLACE FUNCTION exec_sql(sql text) RETURNS void AS \$\$
          BEGIN
            EXECUTE sql;
          END;
          \$\$ LANGUAGE plpgsql SECURITY DEFINER;
          '''
        });
      } catch (e) {
        // This might fail if the function already exists or if user doesn't have permission
        debugPrint('Note: exec_sql function may already exist: $e');
      }
      
      // Ensure users table exists
      await createUsersTableIfNeeded();
      
      // Check if users table has avatar_url column
      final hasAvatarUrl = await columnExists('users', 'avatar_url');
      if (!hasAvatarUrl) {
        await addAvatarUrlColumn();
      }
      
      // Fix RLS policies
      await fixRlsPolicies();
      
      // Ensure chat tables are properly set up
      await ensureChatRoomsTable();
      
      debugPrint('All migrations completed successfully');
    } catch (e) {
      debugPrint('Error running migrations: $e');
    }
  }
}
