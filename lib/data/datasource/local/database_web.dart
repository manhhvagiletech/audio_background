import 'database_impl.dart';

/// platform handler io not supported on the web.
PlatformHandler get platformHandlerIo =>
    throw UnsupportedError('platform handler io not supported on the web');
