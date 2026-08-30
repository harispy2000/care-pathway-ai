/// Turns a thrown exception into a short, presentable message for the UI.
String friendlyError(Object error) {
  var message = error.toString();
  for (final prefix in const ['Exception: ', 'HttpException: ', 'ClientException: ']) {
    if (message.startsWith(prefix)) {
      message = message.substring(prefix.length);
      break;
    }
  }
  return message.trim().isEmpty ? 'Something went wrong. Please try again.' : message;
}