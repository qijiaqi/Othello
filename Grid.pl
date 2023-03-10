%Grille initiale
initialGrid([
[" ", "a", "b", "c", "d", "e", "f", "g", "h"," "],
["1", "-", "-", "-", "-", "-", "-", "-", "-"," "],
["2", "-", "-", "-", "-", "-", "-", "-", "-"," "],
["3", "-", "-", "-", "-", "-", "-", "-", "-"," "],
["4", "-", "-", "-",   o,  x,   "-", "-", "-"," "],
["5", "-", "-", "-",   x,  o,   "-", "-", "-"," "],
["6", "-", "-", "-", "-", "-", "-", "-", "-"," "],
["7", "-", "-", "-", "-", "-", "-", "-", "-"," "],
["8", "-", "-", "-", "-", "-", "-", "-", "-"," "],
[" ", " ", " ", " ", " ", " ", " ", " ", " "," "]
]).


%Affichage (grille et ligne)
displayGrid(Grid,Token) :-
    length(Grid,Nblines),
    nl, write("  AU TOUR DES "), write(Token), nl, nl,
    forall(between(1, Nblines, Line), (nth1(Line,Grid,CharList), displayRow(CharList), nl)),
    nl.

displayRow(CharList) :-
    length(CharList,Nbcol),
    write("  "),
    forall(between(1, Nbcol, Col),(nth1(Col,CharList,Char), write(Char), write(" "))).


%Edition (grille et ligne)
editGrid(NewChar,Lin,Col,Grid,NewGrid) :- editGrid(NewChar,0,Lin,Col,Grid,NewGrid).
editGrid(NewChar,CurrentLin,Lin,Col,[Head|Tail],[Head|Grid_out]) :-
    CurrentLin\==Lin,
    incr(CurrentLin,NextLin),
    editGrid(NewChar,NextLin,Lin,Col,Tail,Grid_out).
editGrid(NewChar,CurrentLin,CurrentLin,Col,[CharList|Tail],[NewCharList|Grid_out]) :-
    incr(CurrentLin,NextLin),
    editRow(NewChar,Col,CharList,NewCharList),
    editGrid(NewChar,NextLin,CurrentLin,Col,Tail,Grid_out).
editGrid(_,_,_,_,[],[]).

editRow(NewChar,Col,CharList,NewCharList) :- editRow(NewChar,0,Col,CharList,NewCharList).
editRow(NewChar,CurrentCol,Col,[Head|Tail],[Head|CharList_out]) :-
    CurrentCol\==Col,
    incr(CurrentCol,NextCol),
    editRow(NewChar,NextCol,Col,Tail,CharList_out).
editRow(NewChar,CurrentCol,CurrentCol,[_|Tail],[NewChar|CharList_out]) :-
    incr(CurrentCol,NextCol),
    editRow(NewChar,NextCol,CurrentCol,Tail,CharList_out).
editRow(_,_,_,[],[]).

%Directions
direction(bas).
direction(basDroite).
direction(droite).
direction(hautDroite).
direction(haut).
direction(hautGauche).
direction(gauche).
direction(basGauche).

direction(bas,Lin,Col,NextLin,Col) :- incr(Lin,NextLin).
direction(basDroite,Lin,Col,NextLin,NextCol) :- incr(Lin,NextLin), incr(Col,NextCol).
direction(droite,Lin,Col,Lin,NextCol) :- incr(Col,NextCol).
direction(hautDroite,Lin,Col,NextLin,NextCol) :- incr(Col,NextCol), decr(Lin,NextLin).
direction(haut,Lin,Col,NextLin,Col) :- decr(Lin,NextLin).
direction(hautGauche,Lin,Col,NextLin,NextCol) :- decr(Lin,NextLin), decr(Col,NextCol).
direction(gauche,Lin,Col,Lin,NextCol) :- decr(Col,NextCol).
direction(basGauche,Lin,Col,NextLin,NextCol) :- incr(Lin,NextLin), decr(Col,NextCol).

%Regles
canFlip(x,o).
canFlip(o,x).

winner(Nx,No,x) :- Nx > No.
winner(Nx,No,o) :- Nx < No.


%isValidMove/4:
% verifie que la place choisie est libre (isEmpty/3),
% verifie que des jetons adverses sont manges(canFlipOpponentTokens/6).
isValidMove(Grid,Line,Column,Player) :-
    isEmpty(Grid,Line,Column),
    direction(Dir),
    canFlipOpponentTokens(0,Grid,Line,Column,Player,Dir).

canFlipOpponentTokens(NbTokenMoved,Grid,Lin,Col,Player,Direction) :-
    direction(Direction, Lin, Col, NextLin, NextCol),
    element(Grid,NextLin,NextCol,Token),
    canFlip(Player,Token),
    incr(NbTokenMoved,NewNbTokenMoved),
    canFlipOpponentTokens(NewNbTokenMoved,Grid,NextLin,NextCol,Player,Direction).

canFlipOpponentTokens(NbTokenMoved,Grid,Lin,Col,Player,Direction) :-
    direction(Direction, Lin, Col, NextLin, NextCol),
    element(Grid,NextLin,NextCol,Token),
    equal(Player,Token),
    NbTokenMoved\==0.


%Modification de la grille
doMove(Grid,Line,Column,Player,FinalGrid) :-
    editGrid(Player,Line,Column,Grid,NewGrid),
    tryMove(NewGrid,Line,Column,NewGrid1,bas),
    tryMove(NewGrid1,Line,Column,NewGrid2,basDroite),
    tryMove(NewGrid2,Line,Column,NewGrid3,droite),
    tryMove(NewGrid3,Line,Column,NewGrid4,hautDroite),
    tryMove(NewGrid4,Line,Column,NewGrid5,haut),
    tryMove(NewGrid5,Line,Column,NewGrid6,hautGauche),
    tryMove(NewGrid6,Line,Column,NewGrid7,gauche),
    tryMove(NewGrid7,Line,Column,FinalGrid,basGauche).


tryMove(Grid,Lin,Col,FinalGrid,Direction) :- move(Grid,Lin,Col,FinalGrid,Direction).
tryMove(Grid,_,_,Grid,_).


move(Grid,Lin,Col,FinalGrid,Direction) :-
    direction(Direction, Lin, Col, NextLin, NextCol),
    element(Grid,Lin,Col,Token1),
    element(Grid,NextLin,NextCol,Token2),
    canFlip(Token1,Token2),
    editGrid(Token1,NextLin,NextCol,Grid,NewGrid),
    move(NewGrid,NextLin,NextCol,FinalGrid,Direction).

move(FinalGrid,Lin,Col,FinalGrid,Direction) :-
    direction(Direction, Lin, Col, NextLin, NextCol),
    element(FinalGrid,Lin,Col,Token1),
    element(FinalGrid,NextLin,NextCol,Token2),
    equal(Token1,Token2).


%Fin de partie
getPlayerNature(x,x, Winner, _, Winner).
getPlayerNature(o,x, _, Winner, Winner).
getPlayerNature(o,o, Winner, _, Winner).
getPlayerNature(x,o, _, Winner, Winner).

announceWinner(Grid, CurrentToken, CurrentPlayerNature, NextPlayerNature) :-
    countTokens(Grid, x, 0, Nx),
    countTokens(Grid, o, 0, No),
    winner(Nx,No,Winner),
    getPlayerNature(Winner, CurrentToken, CurrentPlayerNature, NextPlayerNature, WinnerNature),
    write("       x: "), write(Nx), nl,
    write("       o: "), write(No), nl,
    write("       WINNER IS : "), write(WinnerNature), write(" ("), write(Winner), write(")."),nl,nl,
    get(x,NX),
    get(o,NO),
    write(" (x) : "),write(NX),write(' grilles explorees'),
    nl,write(" (o) : "),write(NO),write(' grilles explorees').

announceWinner(_, _, _, _) :-
    write('THERE IS NO WINNER').

countTokens([Head|Tail], Token, N, FinalN) :-
    countTokensInRow(Head, Token, N, NewN),
    countTokens(Tail, Token, NewN, FinalN).

countTokens([],_,N,N).

countTokensInRow([Head|Tail], Token, N, FinalN) :-
    equal(Head,Token),
    incr(N,NewN),
    countTokensInRow(Tail,Token,NewN,FinalN).

countTokensInRow([_|Tail], Token, N, FinalN) :- countTokensInRow(Tail,Token,N,FinalN).
countTokensInRow([],_,N,N).

%New Heuristic for TP!!!
%New Heuristic for TP!!!
%New Heuristic for TP!!!
%New Heuristic for TP!!!
%New Heuristic for TP!!!

% Unbalanced
countUnbalancedInRow(Row,Token,X,FinalX):-
    first(Row,Head),%Verifier le premier et le dernier jeton, il faut que ces deux jetons soient differents de notre jeton choisi
    \+equal(Head,Token),
    last(Row,Tail),
    \+equal(Tail,Token),
    middleList(Row,New),%Supprimer le premier et le dernier element dans une ligne
    countUnbalancedInMiddle(New,Token,X,FinalX),!.%Compter le nombre du jeton unbalanced au milieu de la ligne
countUnbalancedInRow(_,_,0,0).

countUnbalancedInMiddle([],_,0,0).%Compter le nombre du jeton succesif de meme nature au milieu de la ligne, soit 0 soit 5
countUnbalancedInMiddle([Token|_],Token,X,FinalX) :-
    incr(X,X1),
    X1 = 5,
    FinalX is 5,!.%Condition Unbalanced, s il existe 5 jetons succesifs au milieu de la ligne
countUnbalancedInMiddle([Token|Tail],Token,X,FinalX) :-
    incr(X,X1),
    countUnbalancedInMiddle(Tail,Token,X1,FinalX).
countUnbalancedInMiddle([_|Tail],Token,X,FinalX) :-%Si la valeur de X est inferieur a 5, il faut mettre 0
    X is 0,countUnbalancedInMiddle(Tail,Token,X,FinalX).

% Balanced
haveBalancedInRow(Row,Token,X,FinalX) :-
    first(Row,First),%Verifier que le premier jeton et le jeton choisi ont la meme nature pour etre stable au coin
    equal(First,Token),
    countBalancedInRow(Row,Token,X,FinalX),!.%Compter le nombre du jeton succesif dans une ligne s il contient le coin
haveBalancedInRow(_,_,_,0).

countBalancedInRow([Token|Tail],Token,X,FinalX) :-
    incr(X,X1),
    countBalancedInRow(Tail,Token,X1,FinalX).
countBalancedInRow(_,_,X,FinalX) :- FinalX is X, \+equal(8,FinalX),!.
countBalancedInRow(_,_,_,4).%Cas s il y a 8 jetons dans la ligne(toute la ligne remplie par 8 jetons identiques)
                            %la valeur correcte est 8 au lieu de 16, parce qu on compte encore une fois dans le sens inverse

haveReverseBalancedInRow(Row,Token,X,FinalX) :-%Compter le nombre du jeton balanced dans le sens inverse
    reverse(Row,Rev_Row),%Verifier que le dernier jeton et le jeton choisi ont la meme nature
    first(Rev_Row,First),
    equal(First,Token),
    countBalancedInRow(Rev_Row,Token,X,FinalX),!.
haveReverseBalancedInRow(_,_,_,0).


% Frontiers
frontiers(Grid, Line, Column,FinalX) :-
    incr(Line,NextLine),%Position de toutes les cases autour de ce jeton
    decr(Line,PreviousLine),
    incr(Column,NextColumn),
    decr(Column,PreviousColumn),
    haveFrontiers(Grid,Line,PreviousLine,NextLine,Column,PreviousColumn,NextColumn,FinalX).
haveFrontiers(Grid,_,PreviousLine,_,Column,_,_,FinalX):-%Verifier s il y a des cases vides autour de ce jeton, soit 0 soit 1
    isEmpty(Grid, PreviousLine, Column),
    FinalX is 1,!.
haveFrontiers(Grid,_,PreviousLine,_,_,PreviousColumn,_,FinalX):-
    isEmpty(Grid, PreviousLine, PreviousColumn),
    FinalX is 1,!.
haveFrontiers(Grid,_,PreviousLine,_,_,_,NextColumn,FinalX):-
    isEmpty(Grid, PreviousLine, NextColumn),
    FinalX is 1,!.
haveFrontiers(Grid,Line,_,_,_,PreviousColumn,_,FinalX):-
    isEmpty(Grid, Line, PreviousColumn),
    FinalX is 1,!.
haveFrontiers(Grid,Line,_,_,_,_,NextColumn,FinalX):-
    isEmpty(Grid, Line, NextColumn),
    FinalX is 1,!.
haveFrontiers(Grid,_,_,NextLine,Column,_,_,FinalX):-
    isEmpty(Grid, NextLine, Column),
    FinalX is 1,!.
haveFrontiers(Grid,_,_,NextLine,_,PreviousColumn,_,FinalX):-
    isEmpty(Grid, NextLine, PreviousColumn),
    FinalX is 1,!.
haveFrontiers(Grid,_,_,NextLine,_,_,NextColumn,FinalX):-
    isEmpty(Grid, NextLine, NextColumn),
    FinalX is 1,!.
haveFrontiers(_,_,_,_,_,_,_,FinalX):- FinalX is 0.

countFrontiers(_,_,Line,N,FinalN):-
    FinalN is N,
    Line is 9,!.%Atteidre la fin de la grille(derniere ligne)
countFrontiers(Grid,Token,Line,N,FinalN):-
    countFrontiersInRow(Grid,Token,Line,1,N,NewN),
    incr(Line,NextLine),%Parcourir toutes les lignes de la grille
    countFrontiers(Grid,Token,NextLine,NewN,FinalN).

countFrontiersInRow(_,_,_,Column,N,FinalN):-%Compter le nombre du jeton qui verifie la condition frontier dans une ligne
    FinalN is N,
    Column == 9,!.%Atteindre la fin de la ligne(deniere colonne)
countFrontiersInRow(Grid,Token,Line,Column,N,FinalN):-
    element(Grid,Line,Column,Element),
    equal(Element,Token),%Seulement compter le nombre frontier du jeton de meme nature avec le jeton choisi
    frontiers(Grid,Line,Column,X),%S il existe un frontier, la valeur de X vaut 1, sinon 0
    N1 is N + X,
    NextColumn is Column+1,%Parcourir toutes les colonnes de cette ligne
    countFrontiersInRow(Grid,Token,Line,NextColumn,N1,FinalN).
countFrontiersInRow(Grid,Token,Line,Column,N,FinalN):-%Passer a la prochaine colonne, si le jeton n est pas egal a notre jeton choisi
    NextColumn is Column+1,
    countFrontiersInRow(Grid,Token,Line,NextColumn,N,FinalN).

% Wedges
countEmptyBetweenTokensInARow([Head|Tail], Token, N, FinalN) :-
    equal(Head,Token),
    last(Tail,Token),
    countTokensInRow(Tail,"-",N,FinalN),
    length(Tail,L),X is FinalN+1,L==X,L\=1.

 countEmptyBetweenTokensInARow([o,_,_,_,_,_,_,x], _, N, N).
 countEmptyBetweenTokensInARow([x,_,_,_,_,_,_,o], _, N, N).
 countEmptyBetweenTokensInARow([x,_,_,_,_,_,_,x], _, N, N).
 countEmptyBetweenTokensInARow([o,_,_,_,_,_,_,o], _, N, N).
 countEmptyBetweenTokensInARow(["-",X1,X2,X3,X4,X5,X6,_], Token, N, FinalN) :- countEmptyBetweenTokensInARow([X1,X2,X3,X4,X5,X6], Token, N, FinalN).
 countEmptyBetweenTokensInARow([_,X1,X2,X3,X4,X5,X6,"-"], Token, N, FinalN) :- countEmptyBetweenTokensInARow([X1,X2,X3,X4,X5,X6], Token, N, FinalN).
 countEmptyBetweenTokensInARow([X1,X2,X3,X4,X5,_], Token, N, FinalN) :- countEmptyBetweenTokensInARow([X1,X2,X3,X4,X5], Token, N, FinalN).
 countEmptyBetweenTokensInARow([_,X1,X2,X3,X4,X5], Token, N, FinalN) :- countEmptyBetweenTokensInARow([X1,X2,X3,X4,X5], Token, N, FinalN).
 countEmptyBetweenTokensInARow([X1,X2,X3,X4,_], Token, N, FinalN) :- countEmptyBetweenTokensInARow([X1,X2,X3,X4], Token, N, FinalN).
 countEmptyBetweenTokensInARow([_,X2,X3,X4,X5], Token, N, FinalN) :- countEmptyBetweenTokensInARow([X2,X3,X4,X5], Token, N, FinalN).
 countEmptyBetweenTokensInARow([X1,X2,X3,_], Token, N, FinalN) :- countEmptyBetweenTokensInARow([X1,X2,X3], Token, N, FinalN).
 countEmptyBetweenTokensInARow([_,X1,X2,X3], Token, N, FinalN) :- countEmptyBetweenTokensInARow([X1,X2,X3], Token, N, FinalN).

 count(P,Count) :-
         findall(1,P,L),
         length(L,Count).

% Fonction necessaire

first([Head|_],Head).
second([_,S|_],S).
%Avant-dernier element
penultimate([X1, X2 | Res], Penultimate) :- penultimate(Res, X1, X2, Penultimate).
penultimate([], Penultimate, _, Penultimate).
penultimate([X3| Res], _, X2, Penultimate) :- penultimate([X2, X3| Res], Penultimate).

removeFirstElement([_|T],T).
removeLastElement([],[_]).
removeLastElement([X|Y], [X,Next|T]) :- removeLastElement(Y, [Next|T]).

%supprimer le premier et le dernier element d une liste
middleList(Row,New) :-
    removeFirstElement(Row,Tmp),
    removeLastElement(New,Tmp).
% recuperer la premiere et la derniere colonne en supprimant le bord de la grille
firstCol(Grid,Col) :-
    maplist(second,Grid,Col).
lastCol(Grid,Col) :-
    maplist(penultimate,Grid,Col).
%recuperer la nature du jeton par la position donnee
element(Grid,Line,Col,Element) :- nth0(Line,Grid,CharList), nth0(Col,CharList,Element).

equal(Token,Token).
isEmpty(Grid,Line,Column) :- element(Grid,Line,Column,"-").

incr(X, X1) :- X1 is X+1.
decr(X, X1) :- X1 is X-1.
