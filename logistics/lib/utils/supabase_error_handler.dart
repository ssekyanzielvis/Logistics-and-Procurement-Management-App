import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  /// Get user-friendly error message from Supabase AuthApiException
  static String getErrorMessage(dynamic error) {
    if (error is AuthApiException) {
      return _handleAuthApiException(error);
    } else if (error is PostgrestException) {
      return _handlePostgrestException(error);
    } else {
      return _handleGenericError(error);
    }
  }

  /// Handle AuthApiException (authentication errors)
  static String _handleAuthApiException(AuthApiException error) {
    // Handle by message content first (most reliable)
    if (error.message.contains('over_email_send_rate_limit')) {
      return 'Email sending limit exceeded. Please wait 60 seconds before trying again.';
    } else if (error.message.contains('rate_limit') || error.message.contains('429')) {
      return 'Too many requests. Please wait a moment before trying again.';
    } else if (error.message.contains('User already registered')) {
      return 'This email is already registered. Please sign in instead.';
    } else if (error.message.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (error.message.contains('Email not confirmed')) {
      return 'Account created but email not confirmed. Please contact support or try signing up again.';
    } else if (error.message.contains('Signup requires a valid password')) {
      return 'Please enter a valid password (minimum 6 characters).';
    } else if (error.message.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long.';
    } else if (error.message.contains('Email rate limit exceeded')) {
      return 'Too many emails sent. Please wait a few minutes before trying again.';
    }
    
    // Check status code if available and message didn't match
    final statusCode = error.statusCode;
    if (statusCode == 400) {
      return 'Invalid request. Please check your input and try again.';
    } else if (statusCode == 422) {
      return 'Invalid email or password format. Please check and try again.';
    } else if (statusCode == 429) {
      return 'Too many requests. Please wait a moment before trying again.';
    } else if (statusCode == 500) {
      return 'Server error occurred. Please try again in a few minutes.';
    }
    
    return error.message.isNotEmpty ? error.message : 'An authentication error occurred.';
  }

  /// Handle PostgrestException (database errors)
  static String _handlePostgrestException(PostgrestException error) {
    if (error.code == '23505') {
      return 'This record already exists. Please use different values.';
    } else if (error.code == '23503') {
      return 'Referenced record not found. Please check your data.';
    } else {
      return 'Database error: ${error.message}';
    }
  }

  /// Handle generic errors
  static String _handleGenericError(dynamic error) {
    String errorMessage = error.toString();
    
    // Clean up common error prefixes
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }
    
    // Handle common network errors
    if (errorMessage.contains('SocketException') || errorMessage.contains('TimeoutException')) {
      return 'Network connection error. Please check your internet connection.';
    }
    
    return errorMessage.isNotEmpty ? errorMessage : 'An unexpected error occurred.';
  }

  /// Check if error is rate limit related
  static bool isRateLimitError(dynamic error) {
    if (error is AuthApiException) {
      return error.statusCode == 429 || 
             error.message.contains('rate_limit') || 
             error.message.contains('over_email_send_rate_limit');
    }
    return false;
  }

  /// Get suggested wait time for rate limit errors
  static Duration getRateLimitWaitTime(dynamic error) {
    if (error is AuthApiException && error.message.contains('over_email_send_rate_limit')) {
      return const Duration(seconds: 60); // Email rate limit is typically 60 seconds
    }
    return const Duration(seconds: 30); // Default wait time
  }
}
