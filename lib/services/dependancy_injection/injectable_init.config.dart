// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../../repository/todo_repository.dart' as _i4;
import '../isar.dart' as _i3;
import '../todo_service.dart' as _i5;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    await gh.singletonAsync<_i3.IIsarService>(
      () => _i3.IsarService.create(),
      preResolve: true,
    );
    gh.factory<_i4.TodoRepository>(
        () => _i4.TodoRepositoryImpl(gh<_i3.IIsarService>()));
    gh.factory<_i5.TodoService>(
        () => _i5.TodoService(gh<_i4.TodoRepository>()));
    return this;
  }
}
