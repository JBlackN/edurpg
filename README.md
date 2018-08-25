# eduRPG

Prototyp webové aplikace k diplomové práci &bdquo;Gamifikace studia na FIT ČVUT&rdquo;.

## Instalace

Postup instalace předpokládá linuxový systém a není jediný možný.

### Závislosti

* [PostgreSQL](https://www.postgresql.org/)
* [Ruby](https://www.ruby-lang.org/en/)
* [Bundler](https://bundler.io/)
* [NodeJS](https://nodejs.org/en/)
* [Yarn](https://yarnpkg.com/en/)

* __vývojové prostředí jazyka C__ s příslušnými hlavičkami a knihovnami (z důvodu kompilace tzv. nativních rozšíření některých závislostí v jazyce Ruby)
* __SMTP server__ (volitelně k funkci dvoufázového ověření souhlasu se zpracováním fotografie uživatele, v následujících  instrukcích předpokládám použití služby [Mailgun](https://www.mailgun.com/))

### Postup

Předpokládám, že se prototyp aplikace nachází ve složce `~/edurpg/`. Příkazy jsou uvedeny `neproporcionálním` písmem a začínají znakem `$`.

1.  Vytvořte PostgreSQL uživatele `edurpg` s heslem `edurpg` (nepoužíváte-li jiné než výchozí nastavení v souboru [config/database.yml](config/database.yml)):

    1.  `$ sudo su postgres`,

    2.  `$ psql`,

    3.  `$ CREATE ROLE edurpg WITH LOGIN PASSWORD 'edurpg' SUPERUSER CREATEROLE CREATEDB;`,

    4.  `$ \q`,

    5.  `$ exit`.

2.  Přesuňte se do složky s prototypem aplikace: `$ cd ~/edurpg`.

3.  Inicializujte konfigurační soubor aplikace s použitím přiložené
    šablony:
    `$ cp `[`config/application.yml.template`](config/application.yml.template)` config/application.yml`.

4.  Přejděte na adresu <https://auth.fit.cvut.cz/manager/index.xhtml>
    v preferovaném webovém prohlížeči a přihlaste se do aplikace App
    Manager. Vytvořte nový projekt a k němu novou *webovou* aplikaci.
    URI k přesměrování nastavte na
    <http://localhost:3000/auth/fitcvut_oauth2/callback>. Zkopírujte
    tzv. `Client ID` a `Client secret` do příslušných proměnných v souboru
    `~/edurpg/config/application.yml`.

5.  Volitelně přejděte na adresu <https://www.mailgun.com/> a
    zaregistrujte se. Po přihlášení přejděte na stránku `Domains` a klikněte na
    doménu začínající slovem `sandbox`. Zkopírujte údaje do příslušných
    proměnných v souboru `~/edurpg/config/application.yml` dle
    následující tabulky.

    | Proměnná prostředí | Informace o doméně Mailgun |
    | ------------------ | -------------------------- |
    | `SMTP_ADDRESS`     | `smtp.mailgun.org`         |
    | `SMTP_PORT`        | `'587'` (včetně apostrofů) |
    | `SMTP_DOMAIN`      | DOMAIN                     |
    | `SMTP_USER_NAME`   | Default SMTP Login         |
    | `SMTP_PASSWORD`    | Default Password           |

6.  Nainstalujte závislosti: `$ bundle install && yarn install`.

7.  Inicializujte databázi aplikace:
    `$ bin/rails db:create && bin/rails db:migrate`.

8.  Nastartujte lokální server: `$ bin/rails s`.

9.  Přejděte na adresu <http://localhost:3000> v preferovaném webovém
    prohlížeči, přihlaste se do aplikace a vyplňte a odešlete souhlasy
    se zpracováním osobních údajů.

10. Vyčkejte na dokončení prvotní inicializace aplikace (jedna až dvě
    minuty).

## Dokumentace

Dokumentaci lze vygenerovat příkazem `bin/rails rdoc` z kořenové složky aplikace.

## Architektura aplikace

Architekturu aplikace popisuje následující tabulka:

| Složka, nebo soubor                                                  | Obsah                                             |
| -------------------------------------------------------------------- | ------------------------------------------------- |
| [`app/assets/images/`](app/assets/images)                            | Výchozí obrázky                                   |
| [`app/assets/javascripts/`](app/assets/javascripts)                  | Skripty stránek aplikace                          |
| [`app/assets/stylesheets/`](app/assets/stylesheets)                  | Styly stránek aplikace                            |
| [`app/controllers/`](app/controllers)                                | Akce stránek aplikace                             |
| [`app/javascript/packs/`](app/javascript/packs)                      | Komponenty talentových stromů (`React`)           |
| [`app/models/`](app/models)                                          | Modely entit aplikace                             |
| [`app/services/`](app/services)                                      | Služby pro komunikaci s externími API             |
| [`app/views/`](app/views)                                            | Stránky aplikace                                  |
| `config/application.yml`                                             | Nastavení proměnných prostředí aplikace           |
| [`config/application.yml.template`](config/application.yml.template) | Šablona pro `application.yml`                     |
| [`config/database.yml`](config/database.yml)                         | Nastavení databáze                                |
| [`config/initializers/figaro.rb`](config/initializers/figaro.rb)     | Nastavení povinných proměnných prostředí aplikace |
| [`config/initializers/omniauth.rb`](config/initializers/omniauth.rb) | Nastavení poskytovatele autentizace               |
| [`config/routes.rb`](config/routes.rb)                               | Cesty aplikace                                    |
| [`db/migrate/`](db/migrate)                                          | Skripty pro inicializaci databáze                 |
| [`db/seeds/`](db/seeds)                                              | Skripty pro naplnění databáze počátečními daty    |
