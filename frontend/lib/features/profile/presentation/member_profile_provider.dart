import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/result/result_value.dart';
import '../../../core/session/session_controller.dart';
import '../data/profile_repository_impl.dart';
import '../domain/profile_entities.dart';

final memberProfileProvider = FutureProvider.autoDispose
    .family<MemberProfile, (String, String)>((ref, key) async {
      final user = ref.watch(
        sessionControllerProvider.select((value) => value.user),
      );
      if (user == null) throw const UnauthenticatedException();
      if (user.activeHouseholdId != key.$1) {
        throw const NetworkException(NetworkFailure.cancelled);
      }
      return (await ref
              .watch(profileRepositoryProvider)
              .profile(key.$1, userId: key.$2))
          .valueOrThrow;
    });
