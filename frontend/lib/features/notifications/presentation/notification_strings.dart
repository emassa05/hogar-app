abstract final class NotificationStrings {
  static const entry = 'Alertas y recordatorios';
  static const title = 'Avisos';
  static const heading = 'Qué quieres que te avise';
  static const help =
      'Cada integrante decide sus propios avisos. Estos ajustes personales se aplican a todos tus hogares y no cambian el reparto.';
  static const dependency =
      'El servicio de ajustes de avisos no está disponible (404). No podemos confirmar tus ajustes. Puedes reintentar cuando esté disponible.';
  static const save = 'Guardar avisos';
  static const saved = 'Ajustes de avisos guardados.';
  static const uncertain =
      'No se pudo confirmar el guardado. Al reintentar, consultaremos los ajustes del servidor antes de volver a guardar.';
  static const muted = 'Silenciar todos los avisos';
  static const tasks = 'Tareas';
  static const lead = 'Anticipación en minutos';
  static const leadHelp =
      'De 5 a 10080 minutos. Deja el campo vacío para no recibir recordatorios previos.';
  static const leadError =
      'Introduce un número entero entre 5 y 10080, o deja el campo vacío.';
  static const sharing = 'Reparto';
  static const quiet = 'Horario de descanso';
  static const quietHelp =
      'Los avisos que caen dentro de este horario se descartan: no se acumulan para la mañana ni hay excepciones por prioridad. El horario puede cruzar la medianoche y se interpreta en la zona horaria de cada hogar.';
  static const start = 'Desde';
  static const end = 'Hasta';
  static const timeError =
      'Introduce una hora válida en formato HH:MM (24 horas).';
  static const labels = {
    'task_reminder': 'Recordatorios de tareas próximas',
    'task_due': 'Tareas vencidas',
    'routine_without_candidate': 'Rutinas sin candidato',
    'suggestion_pending': 'Nuevas sugerencias',
    'suggestion_resolved': 'Sugerencias resueltas',
    'swap_request': 'Solicitudes de intercambio',
    'swap_resolved': 'Intercambios resueltos',
  };
}
