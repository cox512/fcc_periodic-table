#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

IS_INTEGER() {
    if [[ $1 =~ ^[0-9]+$ ]] 
      then
          return 0  # The parameter is an integer
      else
          return 1  # The parameter is not an integer
    fi
}

IS_LONGER_THAN_2_CHARS() {
    if [ ${#1} -gt 2 ] 
      then
          return 0  # The parameter is longer than 2 characters
      else
          return 1  # The parameter is not longer than 2 characters
    fi
}

SEARCH_BY_ATOMIC_NUMBER() {
#Get all the property values for the element based on the atomic_number
  PROPERTIES=$($PSQL "SELECT * FROM properties FULL JOIN elements ON properties.atomic_number = elements.atomic_number WHERE properties.atomic_number=$ELEMENT;")
}

SEARCH_BY_SYMBOL() {
#Get all the property values for the element based on the symbol
  PROPERTIES=$($PSQL "SELECT * FROM properties FULL JOIN elements ON properties.atomic_number = elements.atomic_number WHERE elements.symbol='$ELEMENT';")
}

SEARCH_BY_NAME() {
#Get all the property values for the element based on the name
  PROPERTIES=$($PSQL "SELECT * FROM properties FULL JOIN elements ON properties.atomic_number = elements.atomic_number WHERE elements.name='$ELEMENT';")
}

GET_ELEMENT_PROPERTIES() {
  #Create variable for passed in param
  local ELEMENT="$1"

  #Check if atomic number is passed in as param 
  if IS_INTEGER "$ELEMENT"
    then
      #Search by atomic number
      SEARCH_BY_ATOMIC_NUMBER "$ELEMENT"
    else
      #Symbol or name was passed in as Param
      if IS_LONGER_THAN_2_CHARS "$1"
        then
          #Search for element based on name
          SEARCH_BY_NAME "$ELEMENT"
        else
          #Search for element based on symbol
          SEARCH_BY_SYMBOL "$ELEMENT"
      fi
  fi

  if [[ -z $PROPERTIES ]]
    then
      echo "I could not find that element in the database."
    else
      #Parse the returned results of the SQL call
      echo $PROPERTIES | while IFS='|' read -r ATOMIC_NUMBER TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID ATOMIC_NUMBER_2 SYMBOL NAME
      do
        #Print details of the element
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      done
  fi
}

  if [ -z $1 ]
    then
      #No parameter was passed in
      echo Please provide an element as an argument
    else
      #Print out Element details
      GET_ELEMENT_PROPERTIES $1
  fi



