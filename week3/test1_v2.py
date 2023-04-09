import random
import numpy as np

# Prepare the board with ships. This function takes the board size and the list of ship sizes as parameters and returns a prepared board.

# the board is 10x10, and there are 5 ships of sizes 2, 3, 3, 4, and 5
# play_game(10, [2, 3, 3, 4, 5])
# ship can be placed horizontally or vertically, but not diagonally
# 0 = horizontal, 1 = vertical
# Ships can touch each other but two ships cannot occupy the same cell. All ships should be completely within the playing board.


# prepare the board with ships
def prepare_board(board_size, ship_sizes):
    # initialize the board with empty squares
    board = [['O'] * board_size for _ in range(board_size)]
    # randomly place the ships on the board 
    for size in ship_sizes:
        orientation = random.randint(0, 1) # 0 = horizontal, 1 = vertical
        x, y = random.randint(0, board_size - size), random.randint(0, board_size - size) # random starting position
        if orientation == 0: # place the ship horizontally
            for i in range(size): # place the ship
                board[x + i][y] = 'S' 
        else:
            for i in range(size): # place the ship vertically
                board[x][y + i] = 'S'
    return board


# Game
# guess/hit their locations by providing row and column of the cell to hit.
# Player gets a response from the game on the result of the guess: hit or miss.
# When the player hits all parts/cells of all ships, the game is over.

# Player function might take the board size and its own version of the board with the history of past hits and misses as parameters and returns coordinates of the next guess.


# function for the player to guess the next cell
def player_guess(board_size, player_board):
    player_board = np.array(player_board) # convert the board to a numpy array
    if np.all(player_board == 'O'): # if the player has not made any guesses yet, make a random guess
        return np.random.randint(0, board_size), np.random.randint(0, board_size) 
    # np.argwhere function to find the indices of all the cells that contain 'O' (empty cells)
    candidates = np.argwhere(player_board == 'O') # find all the empty cells
    scores = [np.sum(player_board[max(i-1, 0):min(i+2, board_size), j] == 'O') + np.sum(player_board[i, max(j-1, 0):min(j+2, board_size)] == 'O') for i, j in candidates] # calculate the score for each empty cell
    best_guess = candidates[np.argmax(scores)] # find the cell with the highest score
    return tuple(best_guess) # return the coordinates of the cell

# Check function takes the board and player’s guess and returns the result: hit or miss.
# function to check if the guess hits a ship

def check_guess(board, guess):
    row, col = guess # get the row and column of the guess
    # use a dictionary to map the symbols on the board to the symbols on the player's board
    symbol_map = {'S': 'X', 'O': '-', '-': '-', 'X': 'X'} # map the symbols on the board to the symbols on the player's board, e.g. 'S' on the board is 'X' on the player's board, 'O' on the board is '-' on the player's board
    result = symbol_map.get(board[row][col], '-') # get the result of the guess
    board[row][col] = symbol_map[result] # update the board
    return result

# function to play the game
def play_game(board_size, ship_sizes):
    board = prepare_board(board_size, ship_sizes)
    player_board = [['O'] * board_size for _ in range(board_size)]
    num_guesses = 0
    while any('S' in row for row in board):
        guess = player_guess(board_size, player_board)
        result = check_guess(board, guess)
        player_board[guess[0]][guess[1]] = result
        print("Guess:", guess)
        print("Result:", result) # print the result of the guess
        num_guesses += 1
    return num_guesses


# Run a simulation: repeat the game 1000 (or more) times and report statistics of how long it takes for the player to finish the game. 

# simulation to test the average number of guesses required to win the game
num_games = 1000 # number of games to play
total_guesses = sum(play_game(10, [2, 3, 3, 4, 5]) for _ in range(num_games)) # sum the number of guesses required to win the game
average_guesses = total_guesses / num_games # calculate the average number of guesses required to win the game
print("Average number of guesses required to win the game:", average_guesses) # print the average number of guesses required to win the game