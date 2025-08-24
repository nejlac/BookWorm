# \# 📚 BookWorm

# 

# > \*\*Seminarski rad iz predmeta Razvoj softvera 2\*\*  

# > Fakultet informacijskih tehnologija, Mostar

# 

# ---

# 

# BookWorm je  aplikacija kreirana za sve  ljubitelje knjiga koji žele da svoje čitalačko iskustvo podijele sa cijelim svijetom! 

# 

# \### 🌟 Šta možete raditi?

# 

# 🔸 \*\*Kreirajte svoju digitalnu biblioteku\*\* - organizujte svoje omiljene knjige  

# 🔸 \*\*Povežite se sa čitaocima\*\* - pronađite prijatelje sa sličnim ukusom  

# 🔸 \*\*Prihvatite izazove\*\* - pratite svoju statistiku čitanja  

# 🔸 \*\*Otkrijte nova dela\*\* - dobijajte personalizovane preporuke

# 

# ---

# 

# \## 🚀 Kako pokrenuti aplikaciju

# 

# \### 🔧 Backend konfiguracija

# 

# 1\. \*\*Klonirajte repozitorij\*\* i otvorite `BookWorm` folder

# 2\. \*\*Pronađite arhivu\*\* `fit-build-2025\_env.rar` u `BookWorm/BookWorm` direktorijumu

# 3\. \*\*Ekstraktujte\*\* `.env` file koristeći šifru: \*\*`fit`\*\*

# 4\. \*\*Otvorite terminal\*\* u `BookWorm/BookWorm` folderu i pokrenite:

# &nbsp;  ```bash

# &nbsp;  docker compose up --build

# &nbsp;  ```

# &nbsp;  \*Sačekajte da se sve uspješno izgradi\* ⏳

# 

# \### 💻 Desktop aplikacija

# 

# 1\. \*\*Aktivirajte developer mode\*\* (ukoliko već nije)

# 2\. \*\*Pronađite arhivu\*\* `fit-build-2025-08-24.zip` u glavnom folderu (BookWorm)

# 3\. \*\*Ekstraktujte arhivu\*\* - dobićete `Release` i `flutter-apk` foldere

# 4\. \*\*Pokrenite aplikaciju\*\* - otvorite `Release/bookworm\_desktop.exe`

# 

# \### 📱 Mobilna aplikacija

# 

# 1\. \*\*Idite u\*\* `flutter-apk` folder

# 2\. \*\*File `app-release.apk` prenijeti na emulator i sačekati da se instalira\*\* \*(Deinstalirati aplikaciju sa emulatora ukoliko je prije bila instalirana!)\*

# 3\. \*\*Prijavite se\*\* koristeći kredencijale ispod

# 

# ---

# 

# \## 🔐 Pristupni podaci

# 

# | Tip korisnika | Korisničko ime | Lozinka |

# |---------------|----------------|---------|

# | \*\*👑 Administrator\*\* | `dekstop` | `test` |

# | \*\*👤 Korisnik\*\* | `mobile` | `test` |

# 

# ---

# 

# \## ⚡ Napredne funkcionalnosti

# 

# \### 🐰 RabbitMQ mikroservis

# BookWorm koristi RabbitMQ mikroservis za automatsko slanje email obaveštenja korisniku kada admin prihvati knjigu koju je on kreirao. Kada korisnik kreira knjigu, ona se nalazi u submitted stanju, te odobravanjem iz tog stanja prelazi u accepted, što je okidač za slanje maila. 

# 

# ---

# 

# \## 🛠️ Tehnološki stek









# \- \*\*Backend:\*\* ASP.NET Core

# \- \*\*Frontend:\*\* Flutter (desktop i mobilna aplikacija)

# \- \*\*Baza podataka:\*\* SQL Server

# \- \*\*Message Broker:\*\* RabbitMQ

# \- \*\*Containerization:\*\* Docker

# 

# 

# <div align="center">

# &nbsp; 

# </div>

