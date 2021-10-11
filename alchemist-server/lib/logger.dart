import 'dart:io';

class Logger {
  File output;
  Logger({
    String? output,
  }) : this.output = File(output ?? 'alchemist.log');

  void print(String message) {
    print(message);
  }
}
