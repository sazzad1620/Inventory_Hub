/// Tiny Result type to avoid throwing exceptions between layers.
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.message, {this.code});
  final String message;
  final String? code;
}
