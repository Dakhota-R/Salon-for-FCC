#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


SELECT_SERVICE() {
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Sorry, that service could not be found."
  else
    SERVICE_NAME=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

    if [[ -z $SERVICE_NAME ]]
    then 
      MAIN_MENU "Sorry, that service could not be found."
    else
      echo -e "\nPlease enter the phone number associated with your account:"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_ID ]]
      then
        INSERT_NEW_CUSTOMER
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID';")
        FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *&//g')
        echo -e "\nHello $FORMATTED_CUSTOMER_NAME"
      fi
    fi
    CREATE_APPOINTMENT
  fi
}

INSERT_NEW_CUSTOMER() {
  echo -e "Please enter your name to create an account:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID';")
  FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *&//g')
  echo -e "\nThank you for creating an account $FORMATTED_CUSTOMER_NAME"
}

CREATE_APPOINTMENT() {
  echo -e "\nWhen would you like to make your appointment?"
  read SERVICE_TIME
  INSERT_SERVICE_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/^ *| *&//g')
  echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
}

MAIN_MENU(){
  # display error message
  if [[ $1 ]]
  then
    echo $1
  fi

  # get list of services
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "Please choose a service:\n"
  echo "$SERVICES_LIST"|while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  SELECT_SERVICE
}

MAIN_MENU