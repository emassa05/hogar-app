import '../errors/api_error_code.dart';
import '../errors/app_exception.dart';
import '../errors/field_validation_error.dart';

abstract final class ErrorMessages {
  static String forException(AppException error) => switch (error) {
    NetworkException(:final kind) =>
      kind == NetworkFailure.timeout
          ? 'La conexión tardó demasiado. Vuelve a intentarlo.'
          : 'No pudimos conectarnos. Revisa tu conexión y vuelve a intentarlo.',
    UnauthenticatedException() => 'Tu sesión terminó. Vuelve a entrar.',
    UnexpectedException() =>
      'No pudimos completar la acción. Vuelve a intentarlo.',
    ApiException(
      :final code,
      :final remainingAttempts,
      :final retryAfterSeconds,
    ) =>
      code == ApiErrorCode.invalidCredentials && remainingAttempts != null
          ? 'La contraseña no coincide con ese número. ${attemptsLeft(remainingAttempts)}'
          : code == ApiErrorCode.verificationCodeInvalid &&
                remainingAttempts != null
          ? 'El código no coincide. ${attemptsLeft(remainingAttempts)}'
          : code == ApiErrorCode.accountLocked && retryAfterSeconds != null
          ? 'La cuenta está bloqueada temporalmente. Espera antes de volver a entrar.'
          : forCode(code),
  };

  static String attemptsLeft(int count) =>
      count == 1 ? 'Te queda 1 intento.' : 'Te quedan $count intentos.';

  static String forCode(ApiErrorCode code) => switch (code) {
    ApiErrorCode.verificationCodeInvalid =>
      'El código no coincide. Revisa el SMS e inténtalo otra vez.',
    ApiErrorCode.unauthenticated ||
    ApiErrorCode.invalidRefreshToken => 'Tu sesión terminó. Vuelve a entrar.',
    ApiErrorCode.invalidCredentials =>
      'El número o la contraseña no coinciden.',
    ApiErrorCode.invalidVerificationToken =>
      'La verificación terminó. Pide un código nuevo.',
    ApiErrorCode.phoneAlreadyRegistered =>
      'Este número ya tiene una cuenta. Puedes iniciar sesión.',
    ApiErrorCode.verificationNotFound ||
    ApiErrorCode.verificationExpired => 'El código expiró. Pide uno nuevo.',
    ApiErrorCode.verificationAttemptsExceeded =>
      'Se agotaron los intentos. Pide un código nuevo.',
    ApiErrorCode.verificationResendTooSoon =>
      'Espera antes de pedir otro código.',
    ApiErrorCode.rateLimited =>
      'Has hecho varios intentos. Espera un momento y vuelve a intentarlo.',
    ApiErrorCode.accountLocked => 'La cuenta está bloqueada temporalmente.',
    ApiErrorCode.smsDeliveryFailed =>
      'No pudimos enviar el SMS. Vuelve a intentarlo.',
    ApiErrorCode.forbidden || ApiErrorCode.participationNotOwned =>
      'No tienes permiso para realizar esta acción.',
    ApiErrorCode.adminRequired => 'Esta acción requiere administrar el hogar.',
    ApiErrorCode.householdNotFound => 'No pudimos encontrar este hogar.',
    ApiErrorCode.memberNotFound => 'Esta persona ya no pertenece al hogar.',
    ApiErrorCode.invitationNotFound =>
      'El código no corresponde a una invitación vigente.',
    ApiErrorCode.invitationExpired =>
      'La invitación expiró. Pide un código nuevo a quien administra el hogar.',
    ApiErrorCode.alreadyMember => 'Ya perteneces a este hogar.',
    ApiErrorCode.lastAdminMustTransfer =>
      'Primero da la administración a otra persona del hogar.',
    ApiErrorCode.templatesAlreadyApplied =>
      'Este hogar ya eligió sus plantillas.',
    ApiErrorCode.versionConflict =>
      'Otra persona cambió estos datos. Revisa la versión actual antes de guardar.',
    ApiErrorCode.idempotencyKeyReused =>
      'Esta acción cambió. Vuelve a intentarlo.',
    ApiErrorCode.validationError =>
      'Revisa los datos indicados antes de continuar.',
    ApiErrorCode.conflict =>
      'Los datos cambiaron. Revisa el estado actual e inténtalo otra vez.',
    ApiErrorCode.taskCompletedLocked =>
      'La tarea ya está completada y no se puede editar.',
    ApiErrorCode.participationNotAvailable =>
      'Esta participación ya no está disponible.',
    ApiErrorCode.assigneeRestricted =>
      'Una restricción impide asignar esta tarea.',
    ApiErrorCode.similarTasksFound =>
      'Encontramos tareas parecidas. Revísalas antes de continuar.',
    ApiErrorCode.swapRequestNotPending => 'Este intercambio ya fue resuelto.',
    ApiErrorCode.suggestionNotPending => 'Esta sugerencia ya fue resuelta.',
    ApiErrorCode.capacityNotConfigured =>
      'Primero hay que configurar el reparto de capacidad.',
    ApiErrorCode.capacitySumInvalid =>
      'El reparto debe incluir a todas las personas y sumar 100 %.',
    ApiErrorCode.unplannedTaskOutOfRange =>
      'La fecha debe estar entre hoy y los últimos siete días.',
    ApiErrorCode.attachmentTooLarge =>
      'La foto supera el tamaño permitido de 5 MB.',
    ApiErrorCode.unsupportedMediaType => 'Usa una foto JPEG, PNG o WebP.',
    ApiErrorCode.notFound ||
    ApiErrorCode.taskNotFound ||
    ApiErrorCode.routineNotFound ||
    ApiErrorCode.swapRequestNotFound ||
    ApiErrorCode.commentNotFound ||
    ApiErrorCode.suggestionNotFound => 'Este contenido ya no está disponible.',
    ApiErrorCode.internalError ||
    ApiErrorCode.serviceUnavailable ||
    ApiErrorCode.unknown =>
      'El servicio no está disponible. Vuelve a intentarlo.',
  };

  static String forField(FieldValidationError error) => switch (error.code) {
    'required' => 'Completa este campo.',
    'too_short' || 'password_too_short' => 'El texto es demasiado corto.',
    'too_long' => 'El texto supera el máximo permitido.',
    'password_missing_uppercase' => 'Añade una letra mayúscula.',
    'password_missing_digit_or_symbol' => 'Añade un número o un símbolo.',
    'out_of_range' => 'Elige un valor dentro del rango permitido.',
    'unknown_key' || 'invalid_choice' => 'Elige una opción del catálogo.',
    'duplicated' => 'Esta opción ya está seleccionada.',
    'conflicting_values' =>
      'Esta opción es incompatible con los datos actuales.',
    _ => 'Revisa el formato de este campo.',
  };

  static String? field(AppException? error, String field) {
    if (error is! ApiException) return null;
    for (final issue in error.fields) {
      if (issue.fieldName == field || issue.fieldName.startsWith('$field.')) {
        return forField(issue);
      }
    }
    return null;
  }
}
