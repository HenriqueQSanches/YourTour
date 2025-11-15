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
      },

    };
    final table = dict[languageCode] ?? dict['pt']!;
    return table[key] ?? key;
  }
}


