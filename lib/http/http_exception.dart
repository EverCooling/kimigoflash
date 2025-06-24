class HttpException implements Exception {
  final String message;
  final int? statusCode;

  HttpException({required this.message, this.statusCode});

  @override
  String toString() {
    return "$runtimeType: $message (Status Code: $statusCode)";
  }
}
