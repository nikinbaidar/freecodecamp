#!/bin/bash
PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"

echo "Enter your username:"
read username

secret_number=$((RANDOM % 1000 + 1))

USER_EXISTS=$($PSQL " SELECT EXISTS( SELECT 1 FROM users WHERE name='$username' ) ")

if [[ $USER_EXISTS == "t" ]]; then
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$username'")
  $PSQL "SELECT name, total_games_played, best_score FROM users WHERE user_id = $USER_ID" | while IFS="|" read name games_played best_game
  do
    echo "Welcome back, $name! You have played $games_played games, and your best game took $best_game guesses."
  done   
else
  echo Welcome, $username! It looks like this is your first time here.
  ADD_USER=$($PSQL "INSERT INTO users(name, total_games_played, best_score) VALUES('$username', 0, 1000)")

fi

echo Guess the secret number between 1 and 1000:
read guess

count=1

until [[ $guess =~ ^[0-9]+$ ]]; do
  echo "That is not an integer, guess again:"
  read guess
  (( count ++ ))
done

until [[ $guess -eq $secret_number ]]; do
  if [[ $secret_number -lt $guess ]]; then
    echo "It's lower than that, guess again:"
    read guess
    (( count ++ ))
    until [[ $guess =~ ^[0-9]+$ ]]; do
      echo "That is not an integer, guess again:"
      read guess
      (( count++ ))
    done
  elif [[ $secret_number -gt $guess ]]; then
    echo "It's higher than that, guess again:"
    read guess
    (( count++ ))
    until [[ $guess =~ ^[0-9]+$ ]]; do
      echo "That is not an integer, guess again:"
      read guess
      (( count++ ))
    done
  fi
done

echo "You guessed it in $count tries. The secret number was $secret_number. Nice job!"


UPDATE_STATS=$($PSQL \
 "UPDATE users
  SET 
    total_games_played = total_games_played + 1, 
    best_score = CASE WHEN $count < best_score THEN $count ELSE best_score END
    WHERE name = '$username'"
)
