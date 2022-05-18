// ignore_for_file: file_names

class HttpException implements Exception {
  final String massage;
  HttpException(this.massage);

  @override
  String toString() {
    return massage;
  }
}
