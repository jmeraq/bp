package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)
/*
Se verifica que la respuesta del endpoint sea la correcta
*/
func TestResponseEndpoint(t *testing.T) {
	req, err := http.NewRequest("POST", "/DevOps", strings.NewReader(`{ "message" : "This is a test", "to": "Juan Perez", "from": "Rita Asturia", "timeToLifeSec" : 45 }`))

	if err != nil {
		fmt.Println(err)
	}

	rr := httptest.NewRecorder()
	http.HandlerFunc(responseMessage).ServeHTTP(rr, req)


	body, _ := ioutil.ReadAll(rr.Body)
	message := string(body)

	expected := `{"Message":"Hello Juan Perez your message will be send"}`
	if strings.TrimRight(message,"\n") != expected {
		t.Errorf("Response Incorrect. Se esperaba \n %s \n y se recibio \n %s", expected, message)
	}
}
/*
Verifica el estado de la peticion cuando no se ennvia data al endpoint
*/
func TestStatusNotDataEndpoint(t *testing.T)  {
	req, err := http.NewRequest("POST", "/DevOps",strings.NewReader(""))
	if err != nil {
		fmt.Println(err)
	}
	rr := httptest.NewRecorder()
	http.HandlerFunc(responseMessage).ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusUnprocessableEntity {
		t.Errorf("Status code differs. Expected %d .\n Got %d instead", http.StatusUnprocessableEntity, status)
	}
}
/*
Verifica el estado de la peticion cuando se envia data al endpoint
*/
func TestStatusDataEndpoint(t *testing.T)  {
	req, err := http.NewRequest("POST", "/DevOps",strings.NewReader(`{ "message" : "This is a test", "to": "Juan Perez", "from": "Rita Asturia", "timeToLifeSec" : 45 }`))
	if err != nil {
		fmt.Println(err)
	}
	rr := httptest.NewRecorder()
	http.HandlerFunc(responseMessage).ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Status code differs. Expected %d .\n Got %d instead", http.StatusOK, status)
	}
}

