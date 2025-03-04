import 'dart:io';
import 'dart:math';

const int gridSize = 10;

void main() {
  List<List<String>> playerGrid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => '⬜'));
  List<List<String>> computerGrid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => '⬜')); // Видимое поле компьютера для игрока
  List<List<String>> computerShips = List.generate(gridSize, (_) => List.generate(gridSize, (_) => '⬜'));
  List<List<String>> computerAttacks = List.generate(gridSize, (_) => List.generate(gridSize, (_) => '⬜')); // Поле для атак компьютера

  // Функция проверки завершения игры
  bool isGameOver(List<List<String>> grid) {
    for (var row in grid) {
      for (var cell in row) {
        if (cell == '🚢') {
          return false; // Есть ещё неуничтоженные корабли
        }
      }
    }
    return true; // Все корабли уничтожены
  }

  // Функция для отображения игрового поля
  void printGrid(List<List<String>> grid) {
    for (var row in grid) {
      print(row.join(' '));
    }
    print('');
  }

  // Видимое поле компьютера
  void printVisibleComputerGrid() {
    print("Поле компьютера (для игрока):");
    for (var row in computerGrid) {
      print(row.join(' '));
    }
    print('');
  }

  // Проверка возможности размещения корабля
  bool canPlaceShip(int x, int y, int length, bool horizontal, List<List<String>> grid) {
    for (int i = 0; i < length; i++) {
      int dx = horizontal ? x : x + i;
      int dy = horizontal ? y + i : y;

      if (dx >= gridSize || dy >= gridSize || grid[dx][dy] != '⬜') {
        return false;
      }

      for (int nx = dx - 1; nx <= dx + 1; nx++) {
        for (int ny = dy - 1; ny <= dy + 1; ny++) {
          if (nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize && grid[nx][ny] == '🚢') {
            return false;
          }
        }
      }
    }
    return true;
  }

  // Функция для размещения корабля
  void placeShip(int x, int y, int length, bool horizontal, List<List<String>> grid) {
    for (int i = 0; i < length; i++) {
      int dx = horizontal ? x : x + i;
      int dy = horizontal ? y + i : y;
      grid[dx][dy] = '🚢';
    }
  }

  // Ручная расстановка кораблей
  void manualPlacement(List<List<String>> grid) {
    var ships = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];
    for (var ship in ships) {
      bool placed = false;
      while (!placed) {
        printGrid(grid);
        print('Разместите корабль длиной $ship.');
        stdout.write('Введите начальные координаты (x y): ');
        var startInput = stdin.readLineSync();
        stdout.write('Введите конечные координаты (x y): ');
        var endInput = stdin.readLineSync();

        if (startInput == null || endInput == null) {
          print('Ошибка ввода. Попробуйте снова.\n');
          continue;
        }

        try {
          var startCoords = startInput.split(' ').map(int.parse).toList();
          var endCoords = endInput.split(' ').map(int.parse).toList();

          int x1 = startCoords[0];
          int y1 = startCoords[1];
          int x2 = endCoords[0];
          int y2 = endCoords[1];

          bool horizontal = x1 == x2; // Горизонтальная ориентация
          int length = horizontal ? (y2 - y1).abs() + 1 : (x2 - x1).abs() + 1;

          if (length == ship && canPlaceShip(x1, y1, ship, horizontal, grid)) {
            placeShip(x1, y1, ship, horizontal, grid);
            placed = true;
          } else {
            print('Невозможно разместить корабль. Убедитесь, что координаты корректны.\n');
          }
        } catch (e) {
          print('Ошибка ввода. Убедитесь, что координаты являются числами.\n');
        }
      }
    }
  }

  // Автоматическая расстановка кораблей
  void autoPlacement(List<List<String>> grid) {
    var ships = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];
    for (var ship in ships) {
      bool placed = false;
      while (!placed) {
        int x = Random().nextInt(gridSize);
        int y = Random().nextInt(gridSize);
        bool horizontal = Random().nextBool();
        if (canPlaceShip(x, y, ship, horizontal, grid)) {
          placeShip(x, y, ship, horizontal, grid);
          placed = true;
        }
      }
    }
  }

  // Атака компьютера по игроку
  void computerAttack(List<List<String>> playerGrid) {
    while (true) {
      int x = Random().nextInt(gridSize);
      int y = Random().nextInt(gridSize);

      if (playerGrid[x][y] == '⬜') {
        print('Компьютер стреляет в ($x, $y): Мимо.');
        playerGrid[x][y] = '❌';
        break;
      } else if (playerGrid[x][y] == '🚢') {
        print('Компьютер стреляет в ($x, $y): Попадание!');
        playerGrid[x][y] = '🔥';
        break;
      }
    }
  }

  // Основной процесс игры
  void playGame() {
    while (true) {
      print('Ваше поле:');
      printGrid(playerGrid);

      printVisibleComputerGrid();

      stdout.write('Введите координаты для атаки (x y): ');
      var input = stdin.readLineSync();
      if (input == null || input.isEmpty) continue;

      var coords;
      try {
        coords = input.split(' ').map(int.parse).toList();
      } catch (e) {
        print('Ошибка ввода. Введите два числа, разделённых пробелом.\n');
        continue;
      }

      if (coords.length != 2) {
        print('Введите два числа, разделённых пробелом!\n');
        continue;
      }

      int x = coords[0];
      int y = coords[1];

      if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) {
        print('Координаты вне игрового поля. Попробуйте снова.\n');
        continue;
      }

      if (computerGrid[x][y] != '⬜') {
        print('Вы уже стреляли в эту клетку. Попробуйте снова.\n');
        continue;
      }

      if (computerShips[x][y] == '🚢') {
        print('Вы попали!');
        computerGrid[x][y] = '🔥';
        computerShips[x][y] = '🔥';
      } else {
        print('Мимо.');
        computerGrid[x][y] = '❌';
      }

      if (isGameOver(computerShips)) {
        print('Поздравляем! Вы уничтожили все корабли компьютера.');
        break;
      }

      print('Теперь компьютер атакует!');
      computerAttack(playerGrid);

      if (isGameOver(playerGrid)) {
        print('К сожалению, компьютер уничтожил все ваши корабли. Вы проиграли.');
        break;
      }
    }
    
  }

  print('Добро пожаловать в классический "Морской бой"!');
  print('Выберите режим расстановки кораблей:');
  print('1. Ручной');
  print('2. Автоматический');
  stdout.write('Ваш выбор: ');

  var choice = stdin.readLineSync();
  if (choice == '1') {
    manualPlacement(playerGrid);
  } else {
    autoPlacement(playerGrid);
  }

  autoPlacement(computerShips);
  playGame();
}
