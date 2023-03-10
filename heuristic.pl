isWinner(Nb1,Nb2,100) :- Nb1 > Nb2.
isWinner(_,_,-100).
heuristic(Heur,Grid,Token,Eval) :-
    get(Token,N1),
    N2 is N1+1, %nombre de grille exploree incremente
    set(Token,N2),
    h(Heur,Grid,Token,Eval).

h(endGame,Grid,Token,Eval) :-
    next(Token,Opponent),
    countTokens(Grid, Token, 0, Nb1),
    countTokens(Grid, Opponent, 0, Nb2),
    isWinner(Nb1,Nb2,Eval).

h(global,Grid,Token,Eval) :-
    h(countTokens,Grid,Token,Eval1),
    h(countMoves,Grid,Token,Eval2),
    h(countCorners,Grid,Token,Eval3),
    h(stability,Grid,Token,Eval4),
    Eval is Eval1*4 + Eval2*2 + Eval3*20 + Eval4*3.

h(balanced,Grid,Token,Eval) :-
   %h(countTokens,Grid,Token,Eval1),
   h(countBalanced,Grid,Token,Eval2),
   Eval is Eval2.% + Eval1.

h(unbalanced,Grid,Token,Eval) :-
   %h(countTokens,Grid,Token,Eval1),
   h(countUnbalanced,Grid,Token,Eval2),
   Eval is 5 - Eval2/4.%+ Eval1.

h(countTokens,Grid,Token,Eval) :-
    countTokens(Grid, Token, 0, NbTokensCurrentPlayer),
    nextPlayer(Token,Opponent),
    countTokens(Grid, Opponent, 0, NbTokensOpponent),
    Eval is NbTokensCurrentPlayer-NbTokensOpponent.

h(countMoves,Grid,Token,Eval) :-
    allPossibleMoves(Token, Grid, AllMovesMax),
    length(AllMovesMax, Nb_MaxMoves),
    nextPlayer(Token,Opponent),
    allPossibleMoves(Opponent, Grid, AllMovesMin), length(AllMovesMin, Nb_MinMoves),
    Eval is Nb_MaxMoves - Nb_MinMoves.

h(countCorners,Grid,Token,Eval) :-
        getCorners(Grid,ListCorners),
        %listeCorners est une liste de 4 elements dans laquelle est stockee
        %la valeur de chaque coin
        countTokensInRow(ListCorners,Token,0, Nb_CornersMax),
        nextPlayer(Token,Opponent),
        countTokensInRow(ListCorners,Opponent,0, Nb_CornersMin),
        Eval is Nb_CornersMax - Nb_CornersMin.

h(stability,Grid,Token,Eval):-
                   gridToLine(Grid, AsLine),
                   stability_weights(Stability_line),
                   nextPlayer(Token,Opponent),
                   stabilityHeuristic(AsLine,Stability_line,Token,Opponent,Res_PlayerMax,Res_PlayerMin),
                   Eval is Res_PlayerMax - Res_PlayerMin.

h(wedges,Grid,Token,Eval) :-
        h(countWedges,Grid,Token,Eval1),
        h(countCorners,Grid,Token,Eval2),
        Eval is Eval1*10 + Eval2*0.

%New Heuristic for TP!!!
%New Heuristic for TP!!!
%New Heuristic for TP!!!
%New Heuristic for TP!!!
%New Heuristic for TP!!!

h(countFrontiers,Grid,Token,Eval):-
    countFrontiers(Grid,Token,1,0,NbFrontiersPlayer),
    nextPlayer(Token,Opponent),
    countFrontiers(Grid,Opponent,1,0,NbFrontiersOpponent),
    Eval is NbFrontiersOpponent - NbFrontiersPlayer.


h(countWedges,Grid,Token,Eval):-
    second(Grid,First),%premiere ligne
    penultimate(Grid,Last),%derniere ligne
    firstCol(Grid,FirstCol),%premiere colonne
    lastCol(Grid,LastCol),%derniere colonne
    middleList(First,MiddleFirst),%supprimer le bord de la grille
    middleList(Last,MiddleLast),
    middleList(FirstCol,MiddleFirstCol),
    middleList(LastCol,MiddleLastCol),
    count(countEmptyBetweenTokensInARow(MiddleFirst,Token,0,Nb_EmptyInBetweenFirst),Op_Wedge_First),
    count(countEmptyBetweenTokensInARow(MiddleLast,Token,0,Nb_EmptyInBetweenLast),Op_Wedge_Last),
    count(countEmptyBetweenTokensInARow(MiddleFirstCol,Token,0,Nb_EmptyInBetweenFirst),Op_Wedge_FirstCol),
    count(countEmptyBetweenTokensInARow(MiddleLastCol,Token,0,Nb_EmptyInBetweenFirst),Op_Wedge_LastCol),
    Nb_wedges_Opponent = Op_Wedge_First + Op_Wedge_Last + Op_Wedge_FirstCol + Op_Wedge_LastCol,
    nextPlayer(Token,Opponent),
    count(countEmptyBetweenTokensInARow(First,Opponent,0,Nb_EmptyInBetweenFirst),Wedge_First),
    count(countEmptyBetweenTokensInARow(Last,Opponent,0,Nb_EmptyInBetweenLast),Wedge_Last),
    count(countEmptyBetweenTokensInARow(FirstCol,Opponent,0,Nb_EmptyInBetweenFirst),Wedge_FirstCol),
    count(countEmptyBetweenTokensInARow(LastCol,Opponent,0,Nb_EmptyInBetweenFirst),Wedge_LastCol),
    Nb_wedges_CurrentPlayer = Wedge_First + Wedge_Last + Wedge_FirstCol + Wedge_LastCol,
    Eval is Nb_wedges_CurrentPlayer - Nb_wedges_Opponent.

h(countUnbalanced,Grid,Token,Eval):-
    second(Grid,Second),%premiere ligne
    penultimate(Grid,Penul),%derniere ligne
    firstCol(Grid,FirstCol),%premiere colonne
    lastCol(Grid,LastCol),%derniere colonne
    middleList(Second,MiddleFirst),%supprimer le bord de la grille
    middleList(Penul,MiddleLast),
    middleList(FirstCol,MiddleFirstCol),
    middleList(LastCol,MiddleLastCol),
    countUnbalancedInRow(MiddleFirst,Token,0,Nb_unbalancedFirstRow),
    countUnbalancedInRow(MiddleLast,Token,0,Nb_unbalancedLastRow),
    countUnbalancedInRow(MiddleFirstCol,Token,0,Nb_unbalancedFirstCol),
    countUnbalancedInRow(MiddleLastCol,Token,0,Nb_unbalancedLastCol),
    Eval is Nb_unbalancedFirstRow + Nb_unbalancedLastRow + Nb_unbalancedFirstCol + Nb_unbalancedLastCol.

h(countBalanced,Grid,Token,Eval):-
    second(Grid,Second),%premiere ligne
    penultimate(Grid,Penul),%derniere ligne
    firstCol(Grid,FirstCol),%premiere colonne
    lastCol(Grid,LastCol),%derniere colonne
    middleList(Second,MiddleFirst),%supprimer le bord de la grille
    middleList(Penul,MiddleLast),
    middleList(FirstCol,MiddleFirstCol),
    middleList(LastCol,MiddleLastCol),
    haveBalancedInRow(MiddleFirst,Token,0,A),
    haveReverseBalancedInRow(MiddleFirst,Token,0,B),
    haveBalancedInRow(MiddleLast,Token,0,C),
    haveReverseBalancedInRow(MiddleLast,Token,0,D),
    haveBalancedInRow(MiddleFirstCol,Token,0,E),
    haveReverseBalancedInRow(MiddleFirstCol,Token,0,F),
    haveBalancedInRow(MiddleLastCol,Token,0,G),
    haveReverseBalancedInRow(MiddleLastCol,Token,0,H),
    Eval is A + B + C + D + E + F + G + H.

%Recuperation des valeurs des coins
getCorners(Grid,[C1,C2,C3,C4]):-
        element(Grid,1,1,C1),
        element(Grid,8,1,C2),
        element(Grid,1,8,C3),
        element(Grid,8,8,C4).

stability_weights([0,  0,   0,  0,  0,  0,  0,  0,  0, 0,
                   0,  4,  -3,  2,  2,  2,  2, -3,  4, 0,
                   0, -3,  -4, -1, -1, -1, -1, -4, -3, 0,
                   0,  2,  -1,  1,  0,  0,  1, -1,  2, 0,
                   0,  2,  -1,  0,  1,  1,  0, -1,  2, 0,
                   0,  2,  -1,  0,  1,  1,  0, -1,  2, 0,
                   0,  2,  -1,  1,  0,  0,  1, -1,  2, 0,
                   0, -3,  -4, -1, -1, -1, -1, -4, -3, 0,
                   0,  4,  -3,  2,  2,  2,  2, -3,  4, 0,
                   0,  0,   0,  0,  0,  0,  0,  0,  0, 0]).%Les 0 sur les cots correspondent au bord de la grille sur lequel on ne peut pas poser de jeton.

stabilityHeuristic([], [],_,_, 0, 0).

stabilityHeuristic([Head_grid|Tail_grid], [Head_weights|Tail_weights], Head_grid, MinPlayer, Res_PlayerMax, Res_PlayerMin) :-
                   stabilityHeuristic(Tail_grid, Tail_weights,Head_grid, MinPlayer, Tmp_ResPlayerMax, Res_PlayerMin),!,
                   Res_PlayerMax is Tmp_ResPlayerMax + Head_weights.

stabilityHeuristic([Head_grid|Tail_grid], [Head_weights|Tail_weights],MaxPlayer,Head_grid, Res_PlayerMax, Res_PlayerMin) :-
                   stabilityHeuristic(Tail_grid, Tail_weights,MaxPlayer, Head_grid, Res_PlayerMax, Tmp_ResPlayerMin),!,
                   Res_PlayerMin is Tmp_ResPlayerMin + Head_weights.

stabilityHeuristic([_|TG], [_|TW], MaxPlayer, MinPlayer, ResMax, ResMin) :-
                    stabilityHeuristic(TG, TW, MaxPlayer, MinPlayer, ResMax, ResMin).

%Conversion grille en ligne
gridToLine(Grid, Res) :-
                   gridToLine(Grid, [], Res).
gridToLine([], Res, Res).
gridToLine([Line|Grid], Line_tmp, Line_out) :-
                   append(Line, Line_tmp, New_line),
                   gridToLine(Grid, New_line, Line_out).
