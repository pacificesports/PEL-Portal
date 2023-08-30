List<Log> logs = [];

void log(var message, [LogLevel logLevel = LogLevel.info]) {
  print(message.toString());
  logs.add(Log(message.toString(), logLevel));
}

class Log {
  DateTime time = DateTime.now().toUtc();
  String message = "";
  LogLevel level = LogLevel.info;
  Log(this.message, this.level);
}

enum LogLevel {
  info,
  warn,
  error
}

class Logger {
  static void info(var message) {
    log(message, LogLevel.info);
  }
  static void warn(var message) {
    log(message, LogLevel.warn);
  }
  static void error(var message) {
    log(message, LogLevel.error);
  }
}