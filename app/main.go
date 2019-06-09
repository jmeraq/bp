package main

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"io/ioutil"
	"log"
	"net/http"
)

type ErrorMessage struct{
	Description string
	NumberError string
}

type ReceivedMessage struct {
	Message string `json:"message"`
	To string `json:to"`
	From string `json:"from"`
	TimeToLifeSec int `json:"timeToLifeSec"`
}

type ResponseMessage struct {
	Message string
}

func tokenMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("X-Parse-REST-API-Key")
		if token == "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" {
			next.ServeHTTP(w, r)
		}else {
			message := ErrorMessage{Description: "Forbidden",NumberError: "403"}
			w.WriteHeader(http.StatusForbidden)
			err := json.NewEncoder(w).Encode(message)
			fmt.Println(err)
		}
	})
}

func responseMessage(w http.ResponseWriter, r *http.Request){
	if r.Body == nil  {
		messageError := ErrorMessage{Description: "Post Data Structure is Incorrect",NumberError: "422"}
		w.WriteHeader(http.StatusUnprocessableEntity)
		err := json.NewEncoder(w).Encode(messageError)
		fmt.Println(err)
		return
	}else{
		body, _ := ioutil.ReadAll(r.Body)
		message := string(body)
		received := ReceivedMessage{}
		err := json.Unmarshal([]byte(message), &received)

		if err != nil{
			messageError := ErrorMessage{Description: "Post Data Structure is Incorrect",NumberError: "422"}
			w.WriteHeader(http.StatusUnprocessableEntity)
			err := json.NewEncoder(w).Encode(messageError)
			fmt.Println(err)
		}else{
			response := ResponseMessage{Message: "Hello "+received.To+" your message will be send"}
			w.WriteHeader(http.StatusOK)
			err := json.NewEncoder(w).Encode(response)
			if err != nil {
				fmt.Println(err)
			}
		}
	}
}

func errorPage(w http.ResponseWriter, r *http.Request){
	message := ErrorMessage{Description: "Method Not Allowed",NumberError: "405"}
	w.WriteHeader(http.StatusMethodNotAllowed)
	err := json.NewEncoder(w).Encode(message)
	fmt.Println(err)
}

func handleRequests()  {
	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/DevOps",responseMessage).Methods("post")
	router.HandleFunc("/DevOps",errorPage).Methods("get","delete","put","patch")
	router.Use(tokenMiddleware)
	log.Fatal(http.ListenAndServe(":8081", router))
}

func main(){
	handleRequests()
}
