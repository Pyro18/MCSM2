import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/local/preferences_datasource.dart';
import 'data/datasources/local/process_manager.dart';
import 'data/repositories/minecraft_server_repository_impl.dart';
import 'domain/repositories/minecraft_server_repository.dart';
import 'domain/usecases/get_server_by_id.dart';
import 'domain/usecases/start_server.dart';
import 'domain/usecases/stop_server.dart';
import 'domain/usecases/send_command.dart';
import 'presentation/blocs/server/server_bloc.dart';
import 'presentation/blocs/server_list/server_list_bloc.dart';
import 'presentation/blocs/console/console_bloc.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/themes/app_theme.dart';

final GetIt sl = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurazione delle dipendenze
  setupDependencies();

  runApp(const MinecraftServerManagerApp());
}

void setupDependencies() {
  // Data sources
  sl.registerLazySingleton<PreferencesDatasource>(
        () => PreferencesDatasourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<MinecraftServerRepository>(
        () => MinecraftServerRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetServerByIdUseCase(sl()));
  sl.registerLazySingleton(() => StartServerUseCase(sl()));
  sl.registerLazySingleton(() => StopServerUseCase(sl()));
  sl.registerLazySingleton(() => SendCommandUseCase(sl()));

  // BLoCs
  sl.registerFactory(
        () => ServerBloc(
      getServerById: sl(),
      startServer: sl(),
      stopServer: sl(),
      sendCommand: sl(),
    ),
  );

  sl.registerFactory(
        () => ServerListBloc(
      repository: sl(),
    ),
  );

  sl.registerFactory(
        () => ConsoleBloc(
      repository: sl(),
    ),
  );
}

class MinecraftServerManagerApp extends StatelessWidget {
  const MinecraftServerManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ServerListBloc>(
          create: (context) => sl<ServerListBloc>(),
        ),
        BlocProvider<ServerBloc>(
          create: (context) => sl<ServerBloc>(),
        ),
        BlocProvider<ConsoleBloc>(
          create: (context) => sl<ConsoleBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Minecraft Server Manager',
        debugShowMaterialGrid: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
      ),
    );
  }
}