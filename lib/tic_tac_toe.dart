import 'dart:math';

import 'package:flutter/material.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({Key? key}) : super(key: key);

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  var playerTurn = true;
  var playerWins = false;
  var isClicked = false;
  var playWithAI = false;
  var values = List.generate(9, (index) => "");
  var winsCases = [
    [0, 1, 2],
    [0, 3, 6],
    [3, 4, 5],
    [6, 7, 8],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];
  playWithPc() {
    if (!playerWins) {
      Future.delayed(const Duration(seconds: 2), () {
        var randNum = Random().nextInt(8);
        if (values[randNum] == "") {
          changePlayerTurn(randNum);
        } else {
          playWithPc();
        }
      });
    }
  }

  checkWinCondition() async {
    for (var element in winsCases) {
      checkWin(element[0], element[1], element[2]);
    }
    var isGameOver = values.firstWhere((element) => element == "",
        orElse: () => "GAME OVER");
    print(isGameOver);
    if (isGameOver == "GAME OVER" && !playerWins) {
      await showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Game Over"),
              ));
      clear();
    }
  }

  checkWin(int x, int y, int z) {
    if (values[x] == values[y]) {
      if (values[x] != "") {
        if (values[x] == values[z]) playerWins = true;
      }
    }
  }

  changePlayerTurn(index) {
    if (values[index] == "") {
      values[index] = playerTurn ? "O" : "X";
      playerTurn = !playerTurn;
    }
    checkWinCondition();
    if (!playerTurn) {
      if (playWithAI) playWithPc();
    }

    setState(() {});
  }

  clear() {
    values = List.generate(9, (index) => "");
    playerTurn = true;
    playerWins = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    clear();
                  },
                  icon: const Icon(Icons.clear))
            ],
          ),
          Expanded(
            child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (_, i) => InkWell(
                      onTap: () {
                        if ((playerTurn || !playWithAI) && !playerWins) {
                          changePlayerTurn(i);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        height: 80,
                        width: 80,
                        child: Text(
                          values[i],
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    )),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
              "Player ${playerWins ? "${playerTurn ? "B" : "A"} Wins" : playerTurn ? "A Turn" : "B Turn"} "),
          SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Checkbox(
                  value: playWithAI,
                  onChanged: (bool? v) {
                    setState(() {
                      playWithAI = v!;
                    });
                  }),
              const Text("Play with AI")
            ],
          ),
          SizedBox(
            height: 16,
          ),
        ],
      )),
    );
  }
}
