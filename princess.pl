/*Fakta*/
/*room adalah list ruangan yang statis*/
room([bedroom,castle,armory,dragon_treasury]).

/*inventory dan item adalah list dinamis, sedangkan location adalah fakta dinamis*/
:- dynamic((inventory/1), (item/2), (location/1), (sharp/1)).
	
/*Rules*/
loop_entry :-
	repeat, nl, write('> '), read(X), do(X), (X = quit).
	
/*do mengeksekusi fungsi X*/
do(look) :- !, look.
do(sleeping) :- sleeping, !.
do(readmap) :- readmap, !.
do(goto(Y)) :- !, goto(Y).
do(take(Y)) :- take(Y), !.
do(sharpen(Y)) :- sharpen(Y), !.
do(quit) :- quit, !.
do(_) :- write('Command salah, ulangi!!!'), nl, !.

/*start menampilkan header permainan Tio Knight in Shining Armor*/
start :- 
	write('Welcome to Tio''s World where everything is made up and nothing holds an importance!'), nl,
	write('Your job is to find Princess for Tio the Knight in Shining Armor by exploring this nonsense world!'), nl,
	write('You can explore by using command:'), nl,
	write('- look\n- sleeping\n- readmap\n- goto(place)\n- take(object)\n- sharpen(object)\n- quit.\n'),
	asserta(item(bedroom,[bed])), asserta(item(castle,[armor, shield, maps])), asserta(item(armory,[desk,sword])),
	asserta(item(dragon_treasury,[princess])), asserta(location(castle)),
	loop_entry, !.
	
	
/*writelist(Y) menulis list*/
writelist([]) :-  !.
writelist([Y|Z]) :- write(Y), write(' '), writelist(Z).

/*writeall menampilkan seluruh elemen suatu rule*/
writeall(Z) :- inventory(Z), write(Z), write(' '), fail.
writeall(Z) :- nl.

/*look menampilkan ruangan, item di ruangan dan inventory*/
look :- 
	location(X), write('You are in '), write(X), nl,
	tab(2), write('You can see: '), item(X,Y), writelist(Y), nl,
	tab(2), write('Your inventory: '), writeall(Z).

/*sleeping membuat Satria beristirahat, hanya bisa di bedroom*/
sleeping :-
	location(X), (X = bedroom) -> write('Have a good night O Tio, Knight in Shining Armor'), nl;
	write('You are not in bedroom'), nl.
	
/*writeroom menampilkan list room*/
writeroom([]) :- !.
writeroom([Y|Z]) :- write(Y), write(' | '), writeroom(Z).

/*readmap menampilkan denah hanya jika Satria punya maps*/
readmap :-
	inventory(Z), (Z = maps) -> write('You open the wonderful map and see what''s inside'), nl, room(Y), writeroom(Y), nl;
	write('You can''t read map because you don''t have it'), nl.
	
/*nextto mendeklarasikan apakah benar elemen X dan Y bersebelahan dalam list*/
nextto(X, Y, [X,Y|_]).
nextto(Y, X, [X,Y|_]).
nextto(X,Y,[_|Z]) :- nextto(X, Y, Z).

/*goto memindahkan posisi Satria dari ruangan yang bersebelahan dengan posisi awal satria*/
goto(Y) :-
	(location(X), nextto(X, Y, [bedroom, castle, armory, dragon_treasury])) -> 
		(Y = dragon_treasury ->
			(inventory(Z), inventory(W), (Z = shield), (W = armor), sharp(A), (A = yes) ->
				retract(location(X)), asserta(location(Y)), look; 
				write('The Dragon Treasury is being Guarded by Fat Dragon Tiyoks, you have to take armor, shield, and sharpen your sword first')),nl;
			retract(location(X)), asserta(location(Y)), look);  
		write('You can''t get there from here'), nl.

/*delete_one menghapus suatu elemen list*/
delete_one(X, [], []).
delete_one(X, [X|Y], Z) :- delete_one(X, Y, Z).
delete_one(X, [Y|Z], W) :- (X \== Y), delete_one(X, Z, U), append([Y], U, W).
					
/*take mengambil barang yang ada dalam item ruangan dan menyimpannya dalam inventory*/
take(X) :-
	location(Y), item(Y,Z), member(X, Z) ->
		((X = princess) ->
			write('Congratulation Tio has found his true love'), nl;
			asserta(inventory(X)), delete_one(X, Z, W), retractall(item(Y,_)), assertz(item(Y, W))), !;
	write('There is no '), write(X), write(' in this room'), nl. 
		
/*sharpen menajamkan sword yang sudah menjadi inventory*/
sharpen(X) :-
	inventory(Z), (X = sword), (Z = sword) -> asserta(sharp(yes)), !;
	write('You can''t sharpen it'), nl.

/*quit keluar dari permainan*/
quit.
