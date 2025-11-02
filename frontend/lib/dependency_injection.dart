import 'package:get_it/get_it.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Storage Service
  final storageService = StorageService();
  await storageService.init();
  getIt.registerSingleton<StorageService>(storageService);
  
  // API Service
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(getIt<StorageService>()),
  );
  
  // Auth Service
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<ApiService>()),
  );
  
  // Add other services here as needed
}
