abstract final class CapacityStrings {
  static const title = 'Modelo de equilibrio';
  static const distribution = 'Reparto de la carga';
  static const entry = 'Editar carga entre integrantes';
  static const entryHelp =
      'Configura las propuestas y el reparto de capacidad.';
  static const heading = '¿Qué es un reparto justo aquí?';
  static const explanation =
      'Cada persona propone su capacidad. Quien administra aprueba el reparto completo.';
  static const scheduling =
      'Se aplica el próximo lunes en la zona horaria del hogar, sin cambiar periodos anteriores.';
  static const invalidation =
      'Si cambian los integrantes, hay que aprobar de nuevo: los porcentajes no se ajustan solos.';
  static const current = 'Reparto vigente';
  static const upcoming = 'Reparto programado';
  static const unconfigured = 'La capacidad todavía no está configurada.';
  static const noUpcoming = 'No hay un reparto programado.';
  static const proposals = 'Propuestas de los integrantes';
  static const ownProposal = 'Mi propuesta de capacidad';
  static const saveProposal = 'Guardar mi propuesta';
  static const proposalSaved =
      'Tu propuesta fue guardada. No modifica el reparto aprobado.';
  static const approve = 'Aprobar reparto';
  static const approval = 'Revisar reparto completo';
  static const approvalHelp =
      'Estos porcentajes son una aprobación del reparto, no una edición de las propuestas de otras personas.';
  static const approvalSaved =
      'Reparto aprobado. El reparto vigente no cambia hasta el próximo periodo.';
  static const zeroHelp =
      'Una capacidad de 0 % no aporta porcentaje al reparto aprobado.';
  static const history = 'Historial de aprobaciones';
  static const historyHelp =
      'El historial conserva las aprobaciones reemplazadas o inaplicables. Su fecha prevista no significa que hayan llegado a estar vigentes.';
  static const showHistory = 'Ver historial de aprobaciones';
  static const moreHistory = 'Ver más aprobaciones';
  static const emptyHistory = 'Todavía no hay aprobaciones.';
  static const noMembers =
      'No hay integrantes activos para configurar un reparto.';
  static const unset = 'Sin propuesta';
  static const retry = 'Reintentar';
  static const refresh = 'Actualizar capacidad';
  static const unavailable = 'Este hogar ya no es el hogar activo.';
  static const preview = 'Previsualización del reparto esperado';
  static const former = 'Antiguo integrante';
  static String percent(int value) => '$value %';
  static String total(int value) => value == 100
      ? 'El reparto suma 100 %. Listo para aprobar.'
      : 'Suma $value %. El reparto debe sumar 100 %.';
  static String effective(String date) => 'Inicio previsto: $date';
  static String approver(String name) => 'Aprobado por $name';
  static String approvedAt(String time) => 'Aprobación: $time UTC';
}
