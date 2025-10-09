# IKK-Robotok

klónozás:

PS C:\Users\oLovasz> cd .\MyRobotFramework\

PS C:\Users\oLovasz\MyRobotFramework> cd .\DownloadedRobots\

PS C:\Users\oLovasz\MyRobotFramework\DownloadedRobots> cd '.\IKK_Innovatív Képzéstámogató Központ'                                 

PS C:\Users\oLovasz\MyRobotFramework\DownloadedRobots\IKK_Innovatív Képzéstámogató Központ\IKK02_Formai-Ellenorzesek> git clone --branch IKK02_Formai-Ellenorzesek https://github.com/oLovasz/IKK-Robotok
 IKK02_Formai-Ellenorzesek

Ha tényleg a saját gépedre akarsz írni

Ehhez self-hosted runner kell.

Hogyan működik:

Telepítesz egy GitHub Actions “agentet” a saját gépedre.

Ez lesz a futtatókörnyezet (nem a GitHub felhője).

A YAML workflow-t ekkor a te géped hajtja végre, így tud fájlokat írni/olvasni a lokális rendszeredből.

👉 Telepítés útmutató:

https://docs.github.com/en/actions/hosting-your-own-runners

Telepítés után beállítod a workflow-ban:

runs-on: self-hosted


Ezután a pipeline a saját Windows gépeden fut, és bármit írhat, mozgathat, elindíthat.
