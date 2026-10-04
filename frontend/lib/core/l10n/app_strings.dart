abstract final class AppStrings {
  static const appName = 'HogarApp';
  static const back = 'Volver';
  static const retry = 'Reintentar';
  static const cancel = 'Cancelar';
  static const confirm = 'Confirmar';
  static const save = 'Guardar';
  static const continueAction = 'Continuar';
  static const loading = 'Cargando';
  static const requiredField = 'Completa este campo.';
  static const invalidPhone = 'Escribe un número de teléfono válido.';
  static const passwordLength = 'Usa entre 8 y 128 caracteres.';
  static const passwordUppercase = 'Añade una letra mayúscula.';
  static const passwordDigitOrSymbol = 'Añade un número o un símbolo.';
  static const nameLength = 'Usa un máximo de 40 caracteres.';
  static const password = 'Contraseña';
  static const phone = 'Número de teléfono';
  static const showPassword = 'Mostrar contraseña';
  static const hidePassword = 'Ocultar contraseña';
  static const countryChile = 'Chile, código de país +56';
  static const otp = 'Código de verificación de seis dígitos';
  static const safePassword = 'Contraseña segura';
  static const passwordMinimum = 'Al menos 8 caracteres';
  static const passwordCapital = 'Una letra mayúscula';
  static const passwordNumber = 'Un número o un símbolo';
  static const characterPicker = 'ELIGE UN PERSONAJE';
  static const noCharacter = 'Sin elegir';
  static const home = 'Inicio';
  static const comingSoon =
      'Próximamente podrás organizar las tareas de tu hogar.';
  static const foundation = 'Estamos preparando tu hogar.';
  static const chooseHousehold = 'Empezar';
  static const register = 'Crear cuenta';
  static const login = 'Iniciar sesión';
  static const recover = 'Recuperar contraseña';
  static const profile = 'Mi perfil doméstico';
  static const availability = 'Disponibilidad';
  static const preferences = 'Preferencias';
  static const templates = 'Plantillas';

  static String step(int current, int total) => 'Paso $current de $total';
  static String passwordScore(int score) => '$score de 4';
  static String character(String name) => 'Personaje $name';
  static String initials(String name) => 'Avatar de $name';
  static String timeRemaining(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
