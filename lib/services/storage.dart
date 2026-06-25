import 'storage_stub.dart'
    if (dart.library.html) 'storage_web.dart'
    if (dart.library.io) 'storage_io.dart';

final AppStorage storage = createStorage();
