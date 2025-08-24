\# BookWorm\_RS2 



\*\*Seminarski rad iz predmeta Razvoj softvera 2\*\*   

📍 Fakultet informacijskih tehnologija, Mostar   



\## 📖 O projektu 



BookWorm je aplikacija kreirana za sve ljubitelje knjiga koji žele da podjele svoju strast prema čitanju! ✨   



Omogućava korisnicima da:   

\- 📚 kreiraju personalne biblioteke sa svojim knjigama  

\- 🤝 povezuju se sa prijateljima i drugim čitaocima   

\- 🏆 učestvuju u zabavnim izazovima i prate svoju statistiku čitanja   

\- 💡 dobijaju pametne preporuke za nove knjige i prijatelje   



\## 🚀 Upute za pokretanje 



\### Backend setup 



1\. Otvoriti `BookWorm` repozitorij 

2\. Nakon toga ponovno otvoriti folder `Bookworm`, te locirati arhivu \*\*fit-build-2025\_env.rar\*\*.  

3\. Iz te arhive uraditi extract `.env` file-a u isti folder (`BookWorm/BookWorm`) koristeći šifru: \*\*fit\*\* 

4\. U tom folderu (`BookWorm/BookWorm`) otvoriti terminal i pokrenuti: 

&nbsp;  ```bash 

&nbsp;  docker compose up --build 

&nbsp;  ``` 

&nbsp;  Sačekati da se sve uspješno build-a ⏳



\### Desktop aplikacija 



1\. \*\*Uključiti developer mode, ukoliko već nije aktiviran\*\* 

2\. \*\*Locirati `fit-build-2025-08-24.zip` arhivu u Bookworm folderu\*\* 

3\. \*\*Ekstraktovati arhivu - trebali biste dobiti `Release` i `flutter-apk` foldere\*\* 

4\. \*\*Otvoriti `Release` folder i pokrenuti `bookworm\_desktop.exe`\*\* 



\### Mobilna aplikacija 



1\. \*\*Otvoriti `flutter-apk` folder\*\* 

2\. \*\*Prenijeti `app-release.apk` file na emulator i sačekati instalaciju\*\* 

&nbsp;  > ⚠️ \*Deinstalirati prethodnu verziju aplikacije sa emulatora ukoliko postoji!\* 

3\. \*\*Prijaviti se koristeći kredencijale ispod\*\* 



\## 🔐 Kredencijali za prijavu 



\### 👑 Administrator 

\- \*\*Korisničko ime:\*\* `dekstop` 

\- \*\*Lozinka:\*\* `test` 



\### 👤 Korisnik 

\- \*\*Korisničko ime:\*\* `mobile` 

\- \*\*Lozinka:\*\* `test` 



\## 🔧 Mikroservis funkcionalnosti 



BookWorm koristi \*\*RabbitMQ\*\* mikroservis arhitekturu za automatsko slanje email obaveštenja! 📧 



Kada korisnik kreira knjigu, ona se postavlja u `submitted` stanje. Administrator zatim može odobriti knjigu, što je menja u `accepted` stanje - i upravo to je okidač za automatsko slanje email potvrde korisniku! 



\## 🛠️ Tehnologije 



\- \*\*Backend:\*\* ASP.NET Core 🔧

\- \*\*Frontend:\*\* Flutter (desktop i mobilna aplikacija) 🎯

\- \*\*Baza podataka:\*\* SQL Server 🗄️

\- \*\*Message Broker:\*\* RabbitMQ 🐰

\- \*\*Containerization:\*\* Docker 🐳

