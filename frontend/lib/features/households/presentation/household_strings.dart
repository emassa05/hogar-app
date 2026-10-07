abstract final class HouseholdStrings {
  static const sensitiveArea = 'Zona sensible';
  static const leaveQuestion = '¿Abandonar este hogar?';
  static const leaveHelp =
      'Dejarás de pertenecer a este hogar. Tu historial se conserva. Para volver necesitarás una invitación.';
  static const leaveConfirmed =
      'Ya no perteneces a este hogar. Elige otro hogar o crea uno nuevo.';
  static const leaveUncertain =
      'No pudimos confirmar la salida. Reintenta para comprobar si todavía perteneces al hogar.';
  static const transferBeforeLeaving =
      'Antes de salir, da administración a otra persona desde Integrantes. Si eres el único integrante, no puedes abandonar el hogar.';
  static const manageMembers = 'Ir a Integrantes';
  static String leaveHousehold(String name) => 'Abandonar $name';
  static const avatarSaved =
      'El personaje ya está guardado. Falta guardar el perfil doméstico.';
  static const preferencesPartSaved =
      'Parte de las preferencias está guardada. Falta completar los cambios.';
  static const restrictionsPartSaved =
      'Parte de las restricciones está guardada. Falta completar los cambios.';
  static const memberRoleSaved =
      'El permiso ya está guardado. Falta actualizar la lista del hogar.';
  static const memberRemoved =
      'La persona ya fue retirada. Falta actualizar la lista del hogar.';
  static const currentVersionLoaded =
      'Cargamos la versión actual. Revisa tus cambios antes de volver a guardar.';
  static const currentVersionUnavailable =
      'No pudimos cargar la versión actual. Reintenta antes de guardar.';
  static const start = 'Empezar';
  static const chooseTitle = '¿Cómo quieres entrar?';
  static const chooseBody =
      'Un hogar es el grupo de personas que comparten las tareas de una casa. Puedes pertenecer a más de uno.';
  static const create = 'Crear un hogar nuevo';
  static const createBody =
      'Defines el nombre, invitas a quien vive contigo y configuras cómo se reparte la carga.';
  static const join = 'Unirme con un código';
  static const joinBody =
      'Si alguien ya creó el hogar, te compartirá un código de 8 caracteres o un enlace.';
  static const profileLocal =
      'Tu perfil doméstico es propio de cada hogar. Allí defines tu disponibilidad, restricciones y preferencias.';
  static const newHousehold = 'Nuevo hogar';
  static const householdName = 'Nombre del hogar';
  static const householdHint = 'Casa Los Robles';
  static const nameHelp = 'Así lo verán el resto de integrantes.';
  static const templatesHint = 'Después podrás partir de una plantilla';
  static const templatesHintBody =
      'Familia, piso compartido, pareja, personas a cuidado o mascotas: cada una trae las tareas típicas de ese hogar. Se pueden editar o descartar.';
  static const continueLabel = 'Continuar';
  static const invite = 'Invitar';
  static const members = 'Integrantes';
  static const shareTitle = 'Comparte el código del hogar';
  static const copy = 'Copiar';
  static const copied = 'Código copiado';
  static const share = 'Compartir';
  static const regenerate = 'Regenerar código';
  static const invitationHelp =
      'El código caduca en 7 días. Puedes regenerarlo cuando quieras.';
  static const adminHelp =
      'Solo quienes administran pueden retirar integrantes, cambiar permisos o editar el modelo de equilibrio.';
  static const you = 'Tú';
  static const admin = 'Administración';
  static const member = 'Integrante';
  static const refreshMembers = 'Actualizar integrantes';
  static const makeAdmin = 'Dar administración';
  static const makeMember = 'Cambiar a integrante';
  static const removeMember = 'Retirar del hogar';
  static const removeQuestion = '¿Retirar a esta persona del hogar?';
  static const cancel = 'Cancelar';
  static const confirm = 'Confirmar';
  static const profile = 'Mi perfil doméstico';
  static const accountAvatar = 'Tu personaje te identifica en toda la app.';
  static const nickname = 'Cómo te llamamos';
  static const nicknameShort = 'Se muestra a los demás integrantes.';
  static const nicknameLength = 'Usa un máximo de 40 caracteres.';
  static const capacityUnset = 'Sin definir';
  static const saveAndContinue = 'Guardar y continuar';
  static const roleAdmin = 'Administra el hogar';
  static const chooseTarget = 'Elige una categoría o actividad del catálogo.';
  static const chooseEndDate = 'Elegir fecha de término';
  static const endDateNeeded = 'Elige hasta cuándo dura la restricción.';
  static const appliedEmpty =
      'Empezaste con un hogar vacío. Podrás crear tareas cuando quieras.';
  static const codeHint = 'XXXX-XXXX';
  static const joinNote =
      'Tu perfil doméstico es propio de cada hogar: podrás completarlo después de unirte.';
  static const nicknameHelp =
      'Se muestra a los demás integrantes. Si lo dejas vacío, usamos el nombre de tu cuenta.';
  static const capacity = 'Capacidad que puedo asumir';
  static const less = 'Menos';
  static const more = 'Más';
  static const capacityHelp =
      'Es una referencia, no una promesa: el hogar puede ajustarla entre todas y todos en el modelo de equilibrio.';
  static const saveProfile = 'Guardar y entrar al hogar';
  static const availability = 'Disponibilidad';
  static const availabilityTitle = 'Cuándo puedes asumir tareas';
  static const availabilityBody =
      'Marca los tramos en los que sí puedes. El reparto y las sugerencias respetarán siempre lo que indiques aquí.';
  static const morning = 'Mañana';
  static const afternoon = 'Tarde';
  static const evening = 'Noche';
  static const available = 'Disponible';
  static const unavailable = 'No disponible';
  static const periodHelp = 'Mañana 7–13 · Tarde 13–20 · Noche 20–23';
  static const restrictions = 'Restricciones';
  static const addRestriction = 'Añadir restricción';
  static const editRestriction = 'Editar restricción';
  static const removeRestriction = 'Eliminar restricción';
  static const noRestrictions = 'Todavía no has añadido restricciones.';
  static const restrictionHelp =
      'Elige una categoría o actividad del catálogo. Las restricciones impiden su asignación.';
  static const category = 'Categoría';
  static const activity = 'Actividad';
  static const permanent = 'Permanente';
  static const temporary = 'Temporal';
  static const endDate = 'Fecha de término';
  static const save = 'Guardar';
  static const saved = 'Cambios guardados';
  static const preferences = 'Preferencias';
  static const preferencesTitle = 'Qué te va y qué no';
  static const preferencesBody =
      'Las sugerencias de reparto usan estas preferencias como criterio, después de la disponibilidad y las restricciones.';
  static const preferred = 'Tareas que prefiero';
  static const preferredHelp = 'Se te propondrán antes que a otras personas.';
  static const unable = 'Tareas que no puedo hacer';
  static const unableHelp = 'Nunca se te asignarán automáticamente.';
  static const savePreferences = 'Guardar preferencias';
  static const emptyCatalog = 'El catálogo aún no tiene actividades.';
  static const templates = 'Plantillas';
  static const templatesTitle = 'Empieza con una base';
  static const templatesBody =
      'Elige las que se parecen a tu hogar; puedes combinar varias. Podrás editar, reasignar o borrar cualquier tarea después.';
  static const emptyTemplates =
      'Todavía no hay plantillas. Puedes empezar con un hogar vacío.';
  static const startEmpty = 'Empezar vacío';
  static const applied = 'La organización del hogar está lista';
  static const enterHome = 'Entrar al hogar';
  static const rotating = 'Rotativa';
  static const fixed = 'Fija';
  static const joinTitle = 'Unirme a un hogar';
  static const invitationCode = 'Código de invitación';
  static const invalidInvitation =
      'Introduce un código de 8 caracteres, como 7QK2-M9XA.';
  static const codeHelp =
      'Te lo comparte quien creó el hogar. Caduca a los 7 días.';
  static const preview = 'Ver hogar';
  static const joinHome = 'Unirme al hogar';
  static const openExisting = 'Entrar al hogar existente';
  static const retry = 'Reintentar';
  static const waiting = 'Cargando…';
  static const home = 'Inicio';
  static const homeSoon =
      'Pronto podrás organizar aquí las tareas de tu hogar.';
  static const myHouseholds = 'Mis hogares';
  static const household = 'Hogar';
  static const inactiveHousehold =
      'Este hogar ya no está activo. Vuelve a Hogar para continuar.';
  static const profilePreview = 'Así te ve el hogar';
  static const agreedCapacity = 'Capacidad acordada';
  static const allDay = 'Todo el día';
  static const editProfile = 'Editar perfil';
  static const foreignProfileReadOnly = 'Solo puedes editar tu propio perfil.';
  static const accountName = 'Nombre de tu cuenta';
  static const accountNameHelp = 'Se usa en toda la aplicación.';
  static const householdNickname = 'Apodo en este hogar';
  static const accountIdentitySaved =
      'El nombre y el personaje de tu cuenta están guardados. Falta guardar el apodo de este hogar.';
  static const saveChanges = 'Guardar cambios';
  static const editHousehold = 'Editar hogar';
  static const done = 'Volver al hogar';
  static const historyPreserved =
      'Su historial se conserva como antiguo integrante.';
  static const invitationRevocation =
      'El código caduca en 7 días. Regenerarlo invalida el código anterior.';
  static const activeHousehold = 'Hogar activo';
  static const switchHousehold = 'Cambiar a este hogar';
  static const noActiveHousehold =
      'No tienes un hogar activo. Elige uno de tus hogares.';
  static const noHouseholds = 'Todavía no perteneces a ningún hogar.';
  static const noMembers = 'No hay integrantes para mostrar.';
  static String householdCount(int count) =>
      'Perteneces a $count ${count == 1 ? 'hogar' : 'hogares'}';
  static const weekdays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  static const weekdayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static String memberCount(int count) =>
      '$count ${count == 1 ? 'integrante' : 'integrantes'}';
  static String taskCount(int count) =>
      '$count ${count == 1 ? 'tarea' : 'tareas'}';
  static String addTasks(int count) => 'Añadir ${taskCount(count)}';
  static String willAdd(int count) =>
      count == 1 ? 'Se añadirá 1 tarea' : 'Se añadirán $count tareas';
  static String templateCount(int count) =>
      '$count ${count == 1 ? 'plantilla' : 'plantillas'}';
  static String temporaryUntil(String date) => 'Temporal · hasta $date';
  static String endsOn(String date) => 'Hasta el $date';
  static String percent(int value) => '$value %';
  static String avatarOption(String name) => 'Personaje $name';
  static String memberOptions(String name) => 'Opciones para $name';
  static String restrictionOptions(String name) =>
      'Opciones de la restricción $name';
  static String codeLabel(String spelled) => 'Código del hogar: $spelled';
  static String appliedTasks(int count) =>
      'Se ${count == 1 ? 'añadió 1 tarea' : 'añadieron $count tareas'} a tu hogar.';
  static String shareMessage(String household, String code, String url) =>
      'Únete a «$household» en HogarApp con el código $code o desde $url';
}
