program navale;  //Laetitia Monnier

uses crt;

CONST
	MAX = 5;

TYPE
	carreau = record // Carreau = case dans la consigne.
		ligne : integer;
		colonne : char;
		touche : boolean;
end;

TYPE
	bateau = record
		carreaux : array[1..MAX] of carreau;
		nbCarreaux : integer;
		coule : boolean;
end;

TYPE
	flotte = record
		bateaux : array[1..MAX] of bateau;
		nbBateaux : integer;
end;

procedure affichageFlotte(flo : flotte; attaque : boolean); // Cette procedure sert à afficher la flotte d'un joueur sur le plateau.
VAR
	i, j, x, y : integer;
begin
	FOR i := 1 TO flo.nbBateaux DO
	begin
		FOR j := 1 TO flo.bateaux[i].nbCarreaux DO
		begin
			IF attaque THEN // Si on affiche la flotte lors de la phase d'attaque alors...
			begin
				IF flo.bateaux[i].carreaux[j].touche THEN // ... on affiche uniquement les cases touchées...
				begin
					x := 5 + (ord(flo.bateaux[i].carreaux[j].colonne) - ord('A')) * 4; // Ce calcul permet de centrer le X dans chaque carré horizontalement.
					y := 1 + flo.bateaux[i].carreaux[j].ligne * 2; // Ce calcul permet de centrer le X dans chaque carré verticalement.
					gotoxy(x, y);
					write('X');
				end;
			end
			ELSE // ... sinon on affiche entièrement les bateaux.
			begin
				x := 5 + (ord(flo.bateaux[i].carreaux[j].colonne) - ord('A')) * 4; // Ce calcul permet de centrer le O dans chaque carré horizontalement.
				y := 1 + flo.bateaux[i].carreaux[j].ligne * 2; // Ce calcul permet de centrer le 0 dans chaque carré verticalement.
				gotoxy(x, y);
				write('O');
			end;
		end;
	end;
	gotoxy(1, 21);
end;

procedure affichagePlateau();// Cette procedure sert à afficher le plateau vide.
VAR
	i, j : integer;
begin
	write(' '); // Affichage des lettres en haut.
	FOR i := 0 TO 7 DO
		write('   ', char(ord('A') + i));
	writeln();

	write(' '); // Affichage du côté haut de la première ligne de cases.
	FOR i := 0 TO 7 DO
		write('   -');
	writeln();

	FOR i := 1 TO 8 DO
	begin
		write(i); // Affichage des chiffres sur le côté.

		FOR j := 1 TO 9 DO // Affichage des côtés gauche et droite des cases.
			write(' |  ');
		writeln();

		write(' '); // Affichage des côtés haut et bas des cases.
		FOR j := 0 TO 7 DO
			write('   -');
		writeln();
	end;
	writeln();
end;

function comparaison(car1, car2 : carreau):boolean; // Cette fonction sert à vérifier si deux cases sont identiques.
VAR
	resultat : boolean;
begin
	resultat := FALSE;
	IF (car1.ligne = car2.ligne) AND (car1.colonne = car2.colonne) THEN // Si les deux cases ont la même ligne et la même colonne alors...
		resultat := TRUE; // ... oui, les deux cases sont identiques.
	comparaison := resultat;
end;

function verificationBateau(cible : carreau; var bat : bateau; attaque : boolean):boolean; // Cette fonction sert à vérifier si la case ciblée est occupée par le bateau.
VAR
	resultat : boolean;
	compteur : integer;
begin
	resultat := FALSE;
	FOR compteur := 1 TO bat.nbCarreaux DO
	begin
		IF comparaison(cible, bat.carreaux[compteur]) THEN // Si la case ciblée est la même qu'une des cases du bateau alors...
		begin
			resultat := TRUE; // ... oui, la case ciblée est occupée.
			IF attaque THEN // Si la case est attaquée alors...
				bat.carreaux[compteur].touche := TRUE; // ... la case est touchée.
		end;
	end;
	verificationBateau := resultat;
end;

function verificationCoule(bat : bateau):boolean; // Cette fonction permet de vérifier si un bateau est coulé ou non.
VAR
	compteur : integer;
	resultat : boolean;
begin
	resultat := TRUE; // On part du principe que le bateau est coulé.
	FOR compteur := 1 TO bat.nbCarreaux DO
	begin
		IF bat.carreaux[compteur].touche = FALSE THEN // Si il y a au moins une case qui n'est pas touchée, alors le bateau n'est pas coulé.
			resultat := FALSE;
	end;
	verificationCoule := resultat;
end;

function verificationFlotte(cible : carreau; var flo : flotte; attaque : boolean):boolean; // Cette fonction sert à vérifier bateau par bateau si la case ciblée est occupée.
VAR
	resultat : boolean;
	compteur : integer;
begin
	resultat := FALSE;
	FOR compteur := 1 TO flo.nbBateaux DO
	begin
		IF verificationBateau(cible, flo.bateaux[compteur], attaque) THEN // Si la case ciblée est occupée par un des bateaux alors...
		begin
			resultat := TRUE; // ... oui, la case ciblée est occupée.
			IF attaque THEN // Si la case est attaquée (et par conséquent, que le bateau est touché) alors...
			begin
				flo.bateaux[compteur].coule := verificationCoule(flo.bateaux[compteur]); // ... on vérifie si le bateau est coulé.
				clrscr;
    			affichagePlateau();
				IF flo.bateaux[compteur].coule THEN
					write('Coulé !')
				ELSE
					write('Touché !');
				affichageFlotte(flo, TRUE);
			end;
		end;
	end;
	verificationFlotte := resultat;
end;

function verificationDefaite(flo : flotte):boolean; // Cette fonction permet de vérifier si un a joueur a perdu (tous ses bateaux sont coulés) ou non.
VAR
	compteur : integer;
	resultat : boolean;
begin
	resultat := TRUE; // On part du principe que le joueur a perdu.
	FOR compteur := 1 TO flo.nbBateaux DO
	begin
		IF flo.bateaux[compteur].coule = FALSE THEN // Si il y a au moins un bateau qui n'est pas coulé, alors le joueur n'a pas perdu.
			resultat := FALSE;
	end;
	verificationDefaite := resultat;
end;

function creationCase(ligne : integer; colonne : char):carreau; // Cette fonction sert à créer les cases d'un bateau.
VAR
	car : carreau;
begin
	car.ligne := ligne;
	car.colonne := colonne;
	car.touche := FALSE;
	creationCase := car;
end;

function creationBateau(nbcarreaux : integer; var flo : flotte):bateau; // Cette fonction sert à créer et placer un bateau.
VAR
	compteur, yDebut, yFin : integer;
	xDebut, xFin : char;
	bat : bateau;
begin
	writeln('Bateau taille ', nbcarreaux, ' : Rentrez la lettre de la première case');
	readln(xDebut);
	xDebut := upCase(xDebut);
	writeln('Bateau taille ', nbcarreaux, ' : Rentrez le chiffre de la première case');
	readln(yDebut);
	writeln('Bateau taille ', nbcarreaux, ' : Rentrez la lettre de la dernière case');
	readln(xFin);
	xFin := upCase(xFin);
	writeln('Bateau taille ', nbcarreaux, ' : Rentrez le chiffre de la dernière case');
	readln(yFin);
	IF (abs(ord(xDebut) - ord(xFin)) + 1 = nbcarreaux) OR (abs(yDebut - yFin) + 1 = nbcarreaux) THEN // Si la taille du bateau entré par le joueur correspond à la taille demandée...
	begin
		IF xDebut = xFin THEN // ... et que le bateau forme une colonne droite alors on crée le bateau.
		begin
			IF yDebut > yFin THEN // On fait en sorte que la valeur de yFin soit supérieure à yDebut pour toujours créer les cases de haut en bas.
			begin
				compteur := yDebut;
				yDebut := yFin;
				yFin := compteur;
			end;
			FOR compteur := 1 TO nbcarreaux DO
			begin
				bat.carreaux[compteur] := creationCase(yDebut + compteur - 1, xDebut); // On crée chaque case du bateau.
				IF verificationFlotte(bat.carreaux[compteur], flo, FALSE) THEN // Si la case créée est déjà occupée alors on recommence la création du bateau.
				begin
					writeln('Le bateau occupe une ou plusieurs cases déjà utilisées. Veuillez recommencer.');
					creationBateau := creationBateau(nbcarreaux, flo);
					exit;
				end;
			end;
			bat.nbCarreaux := nbcarreaux;
			bat.coule := FALSE;
			flo.nbBateaux := flo.nbBateaux + 1;
			creationBateau := bat;
		end
		ELSE IF yDebut = yFin THEN // ... et que le bateau forme une ligne droite alors on crée le bateau.
		begin
			IF xDebut > xFin THEN // On fait en sorte que la valeur de xFin soit supérieure à xDebut pour toujours créer les cases de gauche à droite.
			begin
				compteur := ord(xDebut);
				ord(xDebut) := ord(xFin);
				ord(xFin) := compteur;
			end;
			FOR compteur := 1 TO nbcarreaux DO
			begin
				bat.carreaux[compteur] := creationCase(yDebut, char(ord(xDebut) + compteur - 1)); // On crée chaque case du bateau.
				IF verificationFlotte(bat.carreaux[compteur], flo, FALSE) THEN  // Si la case créée est déjà occupée alors on recommence la création du bateau.
				begin
					writeln('Le bateau occupe une ou plusieurs cases déjà utilisées. Veuillez recommencer.');
					creationBateau := creationBateau(nbcarreaux, flo);
					exit;
				end;
			end;
			bat.nbCarreaux := nbcarreaux;
			bat.coule := FALSE;
			flo.nbBateaux := flo.nbBateaux + 1;
			creationBateau := bat;
		end
		ELSE
		begin
			writeln('Le bateau n''est pas droit. Veuillez recommencer.');
			creationBateau := creationBateau(nbcarreaux, flo);
		end;
	end
	ELSE
	begin
		writeln('Le bateau n''a pas la bonne taille. Veuillez recommencer.');
		creationBateau := creationBateau(nbcarreaux, flo);
	end;
end;

procedure creationFlotte(var flo : flotte; joueur1 : boolean); // Cette procedure sert a créer tous les bateaux d'une flotte.
begin
	clrscr;
	affichagePlateau();
	IF joueur1 THEN
		writeln('Joueur 1 : Placez vos bateaux')
	ELSE
		writeln('Joueur 2 : Placez vos bateaux');
	flo.nbBateaux := 0;
	flo.bateaux[1] := creationBateau(5, flo);
	clrscr;
    affichagePlateau();
	affichageFlotte(flo, FALSE);
	flo.bateaux[2] := creationBateau(4, flo);
	clrscr;
    affichagePlateau();
	affichageFlotte(flo, FALSE);
	flo.bateaux[3] := creationBateau(3, flo);
	clrscr;
    affichagePlateau();
	affichageFlotte(flo, FALSE);
	flo.bateaux[4] := creationBateau(3, flo);
	clrscr;
    affichagePlateau();
	affichageFlotte(flo, FALSE);
	flo.bateaux[5] := creationBateau(2, flo);
	clrscr;
    affichagePlateau();
	affichageFlotte(flo, FALSE);
end;

function tir(var flo : flotte):boolean; // Cette fonction sert à attaquer une case du joueur adverse.
VAR
	ligne : integer;
	colonne : char;
	cible : carreau;
begin
	writeln('Quelle est la lettre de la case que vous voulez attaquer ?');
	readln(colonne);
	colonne := upCase(colonne);
	writeln('Quelle est le chiffre de la case que vous voulez attaquer ?');
	readln(ligne);
	cible := creationCase(ligne, colonne);
	tir := verificationFlotte(cible, flo, TRUE);
end;

function tour(var flo : flotte; joueur1 : boolean):boolean; // Cette fonction permet à un joueur de jouer son tour de jeu.
begin
	clrscr;
    affichagePlateau();
    IF joueur1 THEN
    	write('Tour du joueur 1')
    ELSE
    	write('Tour du joueur 2');
	affichageFlotte(flo, TRUE);
	IF tir(flo) = FALSE THEN // Si le tir a raté...
	begin
		clrscr;
    	affichagePlateau();
    	write('Raté !');
    	affichageFlotte(flo, TRUE);
		tour := FALSE
    end
    ELSE // ... sinon si le tir a touché.
	begin
		IF verificationDefaite(flo) = FALSE THEN // Si le joueur adverse a encore des bateaux qui n'ont pas coulé alors la partie continue...
			tour := FALSE
		ELSE // ... sinon le joueur actuel gagne la partie.
		begin
			clrscr;
		    affichagePlateau();
		    IF joueur1 THEN
		    	write('Victoire du joueur 1 ! Félicitations !')
		    ELSE
		    	write('Victoire du joueur 2 ! Félicitations !');
    		affichageFlotte(flo, TRUE);
			tour := TRUE;
		end;
	end;
    readln;
end;

// --- Programme principal ---
VAR
	flotteJ1, flotteJ2 : flotte;
	fin : boolean;
BEGIN
	creationFlotte(flotteJ1, TRUE);
	readln;
	creationFlotte(flotteJ2, FALSE);
	readln;
	WHILE fin = FALSE DO
	begin
		fin := tour(flotteJ2, TRUE);
		IF fin = FALSE THEN
			fin := tour(flotteJ1, FALSE);
	end;
END.

