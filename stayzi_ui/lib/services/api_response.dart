class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;
  final int? statusCode;

  ApiResponse({
    this.data,
    this.error,
    required this.success,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse<T>(
      data: data,
      success: true,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(
      error: error,
      success: false,
      statusCode: statusCode,
    );
  }

  bool get hasError => !success;
  bool get hasData => data != null;

  @override
  String toString() {
    return 'ApiResponse{data: $data, error: $error, success: $success, statusCode: $statusCode}';
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
} 