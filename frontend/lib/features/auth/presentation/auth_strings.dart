abstract final class AuthStrings {
  static const welcomeStart = 'La casa,\na partes ';
  static const welcomeAccent = 'justas.';
  static const welcomeBody =
      'Repartan las tareas de la casa según el tiempo y la energía real de cada quien.';
  static const createAccount = 'Crear cuenta';
  static const existingAccount = 'Ya tengo una cuenta';
  static const legal = 'Al continuar aceptas las Condiciones y la Privacidad.';
  static const phoneTitle = '¿Cuál es tu ';
  static const phoneAccent = 'número?';
  static const phoneBody =
      'Lo usarás para entrar. Te enviaremos un código por SMS para confirmar que es tuyo.';
  static const phonePrivacy = 'Solo lo verán las personas de tu hogar.';
  static const sendCode = 'Enviar código';
  static const loginLink = '¿Ya tienes cuenta? Inicia sesión';
  static const codeTitle = 'Revisa tus ';
  static const codeAccent = 'mensajes';
  static const verify = 'Verificar';
  static const resend = 'Pedir otro código';
  static const changeNumber = '¿Número equivocado? Cámbialo';
  static const codeExpired = 'El código expiró. Pide uno nuevo.';
  static const passwordTitle = 'Crea una ';
  static const passwordAccent = 'contraseña';
  static const passwordBody = 'La usarás junto a tu número para entrar.';
  static const nameTitle = '¿Cómo te ';
  static const nameAccent = 'llamas?';
  static const nameBody =
      'Así te verán las demás personas de tu hogar. Puede ser un apodo.';
  static const name = 'Nombre';
  static const preview = 'Vista previa';
  static const previewTask = 'Te toca: Poner la lavadora · hoy';
  static const characterTitle = 'Elige tu ';
  static const characterAccent = 'personaje';
  static const characterBody = 'Así te reconocerán en cada tarea del hogar.';
  static const chosenTitle = 'Así te verán en ';
  static const chosenAccent = 'casa';
  static const chosenBody = 'Podrás cambiarlo cuando quieras.';
  static const changeCharacter = 'Cambiar personaje';
  static const createMyAccount = 'Crear mi cuenta';
  static const skipCharacter = 'Hacerlo más tarde';
  static const createdTitle = '¡Ya estás ';
  static const createdAccent = 'dentro,';
  static const createdBody =
      'Tu cuenta está lista. Ahora arma tu hogar o únete al de alguien con un código.';
  static const next = 'LO QUE SIGUE';
  static const nextSteps = [
    'Crea tu hogar o únete con un código',
    'Cuenta cómo es tu semana',
    'Repartan las tareas con justicia',
  ];
  static const start = 'Empezar';
  static const loginTitle = 'Hola de ';
  static const loginAccent = 'nuevo';
  static const loginBody = 'Entra con tu número y tu contraseña.';
  static const forgotPassword = '¿Olvidaste tu contraseña?';
  static const enter = 'Entrar';
  static const newAccountLink = '¿Aún no tienes cuenta? Crear cuenta';
  static const recoverTitle = '¿Olvidaste tu ';
  static const recoverAccent = 'contraseña?';
  static const recoverBody =
      'Pasa hasta en las mejores casas. Escribe el número de tu cuenta y te enviaremos un código.';
  static const rememberedPassword = '¿La recordaste? Inicia sesión';
  static const newPasswordTitle = 'Tu nueva ';
  static const newPasswordBody = 'Que sea distinta a la que usabas antes.';
  static const newPassword = 'Nueva contraseña';
  static const repeatPassword = 'Repite la contraseña';
  static const passwordsMatch = 'Las contraseñas coinciden.';
  static const passwordsMismatch = 'Las contraseñas no coinciden.';
  static const saveAndEnter = 'Guardar y entrar';
  static const dinner = 'Cocinar la cena';
  static const dinnerDetails = '45 min · Alimentación';
  static const dogWalk = 'Pasear a Lola';
  static const dogDetails = '30 min · Mascotas';

  static String codeSentTo(String phone) =>
      'Enviamos un código de 6 dígitos al $phone.';
  static String resendIn(String remaining) =>
      '¿No te llegó? Podrás pedir otro en $remaining';
  static String lockedFor(String remaining) =>
      'Podrás volver a intentarlo en $remaining';
}
