# Webes robot indítási útmutató

Ez az útmutató segít a PLG-00-main.robot webes felületről történő indításához.

## 1. Előkészületek
- Győződj meg róla, hogy a Python telepítve van a gépen.
- Telepítsd a Flask csomagot:

    pip install flask

- A következő fájloknak létezniük kell a projektedben:
    - `web/robot_runner.html` (a webes felület)
    - `web_server.py` (a Flask szerver)
    - `PLG-00-main.robot` (a futtatandó Robot Framework script)

## 2. Szerver indítása
A projekt gyökerében futtasd a következő parancsot:

    python web_server.py

Ez elindítja a Flask szervert a 5000-es porton.

## 3. Webes felület használata
- Nyisd meg a böngészőben:

    http://localhost:5000

- A felületen két gomb található:
    - **Run**: Elindítja a PLG-00-main.robot futtatását (log, riport és output nélkül).
    - **Kilépés**: Bezárja a böngésző ablakot.
- A futás eredménye a nagy szövegmezőben (textarea) jelenik meg.

## 4. Hibák, naplózás
- A robot futása nem generál log, report vagy output XML fájlt.
- A futás eredménye és esetleges hibák a webes felületen jelennek meg.

## 5. Leállítás
- A szervert a terminálban `Ctrl+C`-vel tudod leállítani.

---

Ha bármilyen kérdésed van, jelezd!
