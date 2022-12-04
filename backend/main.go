/*
Copyright © 2022 Hamza Bilal hamza.cs@outlook.com
*/

package main

import (
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/spf13/viper"
	"log"
	"movies-service/cmd"
	"movies-service/pkg/routes"
	"movies-service/pkg/utils"
	"net/http"
)

func main() {
	prometheus.MustRegister(utils.HttpRequestsTotal)
	cmd.Execute()

	router := mux.NewRouter()
	routes.RegisterRecipeRoutes(router)
	http.Handle("/", router)
	log.Fatal(http.ListenAndServe(viper.GetString("server.url"), router))
}
