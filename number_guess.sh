#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate number to guess
RANDOM_1000=$(($RANDOM % 1000 + 1))
echo $RANDOM_1000

# prompt for username
echo "Enter your username:"
read USERNAME

# check username
USERNAME_RESULT=$($PSQL "SELECT games_played, best_game FROM games WHERE username = '$USERNAME'")

# if username not exist
if [[ -z $USERNAME_RESULT ]]
then

  # respond with welcome message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  # set username and games_played
  INSERT_USERNAME=$($PSQL "INSERT INTO games (username) VALUES ('$USERNAME')")
  GAMES_PLAYED=1

# if username exist
else
  echo $USERNAME_RESULT | while IFS="|" read GAMES_PLAYED BEST_GAME
  do

    # respond with welcome back message
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done

fi

# reset number of guesses
NUMBER_OF_GUESSES=0

# update number of games played
GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username = '$USERNAME'")
((GAMES_PLAYED++))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE games SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")

# ask for guess
echo "Guess the secret number between 1 and 1000:"

# start guessing loop
while true
do
  # increment number of guesses
  ((NUMBER_OF_GUESSES++))
 
  #accept guess
  read GUESS

  # check if guess is not integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then

    # ask for integer guess
    echo "That is not an integer, guess again:"

  # check if guess higher than random number
  elif [[ $GUESS -gt $RANDOM_1000 ]]
  then
      
      # give lower than hint
      echo "It's lower than that, guess again:"
  
  # check if guess lower than random number
  elif [[ $GUESS -lt $RANDOM_1000 ]]
  then

      #give higher than hint
      echo "It's higher than that, guess again:"

  else
    
    # respond with winning prompt
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_1000. Nice job!"

    # check if number of guesses beat prior best guess
    BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username = '$USERNAME'")

    if [[ -z $BEST_GAME || $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
    then

      # update best game
      UPDATE_BEST_GAME=$($PSQL "UPDATE games SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")

    fi

    exit

  fi

done  
