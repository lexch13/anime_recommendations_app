import 'dart:async';

import 'package:boilerplate/data/local/constants/db_constants.dart';
import 'package:boilerplate/data/local/datasources/anime/anime_datasource.dart';
import 'package:boilerplate/data/local/datasources/token/token_datasource.dart';
import 'package:boilerplate/data/local/datasources/user/user_datasource.dart';
import 'package:boilerplate/data/network/apis/animes/anime_api.dart';
import 'package:boilerplate/data/network/apis/users/users_api.dart';
import 'package:boilerplate/data/repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/utils/encryption/xxtea.dart';
import 'package:inject/inject.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'netwok_module.dart';

@module
class LocalModule extends NetworkModule {
  // DI variables:--------------------------------------------------------------
  Future<Database> database;

  // constructor
  // Note: Do not change the order in which providers are called, it might cause
  // some issues
  LocalModule() {
    database = provideDatabase();
  }

  // DI Providers:--------------------------------------------------------------
  /// A singleton database provider.
  ///
  /// Calling it multiple times will return the same instance.
  @provide
  @singleton
  @asynchronous
  Future<Database> provideDatabase() async {
    // Key for encryption
    var encryptionKey = "";

    // Get a platform-specific directory where persistent app data can be stored
    final appDocumentDir = await getApplicationDocumentsDirectory();

    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDir.path, DBConstants.DB_NAME);

    // Check to see if encryption is set, then provide codec
    // else init normal db with path
    var database;
    if (encryptionKey.isNotEmpty) {
      // Initialize the encryption codec with a user password
      var codec = getXXTeaCodec(password: encryptionKey);
      database = await databaseFactoryIo.openDatabase(dbPath, codec: codec);
    } else {
      database = await databaseFactoryIo.openDatabase(dbPath);
    }

    // Return database instance
    return database;
  }

  // DataSources:---------------------------------------------------------------
  // Define all your data sources here
  /// A singleton post dataSource provider.
  ///
  /// Calling it multiple times will return the same instance.
  @provide
  @singleton
  AnimeDataSource providePostDataSource() => AnimeDataSource(database);

  @provide
  @singleton
  UserDataSource provideUserDataSource() => UserDataSource(database);

  @provide
  @singleton
  TokenDataSource provideTokenDataSource() => TokenDataSource(database);

  // DataSources End:-----------------------------------------------------------

  /// A singleton repository provider.
  ///
  /// Calling it multiple times will return the same instance.
  @provide
  @singleton
  Repository provideRepository(
    AnimeApi animeApi,
    UsersApi usersApi,
    SharedPreferenceHelper preferenceHelper,
    AnimeDataSource postDataSource,
    UserDataSource userDataSource,
    TokenDataSource tokenDataSource,
  ) =>
      Repository(animeApi, usersApi, preferenceHelper, postDataSource, userDataSource, tokenDataSource);
}
