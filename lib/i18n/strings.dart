import 'package:flutter/widgets.dart';
import '../services/locale_controller.dart';

class S {
  final String languageCode;
  S(this.languageCode);

  static S of(BuildContext context) {
    return S(LocaleController.current.value.languageCode);
  }

  String t(String key) {
    final Map<String, Map<String, String>> dict = {
      'pt': {
        // gerais
        'app.settings': 'Configurações',
        'app.language': 'Idioma',
        'app.favorites': 'Favoritos',
        'app.help_policies': 'Ajuda & Políticas',
        'app.my_data': 'Meus Dados',
        'app.sign_out': 'Sair',
        // navbar
        'nav.home': 'Início',
        'nav.feed': 'Feed',
        'nav.favorites': 'Favoritos',
        'nav.map': 'Mapa',
        'nav.settings': 'Configurações',
        // idioma
        'lang.title': 'Idioma',
        'lang.select': 'Selecione o idioma do aplicativo',
        'dialog.ok': 'OK',
        'dialog.language_changed': 'Idioma Alterado',
        'dialog.language_changed_to': 'O idioma foi alterado para {lang}',
        // login
        'login.welcome': 'Bem-vindo de volta!',
        'login.subtitle': 'Faça login para continuar sua jornada',
        'login.email': 'E-mail*',
        'login.password': 'Senha*',
        'login.forgot': 'Esqueceu sua senha?',
        'login.captcha': 'Verificação CAPTCHA',
        'login.captcha_hint': 'Digite o código',
        'login.or': 'ou',
        'login.google': 'Continuar com Google',
        'login.no_account': 'Não tem uma conta?',
        'login.signup': 'CADASTRE-SE',
        'login.signin': 'ENTRAR',
        // search/home
        'home.welcome_title': 'YourTour',
        'home.welcome_sub': 'Descubra lugares incríveis',
        'home.search_hint': 'Pesquise seu local...',
        'home.nearby': 'Locais por perto',
        'home.filters': 'Filtros',
        'home.to_visit': 'Locais para conhecer',
        'home.details': 'Ver Detalhes',
        // feed
        'feed.title': 'YouTour Feed',
        'feed.empty_title': 'Nenhuma publicação ainda',
        'feed.empty_subtitle':
            'Seja o primeiro a compartilhar uma experiência turística!',
        'feed.create_post': 'Criar Publicação',
        'feed.caption_hint': 'Compartilhe sua experiência turística...',
        'feed.location_hint': 'Localização',
        'feed.post_created': 'Publicação criada!',
        'common.cancel': 'Cancelar',
        'common.post': 'Publicar',
      },
      'en': {
        // general
        'app.settings': 'Settings',
        'app.language': 'Language',
        'app.favorites': 'Favorites',
        'app.help_policies': 'Help & Policies',
        'app.my_data': 'My Data',
        'app.sign_out': 'Sign out',
        // navbar
        'nav.home': 'Home',
        'nav.feed': 'Feed',
        'nav.favorites': 'Favorites',
        'nav.map': 'Map',
        'nav.settings': 'Settings',
        // language
        'lang.title': 'Language',
        'lang.select': 'Select the app language',
        'dialog.ok': 'OK',
        'dialog.language_changed': 'Language Changed',
        'dialog.language_changed_to': 'Language changed to {lang}',
        // login
        'login.welcome': 'Welcome back!',
        'login.subtitle': 'Sign in to continue your journey',
        'login.email': 'Email*',
        'login.password': 'Password*',
        'login.forgot': 'Forgot your password?',
        'login.captcha': 'CAPTCHA Verification',
        'login.captcha_hint': 'Enter the code',
        'login.or': 'or',
        'login.google': 'Continue with Google',
        'login.no_account': 'Don’t have an account?',
        'login.signup': 'SIGN UP',
        'login.signin': 'SIGN IN',
        // search/home
        'home.welcome_title': 'YourTour',
        'home.welcome_sub': 'Discover amazing places',
        'home.search_hint': 'Search your location...',
        'home.nearby': 'Nearby places',
        'home.filters': 'Filters',
        'home.to_visit': 'Places to visit',
        'home.details': 'See Details',
        // feed
        'feed.title': 'YouTour Feed',
        'feed.empty_title': 'No posts yet',
        'feed.empty_subtitle': 'Be the first to share a travel experience!',
        'feed.create_post': 'Create Post',
        'feed.caption_hint': 'Share your travel experience...',
        'feed.location_hint': 'Location',
        'feed.post_created': 'Post created!',
        'common.cancel': 'Cancel',
        'common.post': 'Post',
      },
      'es': {
        // generales
        'app.settings': 'Configuración',
        'app.language': 'Idioma',
        'app.favorites': 'Favoritos',
        'app.help_policies': 'Ayuda y Políticas',
        'app.my_data': 'Mis Datos',
        'app.sign_out': 'Cerrar sesión',
        // navbar
        'nav.home': 'Inicio',
        'nav.feed': 'Feed',
        'nav.favorites': 'Favoritos',
        'nav.map': 'Mapa',
        'nav.settings': 'Configuración',
        // idioma
        'lang.title': 'Idioma',
        'lang.select': 'Seleccione el idioma de la aplicación',
        'dialog.ok': 'OK',
        'dialog.language_changed': 'Idioma cambiado',
        'dialog.language_changed_to': 'El idioma se cambió a {lang}',
        // login
        'login.welcome': '¡Bienvenido de nuevo!',
        'login.subtitle': 'Inicia sesión para continuar tu viaje',
        'login.email': 'Correo electrónico*',
        'login.password': 'Contraseña*',
        'login.forgot': '¿Olvidaste tu contraseña?',
        'login.captcha': 'Verificación CAPTCHA',
        'login.captcha_hint': 'Ingrese el código',
        'login.or': 'o',
        'login.google': 'Continuar con Google',
        'login.no_account': '¿No tienes una cuenta?',
        'login.signup': 'REGISTRARSE',
        'login.signin': 'INICIAR SESIÓN',
        // search/home
        'home.welcome_title': 'YourTour',
        'home.welcome_sub': 'Descubre lugares increíbles',
        'home.search_hint': 'Busca tu ubicación...',
        'home.nearby': 'Lugares cercanos',
        'home.filters': 'Filtros',
        'home.to_visit': 'Lugares para visitar',
        'home.details': 'Ver detalles',
        // feed
        'feed.title': 'YouTour Feed',
        'feed.empty_title': 'Aún no hay publicaciones',
        'feed.empty_subtitle': '¡Sé el primero en compartir una experiencia de viaje!',
        'feed.create_post': 'Crear publicación',
        'feed.caption_hint': 'Comparte tu experiencia de viaje...',
        'feed.location_hint': 'Ubicación',
        'feed.post_created': '¡Publicación creada!',
        'common.cancel': 'Cancelar',
        'common.post': 'Publicar',
      },
    };
    final table = dict[languageCode] ?? dict['pt']!;
    return table[key] ?? key;
  }
}
