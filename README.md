# \# BookWorm\_RS2

# 

# &nbsp;\*\*Seminarski rad iz predmeta Razvoj softvera 2\*\*  

# 📍 Fakultet informacijskih tehnologija, Mostar  



# \## 📖 O projektu

# 

# BookWorm je aplikacija za sve ljubitelje knjiga. ✨  

# Omogućava korisnicima da:  

# 

# \- 📖 kreiraju liste sa svojim knjigama 

# \- 👯‍♀️ povežu se sa prijateljima i knjiškim ubovima  

# \- 🎯 učestvuju u izazovima i prate statistiku čitanja  

# \- 🤝 dobijaju preporuke knjiga i novih prijatelja  

# 

# \## 🚀 Upute za pokretanje

# 

# \### Backend setup

# 

# 1\. Otvoriti `BookWorm` repozitorij

# 2\. Nakon toga ponovno otvoriti folder `Bookworm`, te locirati arhivu fit-build-2025\_env.rar4. 

# 3\. Iz te arhive uraditi extract `.env` file-a u isti folder (`BookWorm/BookWorm`) koristeći šifru: \*\*fit\*\*

# 4\. Poslije toga u tom folderu (`BookWorm/BookWorm`) otvoriti terminal i pokrenuti sljedeće:

# &nbsp;  ```bash

# &nbsp;  docker compose up --build

# &nbsp;  ```

# &nbsp;  Te sačekati da se sve uspješno build-a

# 

# \### Desktop aplikacija





# 1\. \*\*Uključiti developer ode, ukoliko već nije\*\*

# 2\. \*\*Vratiti se u Bookworm folder i locirati `fit-build-2025-08-24.zip` arhivu\*\*

# 2\. \*\*Iz te arhive uraditi extract, gdje biste trebali dobiti dva foldera: `Release` i `flutter-apk`\*\*

# 3\. \*\*Otvoriti `Release` folder i iz njega otvoriti `bookworm\_desktop.exe`\*\*









# \### Mobilna aplikacija





# 1\. \*\*Otvoriti `flutter-apk` folder\*\*

# 2\. \*\*File `app-release.apk` prenijeti na emulator i sačekati da se instalira\*\* \*(Deinstalirati aplikaciju sa emulatora ukoliko je prije bila instalirana!)\*

# 3\. \*\*Nakon instaliranja obje aplikacije, na iste se možete prijaviti koristeći kredencijale ispod\*\*

# 

# \## 🔐 Kredencijali za prijavu

# 

# \### Administrator

# \- \*\*Korisničko ime:\*\* `dekstop`

# \- \*\*Lozinka:\*\* `test`

# 

# \### Korisnik

# \- \*\*Korisničko ime:\*\* `mobile`

# \- \*\*Lozinka:\*\* `test`

# 

# \## 🔧 Mikroservis funkcionalnosti

# 

# BookWorm koristi \*\*RabbitMQ\*\* mikroservis za automatsko slanje email obaveštenja korisniku kada admin prihvati knjigu koju je on kreirao. Kada korisnik kreira knjigu, ona se nalazi u submitted stanju, te odobravanjem iz tog stanja prelazi u accepted, što je okidač za slanje maila.







# \## 🛠️ Tehnologije

# 

# \- \*\*Backend:\*\* ASP.NET Core

# \- \*\*Frontend:\*\* Flutter (desktop i mobilna aplikacija)

# \- \*\*Baza podataka:\*\* SQL Server

# \- \*\*Message Broker:\*\* RabbitMQ

# \- \*\*Containerization:\*\* Docker

# 

