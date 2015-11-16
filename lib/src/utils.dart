library dart_qv.utils;
import 'package:quiver_log/log.dart';
import 'package:logging/logging.dart';

Logger getLogger(String loggerName) {
  Logger _logger = new Logger(loggerName);
  Appender _logAppender = new PrintAppender(BASIC_LOG_FORMATTER);
  Logger.root.level = Level.ALL;
  _logAppender.attachLogger(_logger);
  return _logger;
}
