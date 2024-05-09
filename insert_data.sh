#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Empty rows in the tables
$PSQL "TRUNCATE TABLE games, teams;"

# Reset team_id sequence to start from 1
$PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;"

# Read data from games.csv and insert into database
tail -n +2 games.csv | while IFS=, read -r year round winner opponent winner_goals opponent_goals; do
    # Insert winner team if it doesn't exist and get its team_id
    $PSQL "INSERT INTO teams (name) VALUES ('$winner') ON CONFLICT (name) DO NOTHING;"
    $PSQL "INSERT INTO teams (name) VALUES ('$opponent') ON CONFLICT (name) DO NOTHING;"
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

    # Insert game data
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$year', '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
done